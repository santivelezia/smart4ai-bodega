> **Publicada por Smart4AI · fecha de corte 2026-08-17 · licencia CC BY-NC 4.0** (puedes usarla y adaptarla sin fines comerciales, dando crédito a Smart4AI).
> Parte de: Universo Claude 2026 · Módulo 3: ecosistema en GitHub, artefactos y Projects. Las etiquetas entre corchetes (por ejemplo `[M2-C001: url]`) son la fuente de cada dato. Precios, límites y conteos cambian: verifícalos en la fuente oficial antes de usarlos.

## Projects: definición, límites y capacidades

- Un **Project** en claude.ai es un entorno autocontenido que persiste entre sesiones, manteniendo historial de chats, instrucciones y base de conocimiento [M3-C020].
- Los usuarios gratuitos pueden crear **hasta 5 Projects**; los planes pagos permiten más y amplían la capacidad de RAG hasta **10× al acercarse al límite** [M3-C020].
- En planes Team y Enterprise, los Projects se pueden **compartir con permisos de ver o editar**, facilitando colaboración controlada [M3-C020].
- A diferencia de un chat suelto, el conocimiento en un Project **no se pierde entre sesiones**, lo que lo hace ideal para contextos estables que alimentan múltiples interacciones humanas [M3-C020].

## Árbol de decisión: Project vs. Skill vs. MCP vs. CLAUDE.md

- Usa un **Project** cuando el conocimiento es **estático o raramente cambia** y sirve para enriquecer conversaciones humanas [M3-C021].
- Usa una **Skill** cuando defines un **procedimiento repetible** que Claude debe invocar autónomamente; su cuerpo consume tokens solo al usarse, no al cargar [M3-C021].
- Usa un **servidor MCP** cuando los datos residen en sistemas externos y **deben estar frescos en tiempo real** (ej.: bases de datos, APIs internas) [M3-C021].
- El archivo **CLAUE.md** (o `claude.md`) es el mecanismo de contexto estático a nivel repositorio, útil para guías, políticas o instrucciones globales en código abierto, pero **no persiste en claude.ai** ni tiene ejecución [INFERENCIA basada en M3-C021 y documentación de Skills].
- Este árbol **no es oficial de Anthropic**, sino una síntesis derivada de capacidades documentadas en Projects, Skills y MCP [M3-C021].

## Gobernanza de Artifacts en organizaciones

- Las organizaciones **Team y Enterprise** disponen de **cuatro controles independientes** sobre Artifacts [M3-C022]:
  1. Toggle global para habilitar/deshabilitar Artifacts.
  2. Toggle separado para **habilitar conectores de Artifacts** (ej.: GitHub, Notion).
  3. Control de **compartición externa**, desactivado por defecto.
  4. Política de retención diferenciada: **períodos distintos** para artifacts privados vs. compartidos.
- Toda acción relevante (publicar, compartir, borrar) queda registrada en el **audit log** con eventos del tipo `claude_artifact_*` [M3-C022].
- El visor de Artifacts carga contenido desde dominios aislados `*.claudeusercontent.com`, que deben incluirse en listas blancas si la organización restringe salida de red [M3-C023].

## Compliance API: auditoría y control programático

- La **Compliance API** expone tres endpoints clave para gestionar Artifacts a nivel organizacional [M3-C023]:
  - `GET /v1/compliance/code/artifacts`: lista todos los artifacts.
  - `GET /v1/compliance/code/artifacts/{artifact_id}/versions/{version_id}`: recupera contenido específico de una versión.
  - `DELETE /v1/compliance/code/artifacts/{artifact_id}`: elimina un artifact por completo.
- Estos endpoints permiten integración con herramientas internas de gobernanza, cumplimiento o backup [M3-C023].
- El uso de la API requiere permisos administrativos y está limitado a organizaciones con plan **Team o Enterprise** [INFERENCIA consistente con M3-C022].

## Publicación en el marketplace comunitario

- Existen **dos vías distintas** para publicar plugins en el marketplace comunitario, dependiendo del perfil del autor [M3-C010]:
  - **Autores individuales**: usan el formulario en **Console** (`platform.claude.com/plugins/submit`).
  - **Organizaciones Team/Enterprise**: usan el formulario en **claude.ai** (`claude.ai/admin-settings/directory/submissions/plugins/new`), que requiere acceso de gestión del directorio.
