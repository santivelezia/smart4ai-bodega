> **Publicada por Smart4AI · fecha de corte 2026-08-17 · licencia CC BY-NC 4.0** (puedes usarla y adaptarla sin fines comerciales, dando crédito a Smart4AI).
> Parte de: Universo Claude 2026 · Módulo 2: extensibilidad (MCP, skills, plugins, hooks y subagentes). Las etiquetas entre corchetes (por ejemplo `[M2-C001: url]`) son la fuente de cada dato. Precios, límites y conteos cambian: verifícalos en la fuente oficial antes de usarlos.

## Modelo de confianza y entornos de ejecución por superficie

- **Skills en Claude API**: entorno de ejecución en contenedor aislado
  - Sin acceso a red
  - Sin instalación de paquetes en runtime
  - Decision de seguridad que limita el radio de accion del codigo de terceros
  - [M2-C035]

- **Skills en Claude Code**: entorno nativo en el computador del usuario
  - Acceso de red completo, equivalente a cualquier programa local
  - Mismo nivel de privilegios que el usuario que ejecuta Claude Code
  - Decision de seguridad que traslada la responsabilidad al entorno host
  - [M2-C035]

- **Skills en claude.ai**: entorno hibrido
  - Acceso a red varia segun configuracion de usuario o administrador
  - No hay garantia uniforme de aislamiento entre cuentas
  - [M2-C035]

- **Hooks y workspace trust**:
  - Los hooks definidos en configuracion de proyecto y los declarados en el frontmatter de skills o subagentes requieren que la carpeta este marcada como confiable
  - El modo no interactivo con el flag `-p` NO cuenta como aceptacion de esa confianza
  - Esto impide que un repositorio ajeno ejecute hooks al abrirse en modo automatizado
  - [M2-C020]

- **Plugins y privilegios nativos**:
  - Plugins y marketplaces son componentes altamente confiables que ejecutan codigo arbitrario con privilegios de usuario
  - Anthropic no controla que servidores MCP, archivos u otro software incluye un plugin
  - Anthropic no puede verificar que funcionen como se declara
  - Las organizaciones pueden restringir que marketplaces se permiten con `managed marketplace restrictions`
  - [M2-C051]

- **MCP project scope y aprobacion interactiva**:
  - Los servidores MCP de alcance `project` se comparten con todo el equipo mediante `.mcp.json` en la raiz del proyecto
  - Son versionables via control de versiones
  - El alcance se elige con el flag `-s` o `--scope` al agregar el servidor
  - Aparecen en `claude mcp list` y `claude mcp get` como `Pending approval` hasta que un usuario los aprueba en sesion interactiva
  - [M2-C008]

- **Nombres reservados en Claude Code**:
  - Cinco nombres de servidor estan reservados para los servidores integrados: `workspace`, `claude-in-chrome`, `computer-use`, `Claude Preview` y `Claude Browser`
  - Si una configuracion define un servidor con nombre reservado, Claude Code lo omite al cargar y muestra un aviso pidiendo renombrarlo
  - El comando `claude mcp add` rechaza la operacion con error
  - [M2-C012]

## Controles de organizacion y gobernanza de hooks

- **Jerarquia de control: hooks gestionados vs no gestionados**:
  - `allowManagedHooksOnly`: bloquea los hooks de usuario, proyecto, local y plugin, dejando operativos solo los gestionados por la organizacion
  - Los hooks gestionados no pueden ser deshabilitados por configuraciones no gestionadas
  - [M2-C019]

- **Restriccion de destinos HTTP**:
  - `allowedHttpHookUrls`: restringe a que URLs pueden apuntar los hooks de tipo HTTP
  - `httpHookAllowedEnvVars`: limita que variables de entorno se pueden interpolar en las cabeceras de las peticiones
  - Reduce la superficie de exfiltracion si un hook malicioso intenta enviar datos a endpoints externos
  - [M2-C019]

