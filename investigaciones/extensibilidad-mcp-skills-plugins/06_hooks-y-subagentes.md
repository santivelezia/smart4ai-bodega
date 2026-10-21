> **Publicada por Smart4AI · fecha de corte 2026-08-17 · licencia CC BY-NC 4.0** (puedes usarla y adaptarla sin fines comerciales, dando crédito a Smart4AI).
> Parte de: Universo Claude 2026 · Módulo 2: extensibilidad (MCP, skills, plugins, hooks y subagentes). Las etiquetas entre corchetes (por ejemplo `[M2-C001: url]`) son la fuente de cada dato. Precios, límites y conteos cambian: verifícalos en la fuente oficial antes de usarlos.

## Hooks: 31 eventos del ciclo de vida y capacidad de bloqueo

- Claude Code expone 31 eventos de hook que cubren todo el ciclo de vida de una sesión [F1: https://code.claude.com/docs/en/hooks.md]
- 14 eventos pueden BLOQUEAR la acción: `UserPromptSubmit`, `UserPromptExpansion`, `PreToolUse`, `PostToolBatch`, `SubagentStop`, `TaskCreated`, `TaskCompleted`, `Stop`, `TeammateIdle`, `ConfigChange`, `WorktreeCreate`, `PreCompact`, `Elicitation`, `ElicitationResult` [F1: https://code.claude.com/docs/en/hooks.md]
- Los 17 eventos restantes son puramente de observación y no pueden impedir la acción que los disparó [F1: https://code.claude.com/docs/en/hooks.md]

## Cinco tipos de handler y contrato de entrada/salida

- Un hook no es necesariamente un comando de shell: existen 5 tipos de handler [F1: https://code.claude.com/docs/en/hooks.md]
- `command`: ejecuta un comando del sistema y recibe JSON por stdin [F1: https://code.claude.com/docs/en/hooks.md]
- `http`: realiza un POST a una URL externa [F1: https://code.claude.com/docs/en/hooks.md]
- `mcp_tool`: invoca una herramienta expuesta por un servidor MCP [F1: https://code.claude.com/docs/en/hooks.md]
- `prompt`: ejecuta la evaluación de un turno mediante un LLM [F1: https://code.claude.com/docs/en/hooks.md]
- `agent`: verificación experimental basada en subagente [F1: https://code.claude.com/docs/en/hooks.md]
- El contrato de salida se basa en el código de salida del proceso: `0` es éxito; Claude Code lee JSON de stdout y envía el texto plano al log de debug [F1: https://code.claude.com/docs/en/hooks.md]
- Código `2` es error bloqueante que impide la acción, pero solo en los eventos que soportan bloqueo [F1: https://code.claude.com/docs/en/hooks.md]
- Cualquier otro código distinto de `0` y `2` es error no bloqueante: la acción original procede igual [F1: https://code.claude.com/docs/en/hooks.md]
- El JSON de salida admite los campos: `continue`, `stopReason`, `systemMessage`, `terminalSequence`, `decision`, `reason`, `hookSpecificOutput` [F1: https://code.claude.com/docs/en/hooks.md]

## Alcance y configuración de hooks (6 niveles)

- Los hooks se configuran en 6 lugares con alcance progresivamente más específico [F1: https://code.claude.com/docs/en/hooks.md]
- `~/.claude/settings.json`: alcance usuario, válido solo en sesiones locales [F1: https://code.claude.com/docs/en/hooks.md]
- `.claude/settings.json`: alcance proyecto, compartible con el equipo via repositorio [F1: https://code.claude.com/docs/en/hooks.md]
- `.claude/settings.local.json`: alcance proyecto pero local y gitignored [F1: https://code.claude.com/docs/en/hooks.md]
- Managed policy settings: alcance organización completa [F1: https://code.claude.com/docs/en/hooks.md]
- `hooks/hooks.json` dentro de un plugin [F1: https://code.claude.com/docs/en/hooks.md]
- Frontmatter de una skill o de un subagente [F1: https://code.claude.com/docs/en/hooks.md]

## Subagentes: aislamiento de contexto y modelo de delegación

- Un subagente es un asistente especializado que corre en su PROPIA ventana de contexto aislada, con system prompt, acceso a herramientas y permisos propios [F2: https://code.claude.com/docs/en/sub-agents.md]
- Su valor principal es preservar el contexto de la conversación principal manteniendo separadas la exploración y la implementación [F2: https://code.claude.com/docs/en/sub-agents.md]
- NO hereda el historial de conversación de la sesión principal, ni el output style, ni la auto memory, ni el tamaño de la ventana de contexto (usa el de su propio modelo) [F2: https://code.claude.com/docs/en/sub-agents.md]
- SÍ carga: su propio system prompt, el mensaje de delegación, los `CLAUDE.md` de la jerarquía, un snapshot de `git status` y las skills precargadas [F2: https://code.claude.com/docs/en/sub-agents.md]
- La única excepción de herencia son los forks, que sí heredan la conversación entera [F2: https://code.claude.com/docs/en/sub-agents.md]

## Cuatro subagentes integrados y sus perfiles

- Claude Code trae 4 subagentes built-in con perfiles predefinidos [F2: https://code.claude.com/docs/en/sub-agents.md]
- `Explore`: solo lectura, búsqueda rápida en el código, se salta `CLAUDE.md` y `git status` [F2: https://code.claude.com/docs/en/sub-agents.md]
- `Plan`: solo lectura, investigación para plan mode, con las mismas exclusiones que Explore [F2: https://code.claude.com/docs/en/sub-agents.md]
- `General-purpose`: acceso a todas las herramientas, diseñado para tareas multi-paso [F2: https://code.claude.com/docs/en/sub-agents.md]
- `claude`: catch-all genérico [F2: https://code.claude.com/docs/en/sub-agents.md]
- Explore topa su modelo heredado en Opus cuando corre sobre la Claude API [F2: https://code.claude.com/docs/en/sub-agents.md]

## Frontmatter de subagentes: campos obligatorios y opcionales

- El frontmatter de un subagente declara `name` y `description` como obligatorios [F2: https://code.claude.com/docs/en/sub-agents.md]
- Opcionales disponibles: `tools`, `disallowedTools`, `model`, `permissionMode`, `maxTurns`, `skills`, `mcpServers`, `hooks`, `memory`, `background`, `effort`, `isolation`, `color`, `initialPrompt` [F2: https://code.claude.com/docs/en/sub-agents.md]
- `isolation` con valor `worktree` otorga al subagente un git worktree aislado del principal [F2: https://code.claude.com/docs/en/sub-agents.md]
- `memory` con valores `user`, `project` o `local` habilita memoria persistente para el subagente [F2: https://code.claude.com/docs/en/sub-agents.md]

## Límites operativos, retención y optimización de costo

- Tres límites operativos con valores por defecto rigen la ejecución de subagentes [F2: https://code.claude.com/docs/en/sub-agents.md]
- Profundidad de anidamiento máxima: 3 capas, controlada por `CLAUDE_CODE_MAX_SUBAGENT_SPAWN_DEPTH` [F2: https://code.claude.com/docs/en/sub-agents.md]
- Concurrencia máxima: 20 subagentes simultáneos via `CLAUDE_CODE_MAX_CONCURRENT_SUBAGENTS` [F2: https://code.claude.com/docs/en/sub-agents.md]
- Retención de transcript: 30 días [F2: https://code.claude.com/docs/en/sub-agents.md]
- En costo, arrancan en frío sin reutilizar contexto, excepto los forks que pueden aprovechar prompt cache [F2: https://code.claude.com/docs/en/sub-agents.md]
- Cada subagente consume tokens de su propia ventana de contexto; la palanca directa para abaratarlos es especificar `model: haiku` [F2: https://code.claude.com/docs/en/sub-agents.md]

## Filtrado de herramientas y control de delegación entre subagentes

- Ciertas herramientas de la sesión principal se filtran siempre para los subagentes [F2: https://code.claude.com/docs/en/sub-agents.md]
- Filtrado fijo: `Agent` (cuando se alcanza el límite de profundidad), `AskUserQuestion`, `EndConversation`, `EnterPlanMode`, `ExitPlanMode` (salvo que `permissionMode` sea `plan`), `ScheduleWakeup`, `TaskOutput`, `WaitForMcpServers`, `Workflow` [F2: https://code.claude.com/docs/en/sub-agents.md]
- Se puede restringir qué subagentes puede lanzar uno dado con la sintaxis `tools: Agent(worker, researcher)` [F2: https://code.claude.com/docs/en/sub-agents.md]

## Interoperabilidad con Skills, MCP y gestión de contexto

- Las skills se definen en un directorio cuyo punto de entrada obligatorio es `SKILL.md`, con frontmatter YAML entre `---` y cuerpo markdown; el nombre del directorio se convierte en comando y `description` activa la carga automática cuando es relevante [F3: https://code.claude.com/docs/en/skills.md]
- Ventaja clave sobre `CLAUDE.md`: el cuerpo de la skill se carga SOLO cuando se usa, por lo que material de referencia largo carga casi 0 tokens hasta su invocación [F3: https://code.claude.com/docs/en/skills.md]
- Ubicaciones: `~/.claude/skills/<nombre>/` (personal, todos los proyectos), `.claude/skills/<nombre>/` (proyecto), `<plugin>/skills/<nombre>/` (plugin); en colisión gana la personal [F3: https://code.claude.com/docs/en/skills.md]
- Una skill que existe SOLO en `~/.claude/skills/` de la máquina local NO está disponible cuando una routine la invoca, porque cada corrida de routine arranca como sesión remota nueva; para cloud hay que commitearla al repo o distribuirla en un plugin declarado en `.claude/settings.json` [F3: https://code.claude.com/docs/en/skills.md]
- Los servidores MCP de alcance project se declaran en `.mcp.json` en la raíz, son versionables y compartibles; requieren aprobación interactiva (estado `Pending approval`) hasta ser aprobados en una sesión interactiva [F4: https://code.claude.com/docs/en/mcp.md]
- Timeout por servidor: agregar el campo `timeout` en milisegundos a la entrada del servidor en `.mcp.json` (ej. `600000` para 10 minutos); ese valor sobrescribe la variable de entorno `MCP_TOOL_TIMEOUT` únicamente para ese servidor [F4: https://code.claude.com/docs/en/mcp.md]
- En configuración MCP, `type` acepta `streamable-http` como alias de `http`; una entrada con `url` pero sin `type` es error de configuración: Claude Code la interpreta como servidor stdio, la omite y solicita agregar `type: http`, `sse` o `ws` [F4: https://code.claude.com/docs/en/mcp.md]
- 5 nombres de servidor están reservados para los integrados de Claude Code: `workspace`, `claude-in-chrome`, `computer-use`, `Claude Preview`, `Claude Browser`; si una configuración los define, Claude Code los omite y pide renombrarlos; `claude mcp add` los rechaza con error [F4: https://code.claude.com/docs/en/mcp.md]
- Con tool search activo (default), las definiciones completas de herramientas MCP no entran al contexto: solo ingresan los nombres y el esquema se carga bajo demanda cuando Claude va a usar una herramienta específica [F4: https://code.claude.com/docs/en/mcp.md]
- Tool search se desactiva cuando hay un `ANTHROPIC_BASE_URL` custom, cuando `ENABLE_TOOL_SEARCH` es `false`, o con modelos anteriores a la generación 4.5 en Google Cloud [F4: https://code.claude.com/docs/en/mcp.md]

**Si te llevas UNA cosa:** Los 14 hooks bloqueantes te permiten interceptar y detener acciones críticas del ciclo de vida (como el uso de herramientas o la creación de tareas) devolviendo código de salida `2`, mientras que los subagentes te permiten delegar trabajo aislado sin contaminar el contexto principal, pero cada uno consume su propia ventana de tokens y está limitado a 3 niveles de anidamiento y 20 concurrentes, por lo que la combinación de hooks bloqueantes + subagentes especializados con `model: haiku` es el patrón más potente y económico para automatizar flujos complejos bajo supervisión programática.
