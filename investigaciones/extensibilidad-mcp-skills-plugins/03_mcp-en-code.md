> **Publicada por Smart4AI · fecha de corte 2026-08-17 · licencia CC BY-NC 4.0** (puedes usarla y adaptarla sin fines comerciales, dando crédito a Smart4AI).
> Parte de: Universo Claude 2026 · Módulo 2: extensibilidad (MCP, skills, plugins, hooks y subagentes). Las etiquetas entre corchetes (por ejemplo `[M2-C001: url]`) son la fuente de cada dato. Precios, límites y conteos cambian: verifícalos en la fuente oficial antes de usarlos.

## Alcances y archivos de configuración MCP

- Los servidores MCP de alcance `project` se declaran en el archivo `.mcp.json` ubicado en la raíz del repositorio. [M2-C008: https://code.claude.com/docs/en/mcp.md]
- Este archivo es versionable y comparte la configuración con todo el equipo. [M2-C008: https://code.claude.com/docs/en/mcp.md]
- El alcance se elige con el flag `-s` o `--scope` al momento de agregar el servidor. [M2-C008: https://code.claude.com/docs/en/mcp.md]
- Los servidores de alcance `project` quedan en estado `Pending approval` hasta que un usuario los aprueba en una sesión interactiva. [M2-C008: https://code.claude.com/docs/en/mcp.md]
- En estado pendiente aparecen listados en los comandos `claude mcp list` y `claude mcp get`. [M2-C008: https://code.claude.com/docs/en/mcp.md]
- En la configuración JSON de servidores MCP —ya sea `.mcp.json`, `~/.claude.json` o vía `claude mcp add-json`— el campo `type` acepta `streamable-http` como alias de `http`. [M2-C009: https://code.claude.com/docs/en/mcp.md]
- Este alias permite copiar configuraciones directamente desde la documentación de un servidor sin modificarlas. [M2-C009: https://code.claude.com/docs/en/mcp.md]
- Una entrada que incluye `url` pero omite el campo `type` es un error de configuración. [M2-C009: https://code.claude.com/docs/en/mcp.md]
- Ante esa omisión, Claude Code interpreta erróneamente el servidor como `stdio`, lo omite del cargado y reporta el problema solicitando agregar `type http`, `sse` o `ws`. [M2-C009: https://code.claude.com/docs/en/mcp.md]

## Transportes, validación y nombres reservados

- Tool search está activo por defecto; en este modo las definiciones completas de las herramientas MCP no entran al contexto, sino solo sus nombres. [M2-C011: https://code.claude.com/docs/en/mcp.md]
- El esquema completo de una herramienta se carga dinámicamente únicamente cuando Claude va a usar esa herramienta específica. [M2-C011: https://code.claude.com/docs/en/mcp.md]
- Tool search se desactiva automáticamente cuando existe una variable `ANTHROPIC_BASE_URL` custom. [M2-C011: https://code.claude.com/docs/en/mcp.md]
- También se desactiva cuando la variable de entorno `ENABLE_TOOL_SEARCH` se establece en `false`. [M2-C011: https://code.claude.com/docs/en/mcp.md]
- Además se desactiva al usar modelos anteriores a la generación 4.5 en Google Cloud. [M2-C011: https://code.claude.com/docs/en/mcp.md]
- Existen 5 nombres de servidor reservados para los servidores integrados de Claude Code: `workspace`, `claude-in-chrome`, `computer-use`, `Claude Preview` y `Claude Browser`. [M2-C012: https://code.claude.com/docs/en/mcp.md]
- Si una configuración define un servidor con nombre reservado, Claude Code lo omite al cargar y muestra un aviso pidiendo renombrarlo. [M2-C012: https://code.claude.com/docs/en/mcp.md]
- El comando `claude mcp add` rechaza explícitamente con error cualquier intento de usar un nombre reservado. [M2-C012: https://code.claude.com/docs/en/mcp.md]

## Directorio de conectores revisados

- El Anthropic Directory disponible en `claude.ai/directory` lista conectores revisados por Anthropic. [M2-C013: https://code.claude.com/docs/en/mcp.md]
- Esos conectores usan la misma infraestructura MCP que Claude Code. [M2-C013: https://code.claude.com/docs/en/mcp.md]
- Cualquier servidor remoto listado en ese directorio se puede agregar localmente con el comando `claude mcp add`. [M2-C013: https://code.claude.com/docs/en/mcp.md]

## Estructura y alcance de Agent Skills

- Una Agent Skill es un directorio cuyo punto de entrada obligatorio es un archivo `SKILL.md`. [M2-C001: https://code.claude.com/docs/en/skills.md]
- El archivo contiene dos partes: frontmatter YAML entre marcadores `---` que le indica a Claude cuándo usar la skill, y contenido markdown con las instrucciones propiamente dichas. [M2-C001: https://code.claude.com/docs/en/skills.md]
- El nombre del directorio se convierte en el comando que el usuario escribe para invocarla. [M2-C001: https://code.claude.com/docs/en/skills.md]
- El campo `description` del frontmatter es el que hace que Claude cargue automáticamente la skill cuando detecta que es relevante para la tarea. [M2-C001: https://code.claude.com/docs/en/skills.md]
- La ventaja clave de contexto sobre `CLAUDE.md` es que el cuerpo de la skill se carga SOLO cuando se usa. [M2-C002: https://code.claude.com/docs/en/skills.md]
- Por esa carga diferida, material de referencia largo cuesta prácticamente nada en tokens de contexto hasta que se necesita. [M2-C002: https://code.claude.com/docs/en/skills.md]
- La recomendación oficial es crear una skill cuando una sección de `CLAUDE.md` dejó de ser un hecho puntual y se convirtió en un procedimiento operativo. [M2-C002: https://code.claude.com/docs/en/skills.md]
- Las skills personales viven en `~/.claude/skills/<nombre>/SKILL.md` y aplican a todos los proyectos del usuario. [M2-C003: https://code.claude.com/docs/en/skills.md]
- Las skills de proyecto viven en `.claude/skills/<nombre>/SKILL.md` y aplican únicamente a ese repositorio. [M2-C003: https://code.claude.com/docs/en/skills.md]
- Las skills de plugin viven en `<plugin>/skills/<nombre>/SKILL.md` y están disponibles donde el plugin esté habilitado. [M2-C003: https://code.claude.com/docs/en/skills.md]
- Cuando una misma skill existe en la ubicación personal y en la de proyecto, se ejecuta la personal por prioridad. [M2-C003: https://code.claude.com/docs/en/skills.md]
- Una skill que existe SOLO en `~/.claude/skills/` de la máquina local NO está disponible cuando una routine la invoca. [M2-C007: https://code.claude.com/docs/en/skills.md]
- Esto ocurre porque cada corrida de routine arranca como una sesión remota nueva sin acceso al filesystem local del usuario. [M2-C007: https://code.claude.com/docs/en/skills.md]
- Para sesiones en la nube hay que commitear la skill al directorio `.claude/skills/` del repositorio, o distribuirla dentro de un plugin declarado en el `.claude/settings.json` del repo. [M2-C007: https://code.claude.com/docs/en/skills.md]

## Skills en la Claude API y repositorio open-source

- Usar Skills desde la Claude API exige la herramienta de code execution, ya que las skills corren dentro de su contenedor. [M2-C036: https://platform.claude.com/docs/en/agents-and-tools/agent-skills/overview.md]
- Se requiere el beta header `skills-2025-10-02`. [M2-C036: https://platform.claude.com/docs/en/agents-and-tools/agent-skills/overview.md]
- Las skills se referencian por `skill_id` dentro del parámetro `container`. [M2-C036: https://platform.claude.com/docs/en/agents-and-tools/agent-skills/overview.md]
- Las skills personalizadas se suben mediante los endpoints `/v1/skills`. [M2-C036: https://platform.claude.com/docs/en/agents-and-tools/agent-skills/overview.md]
- Una vez subidas, quedan compartidas a nivel de workspace. [M2-C036: https://platform.claude.com/docs/en/agents-and-tools/agent-skills/overview.md]
- Si además se suben o descargan archivos asociados a la skill, hace falta el header adicional `files-api-2025-04-14`. [M2-C036: https://platform.claude.com/docs/en/agents-and-tools/agent-skills/overview.md]
- Anthropic publica skills open-source en el repositorio `github.com/anthropics/skills`. [M2-C042: https://platform.claude.com/docs/en/agents-and-tools/agent-skills/overview.md]
- La skill destacada es la Claude API skill, que provee material de referencia actualizado de la API, documentación de SDK y buenas prácticas para 8 lenguajes de programación. [M2-C042: https://platform.claude.com/docs/en/agents-and-tools/agent-skills/overview.md]
- Viene incluida con Claude Code y también se puede instalar manualmente desde el repositorio. [M2-C042: https://platform.claude.com/docs/en/agents-and-tools/agent-skills/overview.md]

## Catálogo de plugins del marketplace oficial

- El marketplace oficial incluye plugins de integración externa con servidores MCP preconfigurados. [M2-C049: https://code.claude.com/docs/en/discover-plugins.md]
- Los agrupa por categorías funcionales: control de versiones, gestión de proyectos, diseño, infraestructura, comunicación y monitoreo. [M2-C049: https://code.claude.com/docs/en/discover-plugins.md]
- Control de versiones: GitHub y GitLab. [M2-C049: https://code.claude.com/docs/en/discover-plugins.md]
- Gestión de proyectos: Atlassian para Jira y Confluence, Asana, Linear, Notion. [M2-C049: https://code.claude.com/docs/en/discover-plugins.md]
- Diseño: Figma. [M2-C049: https://code.claude.com/docs/en/discover-plugins.md]
- Infraestructura: Vercel, Firebase, Supabase. [M2-C049: https://code.claude.com/docs/en/discover-plugins.md]
- Comunicación: Slack. [M2-C049: https://code.claude.com/docs/en/discover-plugins.md]
- Monitoreo: Sentry. [M2-C049: https://code.claude.com/docs/en/discover-plugins.md]
- El marketplace trae 11 plugins de code intelligence que habilitan la herramienta LSP integrada de Claude Code. [M2-C050: https://code.claude.com/docs/en/discover-plugins.md]
- Estos plugins proporcionan navegación de código y diagnósticos automáticos tras cada edición. [M2-C050: https://code.claude.com/docs/en/discover-plugins.md]
- La lista completa es: `clangd-lsp` (C/C++), `csharp-lsp`, `gopls-lsp`, `jdtls-lsp` (Java), `kotlin-lsp`, `lua-lsp`, `php-lsp`, `pyright-lsp` (Python), `rust-analyzer-lsp`, `swift-lsp` y `typescript-lsp`. [M2-C050: https://code.claude.com/docs/en/discover-plugins.md]
- El plugin NO instala el binario del language server; es responsabilidad del usuario tenerlo disponible aparte en el sistema. [M2-C050: https://code.claude.com/docs/en/discover-plugins.md]

## Instalación de plugins y fuentes de marketplaces

- Un plugin se instala con el comando `/plugin install nombre@marketplace`. [M2-C054: https://code.claude.com/docs/en/discover-plugins.md]
- Admite tres alcances de instalación: `user`, `project` y `local`. [M2-C054: https://code.claude.com/docs/en/discover-plugins.md]
- Alcance `user`: disponible para el usuario en todos sus proyectos. [M2-C054: https://code.claude.com/docs/en/discover-plugins.md]
- Alcance `project`: disponible para todos los colaboradores del repositorio y se persiste en el archivo `.claude/settings.json`. [M2-C054: https://code.claude.com/docs/en/discover-plugins.md]
- Alcance `local`: disponible solo para el usuario en ese repositorio específico y no se comparte con el resto del equipo. [M2-C054: https://code.claude.com/docs/en/discover-plugins.md]
- Existe además un alcance `managed`, instalado por administradores vía managed settings, que el usuario final no puede modificar. [M2-C054: https://code.claude.com/docs/en/discover-plugins.md]
- Los marketplaces de plugins se pueden agregar desde cuatro tipos de fuente distintas. [M2-C056: https://code.claude.com/docs/en/discover-plugins.md]
- Primera fuente: repositorios de GitHub en formato `owner/repo`. [M2-C056: https://code.claude.com/docs/en/discover-plugins.md]
- Segunda fuente: URLs de git de cualquier host, incluyendo GitLab, Bitbucket y servidores propios, usando prefijo `https` y sufijo `.git`. [M2-C056: https://code.claude.com/docs/en/discover-plugins.md]
- Tercera fuente: rutas locales a un directorio, o directamente a un archivo `marketplace.json`. [M2-C056: https://code.claude.com/docs/en/discover-plugins.md]
- Cuarta fuente: URLs remotas a un archivo `marketplace.json` hospedado en cualquier servidor web. [M2-C056: https://code.claude.com/docs/en/discover-plugins.md]
- Se puede fijar una rama o tag específico agregando `#` y la referencia al final de la URL o ruta. [M2-C056: https://code.claude.com/docs/en/discover-plugins.md]

## Políticas de equipo y auto-instalación

- Para equipos, un administrador puede declarar marketplaces en el archivo `.claude/settings.json` del proyecto usando el campo `extraKnownMarketplaces`. [M2-C061: https://code.claude.com/docs/en/discover-plugins.md]
- Claude Code agrega esos marketplaces sin pedir permiso adicional una vez que el miembro confía en la carpeta del repositorio. [M2-C061: https://code.claude.com/docs/en/discover-plugins.md]
- A partir de la versión 2.1.195, agregar el marketplace NO instala automáticamente los plugins de fuente externa. [M2-C061: https://code.claude.com/docs/en/discover-plugins.md]
- Cada miembro debe instalar manualmente los plugins que desee utilizar. [M2-C061: https://code.claude.com/docs/en/discover-plugins.md]
- Hasta que el miembro los instale, Claude Code los reporta como no instalados y muestra el comando específico que debe ejecutar para instalarlos. [M2-C061: https://code.claude.com/docs/en/discover-plugins.md]

## Impacto en tokens y prompt cache

- Habilitar o deshabilitar un plugin tiene un costo de tokens medible en la siguiente petición al modelo. [M2-C062: https://code.claude.com/docs/en/discover-plugins.md]
- Este costo ocurre porque los componentes recién cargados se anuncian como contenido agregado a la conversación activa. [M2-C062: https://code.claude.com/docs/en/discover-plugins.md]
- El caso de mayor costo es un plugin que aporta servidores MCP cuyas herramientas NO están diferidas por tool search. [M2-C062: https://code.claude.com/docs/en/discover-plugins.md]
- En ese escenario, el cambio de estado invalida el prompt cache. [M2-C062: https://code.claude.com/docs/en/discover-plugins.md]
- Como consecuencia, la siguiente petición re-lee la conversación entera desde el inicio en lugar de aprovechar cacheo parcial. [M2-C062: https://code.claude.com/docs/en/discover-plugins.md]

## Hooks del ciclo de vida

- Claude Code expone 31 eventos de hook que cubren todo el ciclo de vida de una sesión. [M2-C016: https://code.claude.com/docs/en/hooks.md]
- De esos 31 eventos, 14 tienen capacidad de bloqueo: pueden impedir que la acción asociada se ejecute. [M2-C016: https://code.claude.com/docs/en/hooks.md]
- Los 14 hooks bloqueantes son: `UserPromptSubmit`, `UserPromptExpansion`, `PreToolUse`, `PostToolBatch`, `SubagentStop`, `TaskCreated`, `TaskCompleted`, `Stop`, `TeammateIdle`, `ConfigChange`, `WorktreeCreate`, `PreCompact`, `Elicitation` y `ElicitationResult`. [M2-C016: https://code.claude.com/docs/en/hooks.md]
- Los 17 eventos restantes son puramente de observación y no pueden impedir la acción que están monitorizando. [M2-C016: https://code.claude.com/docs/en/hooks.md]

**Si te llevas UNA cosa:** La interacción entre plugins de alcance `project`, servidores MCP sin tool search diferido y la invalidación del prompt cache genera un costo de tokens que afecta a todo el equipo, por lo que la decisión de qué plugins versionar en `.claude/settings.json` versus dejar en alcance `local` tiene un impacto directo y medible en el rendimiento y costo de cada sesión de Claude Code. [M2-C062: https://code.claude.com/docs/en/discover-plugins.md] [M2-C011: https://code.claude.com/docs/en/mcp.md] [M2-C054: https://code.claude.com/docs/en/discover-plugins.md]