- **No existe un proceso formal de aplicación** para el marketplace **oficial** de Anthropic: la inclusión es **discrecional** y decidida internamente por Anthropic [M3-C010].
- Publicar en el marketplace comunitario **no garantiza visibilidad ni revisión de seguridad**; los usuarios deben auditar plugins antes de usarlos [M3-C006].

## Fuentes vivas para mantenimiento continuo

- Los índices `llms.txt` son las **fuentes más confiables y actualizables** del ecosistema:
  - `code.claude.com/docs/llms.txt`: contiene **372 páginas** distribuidas en **13 secciones**, incluyendo **18 digests semanales** en "What is New" [M3-C011].
  - `modelcontextprotocol.io/llms.txt`: cumple función análoga para el protocolo MCP [M3-C011].
- Estos índices son **catalogables y enumerables**, a diferencia de listas curadas por terceros, lo que permite scripts de monitoreo automatizado [M3-C011].
- Se recomienda consumirlos programáticamente para detectar cambios en APIs, formatos o políticas [INFERENCIA].

## Repositorios centrales y licencias críticas

- **Seis repositorios oficiales populares carecen de archivo LICENSE** detectable por la API de GitHub, incluyendo:
  - `anthropics/claude-code` (141.771 estrellas)
  - `anthropics/skills` (169.981 estrellas)
  - `anthropics/prompt-eng-interactive-tutorial` (37.693 estrellas)
  - `anthropics/claude-agent-sdk-demos` (2.721 estrellas)
  - `anthropics/claude-agent-sdk-typescript` (1.704 estrellas)
  - `modelcontextprotocol/inspector` (10.679 estrellas) [M3-C004].
- La ausencia de licencia **no concede permiso de uso**, representando un **riesgo legal real** para implementaciones comerciales [M3-C004].
- Por contraste, los SDKs oficiales de Anthropic y MCP sí tienen licencias explícitas (MIT o Apache-2.0) y actividad reciente [M3-C008].

## Cambios estructurales en el ecosistema (2026)

- **Ocho repositorios clave fueron renombrados o trasladados**, rompiendo URLs antiguas [M3-C002]:
  - `anthropics/anthropic-cookbook` → `anthropics/claude-cookbooks`
  - `anthropics/claude-code-sdk-python` → `anthropics/claude-agent-sdk-python`
  - `modelcontextprotocol/specification` → `modelcontextprotocol/modelcontextprotocol`
  - `getAsterisk/claudia` → `winfunc/opcode`
  - Entre otros.
- El repositorio de **Desktop Extensions** (`anthropics/dxt` y `anthropics/mcpb`) ahora redirige a `modelcontextprotocol/mcpb` (2.081 estrellas), indicando una **migración del ámbito de producto al de protocolo** [M3-C003].
- Estos movimientos reflejan una **consolidación en torno al Model Context Protocol (MCP)** como capa interoperable, más allá de Anthropic [INFERENCIA basada en M3-C003].

## Adopción y reputación en el ecosistema

- Los repositorios oficiales más adoptados (por estrellas, agosto 2026) son:
  - `modelcontextprotocol/servers` (89.639)
  - `anthropics/claude-cookbooks` (51.732)
  - `anthropics/claude-plugins-official` (33.618)
  - `modelcontextprotocol/python-sdk` (24.035)
  - `anthropics/claude-quickstarts` (17.452) [M3-C001].
- Los repositorios comunitarios líderes incluyen:
  - `anomalyco/opencode` (198.464 estrellas, MIT)
  - `punkpeye/awesome-mcp-servers` (92.486)
  - `ruvnet/ruflo` (68.076) [M3-C007].
- La **fórmula de reputación** prioriza **vigencia (35%) sobre adopción (25%)**, favoreciendo proyectos activos aunque menos famosos [M3-C005].
- Esta fórmula **no evalúa calidad de código, seguridad ni idoneidad para casos específicos**; solo ordena candidatos [M3-C006].

**Si te llevas UNA cosa:** La persistencia contextual en el ecosistema Claude no es monolítica: Projects para conocimiento estable en conversaciones humanas, Skills para procedimientos autónomos y MCP para datos frescos en sistemas externos — elegir mal implica costos de contexto, latencia o gobernanza innecesarios.