- **Cobertura del ciclo de vida: 31 eventos de hook**:
  - Claude Code expone 31 eventos de hook que cubren todo el ciclo de vida de una sesion
  - 14 eventos pueden BLOQUEAR la accion: `UserPromptSubmit`, `UserPromptExpansion`, `PreToolUse`, `PostToolBatch`, `SubagentStop`, `TaskCreated`, `TaskCompleted`, `Stop`, `TeammateIdle`, `ConfigChange`, `WorktreeCreate`, `PreCompact`, `Elicitation` y `ElicitationResult`
  - Los otros 17 son de observacion y no pueden impedir la accion
  - [M2-C016]

- **Cinco tipos de handler para hooks**:
  - `command`: ejecuta un comando de shell y recibe JSON por stdin
  - `http`: realiza POST a una URL configurada
  - `mcp_tool`: llama a una herramienta de un servidor MCP
  - `prompt`: hace una evaluacion de un turno con un LLM
  - `agent`: verificacion experimental basada en subagente
  - [M2-C017]

## Auditoria de extensiones de terceros: skills y plugins

- **Postura oficial de seguridad sobre Skills**:
  - Recomendacion explicita: usar SOLO skills de fuentes confiables, propias o de Anthropic
  - El riesgo concreto es que una skill maliciosa dirija a Claude a invocar herramientas o ejecutar codigo de formas que no correspondan con su proposito declarado
  - Consecuencias posibles: exfiltracion de datos o acceso no autorizado
  - La recomendacion oficial es tratarlas como instalar software
  - [M2-C033]

- **Checklist de auditoria para skills de terceros**:
  - Revisar TODOS los archivos que empaqueta: `SKILL.md`, scripts, imagenes y otros recursos
  - Buscar patrones inusuales: llamadas de red inesperadas o accesos a archivos que no correspondan al proposito declarado
  - Las skills que traen datos desde URLs externas son de riesgo particular porque el contenido recuperado puede traer instrucciones maliciosas
  - Una skill confiable puede comprometerse si cambian sus dependencias externas
  - [M2-C034]

- **Estructura interna de una skill (punto de auditoria)**:
  - Punto de entrada obligatorio: archivo `SKILL.md`
  - Contiene frontmatter YAML entre marcadores `---` que le dice a Claude cuando usar la skill
  - El cuerpo markdown contiene las instrucciones ejecutadas
  - El nombre del directorio se convierte en el comando que se escribe
  - El campo `description` es lo que hace que Claude la cargue automaticamente cuando es relevante
  - [M2-C001]

- **Evaluacion previa de plugins: panel de detalles**:
  - Muestra estimacion de `Context cost`: cuantos tokens agregara al contexto en CADA turno
  - Muestra fecha de `Last updated`
  - Muestra seccion `Will install` que lista exactamente los comandos, agentes, skills, hooks y servidores MCP y LSP que aporta
  - Plugins de marketplaces locales o custom pueden no mostrar estos datos
  - [M2-C052]

## Costo de contexto y mecanicas de carga diferida

- **Tool search y contexto MCP**:
  - Con `tool search` activo, que es el default, las definiciones de herramientas MCP no entran al contexto
  - Solo entran los nombres de las herramientas; el esquema completo se carga cuando Claude va a usar una herramienta especifica
  - Reduce drasticamente el consumo de tokens de servidores MCP con muchas herramientas
  - [M2-C011]

- **Condiciones de desactivacion de tool search**:
  - Se desactiva cuando hay un `ANTHROPIC_BASE_URL` custom
  - Se desactiva cuando `ENABLE_TOOL_SEARCH` es `false`
  - Se desactiva con modelos anteriores a la generacion 4.5 en Google Cloud
  - En estos escenarios, las definiciones completas entran al contexto en cada turno
  - [M2-C011]

