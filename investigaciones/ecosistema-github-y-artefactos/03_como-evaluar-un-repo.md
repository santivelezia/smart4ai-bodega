> **Publicada por Smart4AI · fecha de corte 2026-08-17 · licencia CC BY-NC 4.0** (puedes usarla y adaptarla sin fines comerciales, dando crédito a Smart4AI).
> Parte de: Universo Claude 2026 · Módulo 3: ecosistema en GitHub, artefactos y Projects. Las etiquetas entre corchetes (por ejemplo `[M2-C001: url]`) son la fuente de cada dato. Precios, límites y conteos cambian: verifícalos en la fuente oficial antes de usarlos.

## Evaluación de repositorios: fórmula de reputación y sus límites

- La fórmula de reputación asigna 100 puntos distribuidos en cinco dimensiones: **Vigencia (35 pts)** basada en días desde el último push, **Adopción (25 pts)** por estrellas, **Procedencia (20 pts)** si pertenece a organización oficial, **Licencia (10 pts)** si tiene licencia explícita detectable, y **Salud (10 pts)** según ratio issues abiertos/estrellas (cero automático si está archivado) [M3-C005].  
- Vigencia pesa más que Adopción para priorizar proyectos activos sobre populares: un proyecto excelente de dos meses aún no acumula estrellas [M3-C005].  
- La fórmula **ordena candidatos**, no decide por sí sola; tiene cuatro límites declarados: (1) no mide calidad de código (estrellas ≠ ingeniería), (2) no evalúa seguridad (requiere auditoría manual), (3) no garantiza ajuste al caso de uso específico, y (4) presenta sesgo de antigüedad [M3-C006].  

## Repositorios oficiales: movimientos, licencias y riesgos legales

- **OCHO repositorios centrales** fueron renombrados o trasladados entre organizaciones, rompiendo URLs anteriores:  
  - `anthropics/anthropic-cookbook` → `anthropics/claude-cookbooks`  
  - `anthropic-quickstarts` → `claude-quickstarts`  
  - `claude-code-sdk-python` → `claude-agent-sdk-python`  
  - `modelcontextprotocol/specification` → `modelcontextprotocol/modelcontextprotocol`  
  - `ryoppippi/ccusage` → `ccusage/ccusage`  
  - `ruvnet/claude-flow` → `ruvnet/ruflo`  
  - `getAsterisk/claudia` → `winfunc/opcode`  
  - `sst/opencode` → `anomalyco/opencode` [M3-C002].  
- Además, `anthropics/dxt` y `anthropics/mcpb` redirigen ambos a `modelcontextprotocol/mcpb` (2.081 estrellas al 2026-08-17), indicando migración de la organización del producto a la del protocolo [M3-C003][F1: https://api.github.com/repos/modelcontextprotocol/mcpb].  
- **SEIS repositorios oficiales populares carecen de archivo LICENSE detectable**:  
  - `anthropics/claude-code` (141.771 estrellas)  
  - `anthropics/skills` (169.981)  
  - `anthropics/prompt-eng-interactive-tutorial` (37.693)  
  - `anthropics/claude-agent-sdk-demos` (2.721)  
  - `anthropics/claude-agent-sdk-typescript` (1.704)  
  - `modelcontextprotocol/inspector` (10.679)  
  → Ausencia de licencia implica **ningún permiso legal explícito para uso comercial** [M3-C004].  

## Repositorios comunitarios verificados (al 2026-08-17)

- Los repositorios comunitarios con mayor adopción y licencia explícita son:  
  - `anomalyco/opencode` (198.464 estrellas, MIT)  
  - `punkpeye/awesome-mcp-servers` (92.486)  
  - `ruvnet/ruflo` (68.076)  
  - `hesreallyhim/awesome-claude-code` (52.493)  
  - `davila7/claude-code-templates` (30.274)  
  - `SuperClaude-Org/SuperClaude_Framework` (23.835)  
  - `winfunc/opcode` (22.383)  
  - `ccusage/ccusage` (17.979)  
  → Los puntajes de reputación asociados son **calculados por la fórmula de esta KB**, no datos nativos de GitHub [M3-C007].  

## Riesgo real de cadena de suministro

- El riesgo de cadena de suministro es **operativo y documentado**, con tres vectores:  
  1. **Plugins ejecutan código arbitrario** con privilegios del usuario; Anthropic **no verifica su contenido** [M3-C009][F1: https://code.claude.com/docs/en/discover-plugins.md].  
  2. **Skills pueden invocar herramientas fuera de su propósito declarado**, permitiendo desviaciones maliciosas en flujos automatizados [M3-C009].  
  3. **Skills o servidores MCP que consumen datos externos** pueden recibir payloads maliciosos vía URLs dinámicas o verse comprometidos si sus dependencias cambian sin notificación [M3-C009][F2: https://platform.claude.com/docs/en/agents-and-tools/agent-skills/overview.md].  

## Contexto adicional de ecosistema (para coherencia)

- De los **38 repositorios oficiales verificados**, ninguno está archivado; los más activos incluyen:  
  - `anthropics/claude-cookbooks` (51.732 estrellas, MIT)  
  - `modelcontextprotocol/servers` (89.639)  
  - `anthropics/claude-plugins-official` (33.618, Apache-2.0)  
  - `modelcontextprotocol/python-sdk` (24.035, MIT)  
  - `anthropics/claude-quickstarts` (17.452, MIT)  
  → Sus puntajes de reputación (100, 96, 93, 91, 90) son **calculados**, no nativos [M3-C001].  
- Anthropic mantiene **6 SDKs oficiales** (todos MIT, últimos pushes recientes): Python (3.829 estrellas), TypeScript (2.091), Go (1.176), Java (365), Ruby (365), PHP (175) [M3-C008].  
- El proyecto MCP mantiene **6 SDKs propios**: Python (24.035), TypeScript (13.194), Go (4.996), C# (4.480), Rust (3.813), Java (3.658) [M3-C008].  

## Implicaciones para decisiones técnicas

- **Artifacts** (páginas interactivas publicadas desde sesiones) **no son aplicaciones**: son HTML autocontenidos sin backend, limitados a 16 MiB, con CSP estricta que bloquea recursos externos excepto Google Fonts y conectores MCP [M3-C013][M3-C014].  
- Artifacts requieren sesión autenticada en claude.ai; **no funcionan** con API keys, tokens de gateway, ni en Bedrock/Google Cloud/Microsoft Foundry; además están **deshabilitados** bajo Customer-managed encryption keys, HIPAA o Zero Data Retention [M3-C015].  
- En artifacts, las llamadas a conectores MCP usan **las credenciales del visitante**, no del creador; cada usuario aprueba acceso y ve datos según sus permisos [M3-C016].  
- **Projects** ofrecen contexto persistente entre sesiones (hasta 5 para usuarios gratuitos); en planes pagos, RAG amplía capacidad de base de conocimiento hasta 10×; en Team/Enterprise se comparten con permisos [M3-C020].  
- Para contexto persistente: usar **Project** si alimenta conversaciones humanas estables, **Skill** si es procedimiento repetible (cuerpo consume contexto solo al usarse), y **servidor MCP** si los datos deben estar frescos desde sistemas externos [M3-C021][INFERENCIA].  

**Si te llevas UNA cosa:** La ausencia de licencia en repositorios populares como `anthropics/claude-code` (141k+ estrellas) constituye un riesgo legal real para uso comercial—la fama no sustituye el permiso explícito.
