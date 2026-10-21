> **Publicada por Smart4AI · fecha de corte 2026-08-17 · licencia CC BY-NC 4.0** (puedes usarla y adaptarla sin fines comerciales, dando crédito a Smart4AI).
> Parte de: Universo Claude 2026 · Módulo 2: extensibilidad (MCP, skills, plugins, hooks y subagentes). Las etiquetas entre corchetes (por ejemplo `[M2-C001: url]`) son la fuente de cada dato. Precios, límites y conteos cambian: verifícalos en la fuente oficial antes de usarlos.

## Definición y arquitectura de 3 participantes
- MCP es un protocolo cliente-servidor con 3 roles fijos: MCP Host (la aplicación de IA: Claude Code, Claude Desktop, VS Code), que coordina uno o varios clientes; MCP Client, que mantiene exactamente 1 conexión dedicada con 1 servidor; y MCP Server, el programa que provee contexto [M2-C046: https://modelcontextprotocol.io/docs/learn/architecture]
- El host crea 1 cliente por cada servidor; los servidores locales con transporte STDIO suelen atender 1 solo cliente, mientras que los remotos con Streamable HTTP suelen atender muchos clientes simultáneos [M2-C046: https://modelcontextprotocol.io/docs/learn/architecture]

## Capas del protocolo: datos y transporte
- La especificación separa 2 capas: la capa de datos, que define el intercambio basado en JSON-RPC 2.0 con primitivas y notificaciones; y la capa de transporte, que define los canales de comunicación y la autorización [M2-C047: https://modelcontextprotocol.io/docs/learn/architecture]
- En la capa de transporte la especificación soporta 2 mecanismos: Stdio (procesos locales, sin overhead de red) y Streamable HTTP (POST con Server-Sent Events opcional, para servidores remotos) [M2-C047: https://modelcontextprotocol.io/docs/learn/architecture]
- Streamable HTTP soporta autenticación por bearer tokens, API keys o headers; la recomendación oficial de MCP es usar OAuth [M2-C047: https://modelcontextprotocol.io/docs/learn/architecture]

## Primitivas de servidor
- Los servidores MCP exponen 3 primitivas: Tools (funciones ejecutables que la aplicación de IA invoca para actuar), Resources (fuentes de datos que aportan contexto) y Prompts (plantillas reutilizables para estructurar interacciones) [M2-C043: https://modelcontextprotocol.io/docs/learn/architecture]
- Cada tipo expone métodos de descubrimiento (`*/list`), obtención (`*/get`) y, en el caso de Tools, ejecución (`tools/call`) [M2-C043: https://modelcontextprotocol.io/docs/learn/architecture]

## Primitivas de cliente y deprecaciones 2026-07-28
- La versión de protocolo 2026-07-28 deprecia Sampling y Logging como primitivas de cliente; Sampling, que permitía al servidor pedir completions al modelo del cliente, queda obsoleto en favor de integrar directamente con las APIs del proveedor de LLM [M2-C044: https://modelcontextprotocol.io/docs/learn/architecture]
- Logging como primitiva de cliente se reemplaza por escribir a stderr en transporte stdio o por usar OpenTelemetry [M2-C044: https://modelcontextprotocol.io/docs/learn/architecture]
- Tras el cambio, la única primitiva de cliente vigente es Elicitation, con el método `elicitation/create` [M2-C044: https://modelcontextprotocol.io/docs/learn/architecture]

## Modelo stateless y discovery obligatoria
- MCP opera como protocolo stateless: cada petición lleva en su campo `_meta` la versión de protocolo y las capacidades relevantes, de modo que el servidor no infiere nada de peticiones previas [M2-C045: https://modelcontextprotocol.io/docs/learn/architecture]
- Los servidores anuncian versiones y capacidades únicamente mediante la petición obligatoria `server/discover`, que el cliente puede emitir antes que cualquier otra llamada [M2-C045: https://modelcontextprotocol.io/docs/learn/architecture]
- La respuesta de `server/discover` es cacheable e incluye los campos `ttlMs` y `cacheScope` [M2-C045: https://modelcontextprotocol.io/docs/learn/architecture]

## Notificaciones opt-in y best effort
- Las notificaciones de cambio son opt-in: el cliente abre un stream de larga duración con `subscriptions/listen` nombrando explícitamente los tipos que quiere recibir, y el servidor entrega solo esos [M2-C048: https://modelcontextprotocol.io/docs/learn/architecture]
- Son best effort, sin garantía de entrega especialmente al reconectar, por lo que el cliente debe seguir haciendo polling para preservar frescura de datos [M2-C048: https://modelcontextprotocol.io/docs/learn/architecture]
- Cada notificación lleva el `subscriptionId` dentro del campo `_meta` [M2-C048: https://modelcontextprotocol.io/docs/learn/architecture]

## Transportes: Stdio, Streamable HTTP y WebSocket
- Además de Stdio y Streamable HTTP, Claude Code soporta WebSocket para servidores MCP que empujan eventos sin que se los pidan, manteniendo una conexión bidireccional persistente [M2-C010: https://code.claude.com/docs/en/mcp.md]
- WebSocket tiene 2 limitaciones frente a HTTP: no soporta OAuth y no es aceptado por el flag `claude mcp add --transport`; debe configurarse en `.mcp.json` o con `claude mcp add-json`, y su autenticación es exclusivamente por headers [M2-C010: https://code.claude.com/docs/en/mcp.md]
- En la configuración JSON (`.mcp.json`, `~/.claude.json` o `claude mcp add-json`), el campo `type` acepta `streamable-http` como alias de `http` porque así lo nombra la especificación MCP, permitiendo copiar configuraciones de documentación de servidores sin modificarlas [M2-C009: https://code.claude.com/docs/en/mcp.md]
- Una entrada que incluye `url` pero omite `type` es un error de configuración: Claude Code la interpreta como servidor stdio, la omite del cargado y reporta el problema pidiendo agregar `type http`, `sse` o `ws` [M2-C009: https://code.claude.com/docs/en/mcp.md]

## Configuración, alcance y reservas en Claude Code
- Servidores de alcance project se declaran en `.mcp.json` en la raíz del repositorio, son versionables y se comparten con todo el equipo; se eligen con el flag `-s` o `--scope` al agregar el servidor [M2-C008: https://code.claude.com/docs/en/mcp.md]
- Los servidores project quedan en estado `Pending approval` hasta que se aprueban en una sesión interactiva; aparecen como pendientes en `claude mcp list` y `claude mcp get` [M2-C008: https://code.claude.com/docs/en/mcp.md]
- 5 nombres de servidor están reservados para los servidores integrados de Claude Code: `workspace`, `claude-in-chrome`, `computer-use`, `Claude Preview` y `Claude Browser` [M2-C012: https://code.claude.com/docs/en/mcp.md]
- Si una configuración define un nombre reservado, Claude Code lo omite al cargar y muestra aviso pidiendo renombrarlo; el comando `claude mcp add` lo rechaza con error [M2-C012: https://code.claude.com/docs/en/mcp.md]
- Con tool search activo (default), las definiciones completas de herramientas MCP no entran al contexto; solo ingresan los nombres y el esquema completo se carga cuando Claude va a usar una herramienta específica [M2-C011: https://code.claude.com/docs/en/mcp.md]
- Tool search se desactiva automáticamente cuando existe un `ANTHROPIC_BASE_URL` custom, cuando la variable `ENABLE_TOOL_SEARCH` es `false`, o con modelos anteriores a la generación 4.5 en Google Cloud [M2-C011: https://code.claude.com/docs/en/mcp.md]

## Integración con Skills, Hooks y contexto de ejecución
- Las Agent Skills son directorios con punto de entrada obligatorio `SKILL.md` (frontmatter YAML entre `---` y contenido markdown); el nombre del directorio se convierte en comando y el campo `description` activa la carga automática cuando es relevante [M2-C001: https://code.claude.com/docs/en/skills.md]
- El cuerpo de una skill se carga solo cuando se usa, a diferencia de `CLAUDE.md` que permanece siempre en contexto; la recomendación oficial es crear una skill cuando una sección de `CLAUDE.md` dejó de ser un hecho y se convirtió en procedimiento [M2-C002: https://code.claude.com/docs/en/skills.md]
- Las skills se resuelven en 3 ubicaciones con alcance distinto: `~/.claude/skills/<nombre>/` (personal, todos los proyectos), `.claude/skills/<nombre>/` (proyecto, solo ese repo) y `<plugin>/skills/<nombre>/` (plugin, donde el plugin esté habilitado); si existe en personal y proyecto, gana la personal [M2-C003: https://code.claude.com/docs/en/skills.md]
- Una skill exclusiva en `~/.claude/skills/` de la máquina local no está disponible cuando una routine la invoca, porque cada corrida de routine arranca como sesión remota nueva; para ejecución en la nube hay que commitear la skill al repo o distribuirla en un plugin declarado en `.claude/settings.json` [M2-C007: https://code.claude.com/docs/en/skills.md]
- Claude Code expone 31 eventos de hook que cubren todo el ciclo de vida de sesión; 14 pueden bloquear la acción (`UserPromptSubmit`, `UserPromptExpansion`, `PreToolUse`, `PostToolBatch`, `SubagentStop`, `TaskCreated`, `TaskCompleted`, `Stop`, `TeammateIdle`, `ConfigChange`, `WorktreeCreate`, `PreCompact`, `Elicitation`, `ElicitationResult`) y 17 son de observación sin capacidad de bloqueo [M2-C016: https://code.claude.com/docs/en/hooks.md]

**Si te llevas UNA cosa:** MCP 2026-07-28 es ahora un protocolo stateless y minimalista: el servidor solo declara Tools, Resources y Prompts vía la llamada obligatoria `server/discover`, el cliente solo expone la primitiva `elicitation/create`, y todo lo demás (sampling, logging, estado, eventos push) se resuelve fuera del protocolo mediante APIs directas de LLM, OpenTelemetry, o conexiones WebSocket best-effort gestionadas por el host.