- **Ventaja de contexto de Skills sobre CLAUDE.md**:
  - El cuerpo de la skill se carga SOLO cuando se usa
  - Material de referencia largo cuesta practicamente nada hasta que se necesita
  - La recomendacion oficial es crear una skill cuando una seccion de `CLAUDE.md` dejo de ser un hecho y se convirtio en un procedimiento
  - [M2-C002]

- **Deteccion de plugins sin uso**:
  - Claude Code detecta plugins instalados pero no usados en al menos 2 semanas, dentro de un lapso de al menos 10 sesiones
  - Los agrupa bajo el encabezado `Not used recently` con una linea `Last used` por plugin
  - Proposito declarado: encontrar los que siguen sumando costo de arranque y de contexto sin aportar
  - [M2-C053]

- **Exenciones de la deteccion de uso**:
  - Quedan exentos los gestionados por la organizacion
  - Quedan exentos los cargados con `--plugin-dir`
  - Quedan exentos los que aportan tema, output style, monitor o workflow
  - [M2-C053]

## Interoperabilidad: MCP como estandar vs capa de producto Anthropic

- **MCP es un estandar abierto y portable**:
  - Visual Studio Code, Claude Code y Claude Desktop actuan como MCP hosts sobre el mismo protocolo
  - Un servidor MCP escrito una vez sirve a cualquiera de ellos sin modificaciones
  - [M2-C060]

- **Lo especifico de Anthropic es la capa de producto**:
  - Skills, plugins y hooks no son parte de la especificacion MCP
  - Son extensiones propietarias que envuelven el protocolo
  - Esto crea una division clara entre lo portable (el servidor MCP) y lo vendor-locked (la orquestacion de Anthropic)
  - [M2-C060]

- **Skills no se sincronizan entre superficies**:
  - Una skill subida a claude.ai no esta disponible en la API
  - Una skill subida por API no aparece en claude.ai
  - Las skills de Claude Code son basadas en filesystem y separadas de ambas
  - Hay que gestionarlas y subirlas por separado en cada superficie donde se quieran usar
  - [M2-C031]

- **Modelo de compartir skills por superficie**:
  - **claude.ai**: ~~individuales por usuario; cada miembro del equipo debe subirlas por separado; NO hay gestion centralizada ni distribucion a nivel de organizacion~~
  - 🔄 **CORRECCION 2026-08-25** (verificado contra documentacion oficial vigente): el claim anterior quedo desactualizado. Los owners de planes **Team y Enterprise SI pueden provisionar skills para toda la organizacion** desde *Organization settings → Skills* (claude.ai/admin-settings/skills); las skills provisionadas por el admin quedan **habilitadas por defecto para todos los usuarios** (en Team la funcion viene activada por defecto a nivel de organizacion; en Enterprise el owner debe verificar que Code execution/file creation y Skills esten activados). Los usuarios individuales siguen pudiendo subir las suyas en *Customize → Skills*. Fuentes: https://support.claude.com/en/articles/12512180-use-skills-in-claude · https://claude.com/blog/organization-skills-and-directory · https://platform.claude.com/docs/en/agents-and-tools/agent-skills/enterprise
  - **Claude API**: a nivel de workspace; todos los miembros del workspace acceden a las skills
  - **Claude Code**: personales o de proyecto; se pueden compartir via plugins
  - [M2-C032]

- **Ubicaciones de skills en Claude Code y prioridad**:
  - Personales: `~/.claude/skills/<nombre>/SKILL.md` (aplican a todos los proyectos del usuario)
  - De proyecto: `.claude/skills/<nombre>/SKILL.md` (solo ese proyecto)
  - De plugin: `<plugin>/skills/<nombre>/SKILL.md` (donde el plugin este habilitado)
  - Cuando una misma skill existe en ubicacion personal y de proyecto, se ejecuta la personal
  - [M2-C003]

- **Skills locales vs ejecucion en la nube**:
  - Una skill que existe SOLO en `~/.claude/skills/` de la maquina local NO esta disponible cuando una routine la invoca
  - Cada corrida de routine arranca como sesion remota nueva sin acceso al filesystem local
  - Para sesiones en la nube hay que commitear la skill al `.claude/skills/` del repositorio
  - Alternativa: distribuirla en un plugin declarado en el `.claude/settings.json` del repo
  - [M2-C007]

