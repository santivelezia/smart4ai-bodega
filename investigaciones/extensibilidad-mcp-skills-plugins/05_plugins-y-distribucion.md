> **Publicada por Smart4AI · fecha de corte 2026-08-17 · licencia CC BY-NC 4.0** (puedes usarla y adaptarla sin fines comerciales, dando crédito a Smart4AI).
> Parte de: Universo Claude 2026 · Módulo 2: extensibilidad (MCP, skills, plugins, hooks y subagentes). Las etiquetas entre corchetes (por ejemplo `[M2-C001: url]`) son la fuente de cada dato. Precios, límites y conteos cambian: verifícalos en la fuente oficial antes de usarlos.

## Estructura de directorio y manifiesto

- Un plugin de Claude Code es un directorio autocontenido cuyo manifiesto obligatorio vive en `.claude-plugin/plugin.json`; este archivo declara la identidad del plugin mediante los campos `name`, `description` y `version`, donde `name` fija el namespace de las skills contenidas [M2-C037: https://code.claude.com/docs/en/plugins.md].
- El error más frecuente es colocar directorios de componentes dentro de `.claude-plugin/`: únicamente `plugin.json` reside ahí; todos los demás artefactos —`skills/`, `commands/`, `agents/`, `hooks/`, `.mcp.json`, `.lsp.json`, `monitors/`, `bin/` y `settings.json`— deben situarse en la raíz del plugin [M2-C037: https://code.claude.com/docs/en/plugins.md].
- Los plugins definen sus servidores MCP mediante un archivo `.mcp.json` en la raíz del directorio o bien inline dentro del propio `plugin.json` [M2-C015: https://code.claude.com/docs/en/mcp.md].

## Empaquetado de capacidades: skills, agentes, hooks y MCP

- Agregar un `.claude-plugin/plugin.json` a una carpeta de skill convierte esa carpeta en un plugin cargado como `<nombre>@skills-dir`, lo que habilita el empaquetado conjunto de agentes, hooks y servidores MCP además de la skill base [M2-C015: https://code.claude.com/docs/en/skills.md].
- Las skills empaquetadas en un plugin residen en `<plugin>/skills/<nombre>/SKILL.md` y solo están disponibles cuando el plugin está habilitado en el contexto de ejecución [M2-C003: https://code.claude.com/docs/en/skills.md].
- Una skill exige un archivo `SKILL.md` como punto de entrada único, dividido en frontmatter YAML entre delimitadores `---` —que indica a Claude cuándo usarla— y cuerpo markdown con instrucciones; el nombre del directorio se convierte en el comando invocable y el campo `description` determina la carga automática por relevancia [M2-C001: https://code.claude.com/docs/en/skills.md].
- El cuerpo de una skill se carga bajo demanda (lazy loading), por lo que material de referencia extenso tiene coste de contexto nulo hasta su invocación; la recomendación oficial es migrar a skill cualquier sección de `CLAUDE.md` que dejó de ser un hecho estático para convertirse en un procedimiento [M2-C002: https://code.claude.com/docs/en/skills.md].

## Integración con MCP: protocolo, configuración y alcance

- MCP (Model Context Protocol) se centra exclusivamente en el protocolo de intercambio de contexto: no prescribe cómo la aplicación de IA utiliza el LLM ni cómo gestiona el contexto recibido [M2-C055: https://modelcontextprotocol.io/docs/learn/architecture].
- El proyecto MCP se compone de cuatro elementos: la especificación en `modelcontextprotocol.io/specification`, SDKs por lenguaje, herramientas de desarrollo como el MCP Inspector (`github.com/modelcontextprotocol/inspector`), e implementaciones de referencia de servidores en `github.com/modelcontextprotocol/servers` [M2-C055: https://modelcontextprotocol.io/docs/learn/architecture].
- MCP soporta extensiones opcionales además de sus primitivas de núcleo; la extensión Tasks permite que un servidor devuelva un handle durable para peticiones de larga duración, posibilitando que el cliente consulte el estado y recupere el resultado posteriormente sin mantener la conexión abierta [M2-C059: https://modelcontextprotocol.io/docs/learn/architecture].
- Los servidores MCP de alcance proyecto se declaran en `.mcp.json` en la raíz del proyecto, son versionables y se configuran con el flag `-s` o `--scope` al agregarlos; al crearse quedan en estado `Pending approval` hasta que un usuario los apruebe en una sesión interactiva, momento en el que aparecen en `claude mcp list` y `claude mcp get` [M2-C008: https://code.claude.com/docs/en/mcp.md].
- En la configuración JSON de servidores MCP —ya sea `.mcp.json`, `~/.claude.json` o vía `claude mcp add-json`— el campo `type` acepta `streamable-http` como alias de `http`, alineándose con la nomenclatura de la especificación MCP; si una entrada incluye `url` pero omite `type`, Claude Code la interpreta erróneamente como servidor `stdio`, la omite y reporta el error solicitando agregar `type: http`, `sse` o `ws` [M2-C009: https://code.claude.com/docs/en/mcp.md].
- Con `tool search` activo —el comportamiento predeterminado— únicamente los nombres de las herramientas MCP entran al contexto inicial; el esquema completo se carga en el momento en que Claude va a usar una herramienta específica. Esta optimización se desactiva cuando existe una `ANTHROPIC_BASE_URL` personalizada, cuando la variable `ENABLE_TOOL_SEARCH` es `false`, o al usar modelos anteriores a la generación 4.5 en Google Cloud [M2-C011: https://code.claude.com/docs/en/mcp.md].
- Cinco nombres de servidor están reservados para los servidores integrados de Claude Code: `workspace`, `claude-in-chrome`, `computer-use`, `Claude Preview` y `Claude Browser`. Si una configuración define un servidor con nombre reservado, Claude Code lo omite al cargar y muestra un aviso pidiendo renombrarlo; el comando `claude mcp add` lo rechaza con error [M2-C012: https://code.claude.com/docs/en/mcp.md].

## Distribución: marketplaces oficiales y comunitarios

- Anthropic mantiene dos marketplaces públicos de plugins: `claude-plugins-official`, un conjunto curado que Claude Code registra automáticamente en el primer arranque interactivo y al que no existe proceso de aplicación para desarrolladores; y `claude-community`, el marketplace público donde aterrizan las contribuciones de terceros tras revisión, que se agrega manualmente con `/plugin marketplace add anthropics/claude-plugins-community` [M2-C038: https://code.claude.com/docs/en/plugins.md].

## Validación y seguridad antes de publicar

- Antes de publicar un plugin debe ejecutarse `claude plugin validate <ruta>`, que ejecuta exactamente la misma verificación que el pipeline de revisión en cada envío, junto con un screening automático de seguridad [M2-C039: https://code.claude.com/docs/en/plugins.md].
- Si la validación pasa, el CLI imprime `Validation passed`; si existen advertencias, imprime `Validation passed with warnings`. Las advertencias no reprueban la publicación a menos que se utilice el flag `--strict` [M2-C039: https://code.claude.com/docs/en/plugins.md].
- Los plugins aprobados quedan fijados (pineados) a un commit SHA específico en el catálogo público, garantizando inmutabilidad de la versión distribuida [M2-C039: https://code.claude.com/docs/en/plugins.md].

## Desarrollo local y recarga en caliente

- Para desarrollar plugins localmente se utiliza `claude --plugin-dir <ruta>`, que también acepta un archivo `.zip` y puede repetirse para cargar múltiples plugins simultáneamente [M2-C040: https://code.claude.com/docs/en/plugins.md].
- Un plugin cargado mediante `--plugin-dir` tiene precedencia sobre uno instalado del marketplace que tenga el mismo nombre, salvo que la configuración de `managed settings` fuerce explícitamente habilitar o deshabilitar el plugin [M2-C040: https://code.claude.com/docs/en/plugins.md].
- Tras modificar archivos del plugin en desarrollo, el comando `/reload-plugins` recarga plugins, skills, agentes, hooks y servidores MCP y LSP asociados sin necesidad de reiniciar la sesión de Claude Code [M2-C040: https://code.claude.com/docs/en/plugins.md].

## Skills: alcance, resolución de conflictos y disponibilidad en entornos remotos

- Las skills residen en tres ubicaciones con alcance distinto: personales en `~/.claude/skills/<nombre>/SKILL.md` (todos los proyectos), de proyecto en `.claude/skills/<nombre>/SKILL.md` (repositorio único), y de plugin en `<plugin>/skills/<nombre>/SKILL.md` (donde el plugin esté habilitado). Cuando una skill existe simultáneamente en la ubicación personal y la de proyecto, se ejecuta la personal [M2-C003: https://code.claude.com/docs/en/skills.md].
- Una skill ubicada exclusivamente en `~/.claude/skills/` de la máquina local no está disponible cuando una routine la invoca, porque cada ejecución de routine inicia una sesión remota nueva sin acceso al filesystem local; para entornos en la nube la skill debe commitearse al directorio `.claude/skills/` del repositorio o distribuirse mediante un plugin declarado en el `.claude/settings.json` del repo [M2-C007: https://code.claude.com/docs/en/skills.md].

**Si te llevas UNA cosa:** El plugin es el único artefacto de empaquetado que permite distribuir skills, agentes, hooks y servidores MCP bajo un namespace versionado, y es el mecanismo requerido para que cualquier extensión sobreviva al paso de una sesión local a una routine remota o a un marketplace comunitario.
