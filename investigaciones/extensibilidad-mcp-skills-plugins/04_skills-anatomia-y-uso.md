> **Publicada por Smart4AI · fecha de corte 2026-08-17 · licencia CC BY-NC 4.0** (puedes usarla y adaptarla sin fines comerciales, dando crédito a Smart4AI).
> Parte de: Universo Claude 2026 · Módulo 2: extensibilidad (MCP, skills, plugins, hooks y subagentes). Las etiquetas entre corchetes (por ejemplo `[M2-C001: url]`) son la fuente de cada dato. Precios, límites y conteos cambian: verifícalos en la fuente oficial antes de usarlos.

## Definición y anatomía de una Agent Skill

- Una Agent Skill es un directorio de archivo único cuyo punto de entrada obligatorio es `SKILL.md` [M2-C001: https://code.claude.com/docs/en/skills.md]
- El archivo `SKILL.md` se divide en dos partes estructurales: frontmatter YAML delimitado por marcadores `---` y contenido markdown con las instrucciones operativas [M2-C001: https://code.claude.com/docs/en/skills.md]
- El frontmatter YAML le indica a Claude cuándo debe usar la skill [M2-C001: https://code.claude.com/docs/en/skills.md]
- El contenido markdown posterior contiene las instrucciones que Claude ejecuta al invocar la skill [M2-C001: https://code.claude.com/docs/en/skills.md]
- El nombre del directorio que contiene `SKILL.md` se convierte automáticamente en el comando invocable por el usuario [M2-C001: https://code.claude.com/docs/en/skills.md]
- El campo `description` dentro del frontmatter es el mecanismo que hace que Claude cargue la skill automáticamente cuando detecta relevancia temática [M2-C001: https://code.claude.com/docs/en/skills.md]
- Los únicos campos obligatorios en la definición de una skill son `name` y `description` [M2-C030: https://platform.claude.com/docs/en/agents-and-tools/agent-skills/overview.md]
- El campo `name` admite un máximo de 64 caracteres [M2-C030: https://platform.claude.com/docs/en/agents-and-tools/agent-skills/overview.md]
- El campo `name` solo permite minúsculas, números y guiones [M2-C030: https://platform.claude.com/docs/en/agents-and-tools/agent-skills/overview.md]
- El campo `name` prohíbe etiquetas XML [M2-C030: https://platform.claude.com/docs/en/agents-and-tools/agent-skills/overview.md]
- El campo `name` no puede contener las palabras reservadas `anthropic` ni `claude` [M2-C030: https://platform.claude.com/docs/en/agents-and-tools/agent-skills/overview.md]
- El campo `description` debe ser no vacío [M2-C030: https://platform.claude.com/docs/en/agents-and-tools/agent-skills/overview.md]
- El campo `description` tiene un límite máximo de 1.024 caracteres [M2-C030: https://platform.claude.com/docs/en/agents-and-tools/agent-skills/overview.md]
- El campo `description` prohíbe etiquetas XML [M2-C030: https://platform.claude.com/docs/en/agents-and-tools/agent-skills/overview.md]
- El campo `description` debe cumplir una doble función en su redacción: declarar qué hace la skill y especificar cuándo usarla [M2-C030: https://platform.claude.com/docs/en/agents-and-tools/agent-skills/overview.md]

## Progressive Disclosure y costo real en tokens

- El sistema de skills implementa un modelo de progressive disclosure de tres niveles que mide el costo de contexto en tokens [M2-C029: https://platform.claude.com/docs/en/agents-and-tools/agent-skills/overview.md]
- Nivel 1 (metadata): los campos `name` y `description` del frontmatter se cargan siempre al arranque de la sesión [M2-C029: https://platform.claude.com/docs/en/agents-and-tools/agent-skills/overview.md]
- El costo del Nivel 1 es de aproximadamente 100 tokens por skill [M2-C029: https://platform.claude.com/docs/en/agents-and-tools/agent-skills/overview.md]
- Nivel 2 (instrucciones): el cuerpo completo de `SKILL.md` se carga únicamente cuando la skill se dispara por comando o por relevancia automática [M2-C029: https://platform.claude.com/docs/en/agents-and-tools/agent-skills/overview.md]
- El costo del Nivel 2 es de menos de 5.000 tokens [M2-C029: https://platform.claude.com/docs/en/agents-and-tools/agent-skills/overview.md]
- Nivel 3 (recursos y scripts): no incurre en costo de contexto hasta que el flujo de la skill accede explícitamente a ellos [M2-C029: https://platform.claude.com/docs/en/agents-and-tools/agent-skills/overview.md]
- En el Nivel 3, únicamente la salida de ejecución de los scripts entra al contexto; el código fuente de los scripts nunca se inyecta en el contexto [M2-C029: https://platform.claude.com/docs/en/agents-and-tools/agent-skills/overview.md]

## Ventaja de contexto sobre CLAUDE.md

- La ventaja estructural de una skill respecto a `CLAUDE.md` radica en que el cuerpo de la skill se carga solo cuando se usa [M2-C002: https://code.claude.com/docs/en/skills.md]
- El material de referencia extenso alojado en una skill cuesta prácticamente 0 tokens hasta que se necesita activamente [M2-C002: https://code.claude.com/docs/en/skills.md]
- La recomendación oficial de Anthropic es crear una skill en el momento exacto en que una sección de `CLAUDE.md` dejó de ser un hecho declarativo y se convirtió en un procedimiento operativo [M2-C002: https://code.claude.com/docs/en/skills.md]

## Ubicaciones, alcance y precedencia

- Las skills residen en tres ubicaciones con alcances mutuamente excluyentes [M2-C003: https://code.claude.com/docs/en/skills.md]
- Ubicación personal: `~/.claude/skills/<nombre>/SKILL.md`, aplicable a todos los proyectos del usuario en la máquina local [M2-C003: https://code.claude.com/docs/en/skills.md]
- Ubicación de proyecto: `.claude/skills/<nombre>/SKILL.md`, aplicable únicamente al proyecto que contiene ese directorio [M2-C003: https://code.claude.com/docs/en/skills.md]
- Ubicación de plugin: `<plugin>/skills/<nombre>/SKILL.md`, disponible únicamente cuando el plugin correspondiente está habilitado [M2-C003: https://code.claude.com/docs/en/skills.md]
- La precedencia de resolución de conflictos favorece la skill personal: cuando una skill con idéntico nombre existe en ubicación personal y de proyecto, se ejecuta la personal [M2-C003: https://code.claude.com/docs/en/skills.md]
- Las skills también se cargan desde directorios `.claude/skills/` anidados por debajo del directorio de trabajo actual [M2-C004: https://code.claude.com/docs/en/skills.md]
- Las skills anidadas no se activan al inicio de la sesión [M2-C004: https://code.claude.com/docs/en/skills.md]
- El disparador de activación de una skill anidada ocurre la primera vez que Claude lee o edita un archivo dentro de ese subdirectorio [M2-C004: https://code.claude.com/docs/en/skills.md]
- Hasta el momento de activación, las skills anidadas no aparecen en el autocompletado de comandos [M2-C004: https://code.claude.com/docs/en/skills.md]
- Hasta el momento de activación, las skills anidadas no se pueden invocar por nombre [M2-C004: https://code.claude.com/docs/en/skills.md]
- Este mecanismo de activación diferida permite que un paquete individual dentro de un monorepo aporte sus propias skills sin contaminar el contexto inicial del repositorio [M2-C004: https://code.claude.com/docs/en/skills.md]
- Una skill que existe únicamente en `~/.claude/skills/` de la máquina local no está disponible cuando una routine la invoca [M2-C007: https://code.claude.com/docs/en/skills.md]
- La causa de la indisponibilidad en routines es que cada corrida de routine arranca como una sesión remota nueva sin acceso al filesystem local del usuario [M2-C007: https://code.claude.com/docs/en/skills.md]
- Para hacer una skill disponible en sesiones en la nube o routines, hay que commitearla al directorio `.claude/skills/` del repositorio [M2-C007: https://code.claude.com/docs/en/skills.md]
- Alternativa para nube: distribuir la skill dentro de un plugin declarado en el archivo `.claude/settings.json` del repositorio [M2-C007: https://code.claude.com/docs/en/skills.md]

## Fusión con Custom Commands

- Los custom commands heredados se fusionaron conceptualmente con el sistema de skills [M2-C005: https://code.claude.com/docs/en/skills.md]
- Un archivo ubicado en `.claude/commands/deploy.md` y una skill ubicada en `.claude/skills/deploy/SKILL.md` generan ambos el comando `/deploy` [M2-C005: https://code.claude.com/docs/en/skills.md]
- Ambas formas de definición funcionan de manera idéntica en la interfaz de usuario [M2-C005: https://code.claude.com/docs/en/skills.md]
- Los archivos existentes en `.claude/commands/` siguen funcionando sin migración forzosa [M2-C005: https://code.claude.com/docs/en/skills.md]
- Las skills añaden tres capacidades que los custom commands originales no poseían: directorio de archivos de apoyo, frontmatter para controlar quién las invoca, y carga automática por relevancia [M2-C005: https://code.claude.com/docs/en/skills.md]

## Hot-reload y ciclo de vida en sesión

- Claude Code vigila activamente los directorios de skills durante la sesión en curso [M2-C006: https://code.claude.com/docs/en/skills.md]
- El sistema detecta altas, ediciones y bajas de skills sin requerir reinicio de la sesión [M2-C006: https://code.claude.com/docs/en/skills.md]
- La detección en vivo cubre exclusivamente el texto contenido en `SKILL.md` [M2-C006: https://code.claude.com/docs/en/skills.md]
- Si la carpeta de la skill es simultáneamente un plugin, los cambios en subdirectorios `hooks/`, en `.mcp.json`, en `agents/` y en `output-styles/` no se detectan en vivo [M2-C006: https://code.claude.com/docs/en/skills.md]
- Para aplicar cambios en los artefactos de plugin asociados a una skill, se requiere ejecutar explícitamente el comando `/reload-plugins` [M2-C006: https://code.claude.com/docs/en/skills.md]

## Skills oficiales de Anthropic

- Anthropic publica exactamente 4 Agent Skills pre-construidas [M2-C028: https://platform.claude.com/docs/en/agents-and-tools/agent-skills/overview.md]
- Las 4 skills oficiales están orientadas exclusivamente a tareas documentales [M2-C028: https://platform.claude.com/docs/en/agents-and-tools/agent-skills/overview.md]
- El inventario oficial es: PowerPoint (`skill_id: pptx`), Excel (`skill_id: xlsx`), Word (`skill_id: docx`) y PDF (`skill_id: pdf`) [M2-C028: https://platform.claude.com/docs/en/agents-and-tools/agent-skills/overview.md]
- Estas skills están disponibles en la Claude API [M2-C028: https://platform.claude.com/docs/en/agents-and-tools/agent-skills/overview.md]
- Estas skills están disponibles en Claude Platform on AWS [M2-C028: https://platform.claude.com/docs/en/agents-and-tools/agent-skills/overview.md]
- Estas skills están disponibles en Microsoft Foundry [M2-C028: https://platform.claude.com/docs/en/agents-and-tools/agent-skills/overview.md]
- Estas skills están disponibles en claude.ai [M2-C028: https://platform.claude.com/docs/en/agents-and-tools/agent-skills/overview.md]
- Estas 4 skills oficiales no están disponibles en Claude Code [M2-C028: https://platform.claude.com/docs/en/agents-and-tools/agent-skills/overview.md]

## Marketplace de plugins y skills de flujo

- El marketplace oficial incluye plugins de flujo de desarrollo que incorporan skills y agentes listos para uso [M2-C057: https://code.claude.com/docs/en/discover-plugins.md]
- Plugin `commit-commands`: provee flujos de git que incluyen commit, push y creación de PR [M2-C057: https://code.claude.com/docs/en/discover-plugins.md]
- Plugin `pr-review-toolkit`: contiene agentes especializados para revisar pull requests [M2-C057: https://code.claude.com/docs/en/discover-plugins.md]
- Plugin `agent-sdk-dev`: provee herramientas para construir con el Claude Agent SDK [M2-C057: https://code.claude.com/docs/en/discover-plugins.md]
- Plugin `plugin-dev`: kit para crear plugins propios [M2-C057: https://code.claude.com/docs/en/discover-plugins.md]
- El marketplace también distribuye plugins de output style: `explanatory-output-style` y `learning-output-style` [M2-C057: https://code.claude.com/docs/en/discover-plugins.md]
- El plugin oficial `security-guidance` revisa cada cambio que hace Claude buscando vulnerabilidades comunes [M2-C058: https://code.claude.com/docs/en/discover-plugins.md]
- El plugin `security-guidance` instruye a Claude a corregir lo encontrado dentro de la misma sesión, en lugar de diferir la corrección a una auditoría posterior [M2-C058: https://code.claude.com/docs/en/discover-plugins.md]

## Integración con MCP: contexto lazy y configuración

- Con tool search activo, que es el comportamiento por defecto, las definiciones completas de herramientas MCP no entran al contexto inicial [M2-C011: https://code.claude.com/docs/en/mcp.md]
- En modo tool search activo, únicamente los nombres de las herramientas MCP residen en el contexto [M2-C011: https://code.claude.com/docs/en/mcp.md]
- El esquema completo de una herramienta MCP se carga en contexto únicamente cuando Claude va a usar esa herramienta específica [M2-C011: https://code.claude.com/docs/en/mcp.md]
- Tool search se desactiva automáticamente cuando se configura un `ANTHROPIC_BASE_URL` custom [M2-C011: https://code.claude.com/docs/en/mcp.md]
- Tool search se desactiva cuando la variable de entorno `ENABLE_TOOL_SEARCH` se establece en `false` [M2-C011: https://code.claude.com/docs/en/mcp.md]
- Tool search se desactiva con modelos anteriores a la generación 4.5 ejecutándose en Google Cloud [M2-C011: https://code.claude.com/docs/en/mcp.md]
- Los servidores MCP de alcance project se comparten con todo el equipo mediante el archivo `.mcp.json` ubicado en la raíz del proyecto [M2-C008: https://code.claude.com/docs/en/mcp.md]
- Los servidores de alcance project son versionables al residir en el repositorio [M2-C008: https://code.claude.com/docs/en/mcp.md]
- El alcance project se elige con el flag `-s` o `--scope` al agregar el servidor [M2-C008: https://code.claude.com/docs/en/mcp.md]
- Los servidores de alcance project quedan en estado pendiente de aprobación tras su configuración [M2-C008: https://code.claude.com/docs/en/mcp.md]
- Un servidor pendiente aparece como `Pending approval` en la salida de `claude mcp list` [M2-C008: https://code.claude.com/docs/en/mcp.md]
- Un servidor pendiente aparece como `Pending approval` en la salida de `claude mcp get` [M2-C008: https://code.claude.com/docs/en/mcp.md]
- El servidor permanece bloqueado hasta que un usuario lo aprueba en una sesión interactiva [M2-C008: https://code.claude.com/docs/en/mcp.md]
- En la configuración JSON de servidores MCP (vía `.mcp.json`, `~/.claude.json` o `claude mcp add-json`), el campo `type` acepta `streamable-http` como alias de `http` [M2-C009: https://code.claude.com/docs/en/mcp.md]
- El alias `streamable-http` existe para permitir copiar configuraciones directamente desde la documentación de un servidor MCP sin modificarlas [M2-C009: https://code.claude.com/docs/en/mcp.md]
- Una entrada JSON que trae `url` pero no trae `type` es un error de configuración [M2-C009: https://code.claude.com/docs/en/mcp.md]
- Ante una entrada con `url` y sin `type`, Claude Code la interpreta erróneamente como servidor `stdio`, la omite del cargado y reporta el problema [M2-C009: https://code.claude.com/docs/en/mcp.md]
- El mensaje de error solicita agregar explícitamente `type: http`, `type: sse` o `type: ws` [M2-C009: https://code.claude.com/docs/en/mcp.md]
- Cinco nombres de servidor están reservados para los servidores integrados de Claude Code [M2-C012: https://code.claude.com/docs/en/mcp.md]
- Los nombres reservados son: `workspace`, `claude-in-chrome`, `computer-use`, `Claude Preview` y `Claude Browser` [M2-C012: https://code.claude.com/docs/en/mcp.md]
- Si una configuración define un servidor con nombre reservado, Claude Code lo omite al cargar y muestra un aviso pidiendo renombrarlo [M2-C012: https://code.claude.com/docs/en/mcp.md]
- El comando `claude mcp add` rechaza con error la creación de un servidor con nombre reservado [M2-C012: https://code.claude.com/docs/en/mcp.md]

## Integración con Hooks: eventos, handlers y seguridad

- Claude Code expone 31 eventos de hook que cubren todo el ciclo de vida de una sesión [M2-C016: https://code.claude.com/docs/en/hooks.md]
- De los 31 eventos, 14 pueden bloquear la acción que los disparó [M2-C016: https://code.claude.com/docs/en/hooks.md]
- Los otros 17 eventos son de observación pura y no pueden impedir la acción [M2-C016: https://code.claude.com/docs/en/hooks.md]
- Los 14 eventos bloqueantes son: `UserPromptSubmit`, `UserPromptExpansion`, `PreToolUse`, `PostToolBatch`, `SubagentStop`, `TaskCreated`, `TaskCompleted`, `Stop`, `TeammateIdle`, `ConfigChange`, `WorktreeCreate`, `PreCompact`, `Elicitation` y `ElicitationResult` [M2-C016: https://code.claude.com/docs/en/hooks.md]
- Un hook no está limitado a comandos de shell; existen 5 tipos de handler [M2-C017: https://code.claude.com/docs/en/hooks.md]
- Handler `command`: ejecuta un comando de shell y recibe JSON por stdin [M2-C017: https://code.claude.com/docs/en/hooks.md]
- Handler `http`: realiza una petición POST a una URL [M2-C017: https://code.claude.com/docs/en/hooks.md]
- Handler `mcp_tool`: llama a una herramienta expuesta por un servidor MCP [M2-C017: https://code.claude.com/docs/en/hooks.md]
- Handler `prompt`: realiza una evaluación de un turno con un LLM [M2-C017: https://code.claude.com/docs/en/hooks.md]
- Handler `agent`: verificación experimental basada en subagente [M2-C017: https://code.claude.com/docs/en/hooks.md]
- El contrato de salida de un hook se basa en el código de salida del proceso [M2-C018: https://code.claude.com/docs/en/hooks.md]
- Código de salida `0` significa éxito; Claude Code lee JSON de stdout y envía cualquier texto plano al log de debug [M2-C018: https://code.claude.com/docs/en/hooks.md]
- Código de salida `2` significa error bloqueante que impide la acción, pero solo en los eventos que soportan bloqueo [M2-C018: https://code.claude.com/docs/en/hooks.md]
- Cualquier código de salida distinto de `0` y `2` se interpreta como error no bloqueante y la acción procede igual [M2-C018: https://code.claude.com/docs/en/hooks.md]
- El JSON de salida de un hook admite los campos: `continue`, `stopReason`, `systemMessage`, `terminalSequence`, `decision`, `reason` y `hookSpecificOutput` [M2-C018: https://code.claude.com/docs/en/hooks.md]
- Los hooks tienen controles de seguridad configurables a nivel de organización [M2-C019: https://code.claude.com/docs/en/hooks.md]
- El control `allowManagedHooksOnly` bloquea los hooks definidos en ámbito de usuario, proyecto, local y plugin, dejando operativos únicamente los hooks gestionados por la organización [M2-C019: https://code.claude.com/docs/en/hooks.md]
- El control `allowedHttpHookUrls` restringe las URLs a las que pueden apuntar los hooks de tipo HTTP [M2-C019: https://code.claude.com/docs/en/hooks.md]
- El control `httpHookAllowedEnvVars` limita qué variables de entorno se pueden interpolar en las cabeceras de los hooks HTTP [M2-C019: https://code.claude.com/docs/en/hooks.md]
- Los hooks gestionados no pueden ser deshabilitados ni sobreescritos por configuraciones no gestionadas [M2-C019: https://code.claude.com/docs/en/hooks.md]

**Si te llevas UNA cosa:** Las skills operan bajo un modelo de progressive disclosure de tres niveles que mantiene el costo de contexto casi nulo hasta su uso real: solo ~100 tokens de metadata por skill al arranque, menos de 5.000 tokens al invocarse, y cero costo por recursos/scripts hasta su ejecución, lo que las convierte en la unidad de extensión preferida sobre CLAUDE.md para cualquier procedimiento no trivial.