- **Configuracion MCP y alias de transporte**:
  - En la configuracion JSON de servidores (`.mcp.json`, `~/.claude.json` o via `claude mcp add-json`), el campo `type` acepta `streamable-http` como alias de `http`
  - Esto permite copiar configuraciones de la documentacion de un servidor sin modificarlas
  - Una entrada que trae `url` pero no trae `type` es error de configuracion: Claude Code la interpreta como servidor `stdio`, la omite y reporta el problema pidiendo agregar `type http`, `sse` o `ws`
  - [M2-C009]

## Retencion de datos y cumplimiento

- **Agent Skills y Zero Data Retention**:
  - Agent Skills NO esta cubierta por acuerdos de Zero Data Retention
  - Las definiciones de skill y los datos de su ejecucion se retienen segun la politica estandar de retencion de Anthropic
  - Es un costo de cumplimiento, no de tokens
  - Debe evaluarse antes de meter conocimiento sensible dentro de una skill
  - [M2-C041]

---

### Registro de fuentes

- [M2-C001]: https://code.claude.com/docs/en/skills.md
- [M2-C002]: https://code.claude.com/docs/en/skills.md
- [M2-C003]: https://code.claude.com/docs/en/skills.md
- [M2-C007]: https://code.claude.com/docs/en/skills.md
- [M2-C008]: https://code.claude.com/docs/en/mcp.md
- [M2-C009]: https://code.claude.com/docs/en/mcp.md
- [M2-C011]: https://code.claude.com/docs/en/mcp.md, https://code.claude.com/docs/en/costs.md
- [M2-C012]: https://code.claude.com/docs/en/mcp.md
- [M2-C016]: https://code.claude.com/docs/en/hooks.md
- [M2-C017]: https://code.claude.com/docs/en/hooks.md
- [M2-C019]: https://code.claude.com/docs/en/hooks.md
- [M2-C020]: https://code.claude.com/docs/en/hooks.md
- [M2-C031]: https://platform.claude.com/docs/en/agents-and-tools/agent-skills/overview.md
- [M2-C032]: https://platform.claude.com/docs/en/agents-and-tools/agent-skills/overview.md
- [M2-C033]: https://platform.claude.com/docs/en/agents-and-tools/agent-skills/overview.md
- [M2-C034]: https://platform.claude.com/docs/en/agents-and-tools/agent-skills/overview.md
- [M2-C035]: https://platform.claude.com/docs/en/agents-and-tools/agent-skills/overview.md
- [M2-C041]: https://platform.claude.com/docs/en/agents-and-tools/agent-skills/overview.md
- [M2-C051]: https://code.claude.com/docs/en/discover-plugins.md
- [M2-C052]: https://code.claude.com/docs/en/discover-plugins.md
- [M2-C053]: https://code.claude.com/docs/en/discover-plugins.md
- [M2-C060]: https://modelcontextprotocol.io/docs/learn/architecture

**Si te llevas UNA cosa:** La extensibilidad de Claude opera bajo un modelo de confianza profundamente fragmentado por superficie: MCP es el unico componente portable y estandar, mientras que skills, plugins y hooks son capas propietarias de Anthropic que cambian de comportamiento, alcance de sharing, sandboxing y retencion de datos dependiendo de si ejecutas en API (contenedor sin red), Claude Code (acceso nativo completo) o claude.ai (config variable); ademas, el costo de contexto solo se optimiza automaticamente si tool search esta activo, las skills cargan bajo demanda, y los plugins sin uso se detectan tras 2 semanas, pero ninguna de estas garantias aplica si instalas software de terceros sin pasar el checklist de auditoria manual que exige revisar cada archivo buscando exfiltracion por red o dependencias externas maliciosas.
