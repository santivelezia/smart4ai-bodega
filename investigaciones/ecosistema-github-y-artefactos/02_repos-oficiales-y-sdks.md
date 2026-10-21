> **Publicada por Smart4AI · fecha de corte 2026-08-17 · licencia CC BY-NC 4.0** (puedes usarla y adaptarla sin fines comerciales, dando crédito a Smart4AI).
> Parte de: Universo Claude 2026 · Módulo 3: ecosistema en GitHub, artefactos y Projects. Las etiquetas entre corchetes (por ejemplo `[M2-C001: url]`) son la fuente de cada dato. Precios, límites y conteos cambian: verifícalos en la fuente oficial antes de usarlos.

## Repositorios oficiales más activos y adoptados

- Al 2026-08-17, los cinco repositorios oficiales con mayor reputación (según la fórmula de la KB) son:  
  - `anthropics/claude-cookbooks` (51.732 estrellas, MIT, último push el mismo día de verificación) [M3-C001]  
  - `modelcontextprotocol/servers` (89.639 estrellas, sin licencia explícita detectada) [M3-C001]  
  - `anthropics/claude-plugins-official` (33.618 estrellas, Apache-2.0) [M3-C001]  
  - `modelcontextprotocol/python-sdk` (24.035 estrellas, MIT) [M3-C001]  
  - `anthropics/claude-quickstarts` (17.452 estrellas, MIT) [M3-C001]  
- De los 38 repositorios oficiales verificados, **ninguno está archivado** [M3-C001].  
- Los puntajes de reputación (100, 96, 93, 91, 90) son calculados mediante una fórmula que pondera vigencia (35%), adopción (25%), procedencia (20%), licencia (10%) y salud del repo (10%) [M3-C005].  

## SDKs oficiales por lenguaje

- Anthropic mantiene **seis SDKs oficiales**, todos bajo licencia MIT y con actividad reciente (último push al 2026-08-17):  
  - Python: `anthropic-sdk-python` (3.829 estrellas) [M3-C008]  
  - TypeScript: `anthropic-sdk-typescript` (2.091 estrellas) [M3-C008]  
  - Go: `anthropic-sdk-go` (1.176 estrellas) [M3-C008]  
  - Java: `anthropic-sdk-java` (365 estrellas) [M3-C008]  
  - Ruby: `anthropic-sdk-ruby` (365 estrellas) [M3-C008]  
  - PHP: `anthropic-sdk-php` (175 estrellas) [M3-C008]  
- El proyecto Model Context Protocol (MCP) mantiene **su propia familia de SDKs**, separada de los de Anthropic:  
  - Python: `python-sdk` (24.035 estrellas) [M3-C008]  
  - TypeScript: `typescript-sdk` (13.194 estrellas) [M3-C008]  
  - Go: `go-sdk` (4.996 estrellas) [M3-C008]  
  - C#: `csharp-sdk` (4.480 estrellas) [M3-C008]  
  - Rust: `rust-sdk` (3.813 estrellas) [M3-C008]  
  - Java: `java-sdk` (3.658 estrellas) [M3-C008]  

## Recursos oficiales de aprendizaje

- Tres repositorios son considerados recursos oficiales de aprendizaje:  
  - `anthropics/claude-cookbooks` (51.732 estrellas, MIT, push el 2026-08-17) [M3-C012]  
  - `anthropics/claude-quickstarts` (17.452 estrellas, MIT) [M3-C012]  
  - `anthropics/courses` (22.642 estrellas, sin push en los últimos **277 días**) [M3-C012]  
- [INFERENCIA] El repositorio `courses` probablemente no refleja cambios de producto introducidos en 2026; útil como base conceptual, pero debe contrastarse con documentación vigente [M3-C012].  

## Cambios estructurales en el ecosistema (renombramientos y migraciones)

- **Ocho repositorios centrales** cambiaron de nombre o de organización, rompiendo URLs anteriores:  
  - `anthropics/anthropic-cookbook` → `anthropics/claude-cookbooks` [M3-C002]  
  - `anthropic-quickstarts` → `claude-quickstarts` [M3-C002]  
  - `claude-code-sdk-python` → `claude-agent-sdk-python` [M3-C002]  
  - `modelcontextprotocol/specification` → `modelcontextprotocol/modelcontextprotocol` [M3-C002]  
  - `ryoppippi/ccusage` → `ccusage/ccusage` [M3-C002]  
  - `ruvnet/claude-flow` → `ruvnet/ruflo` [M3-C002]  
  - `getAsterisk/claudia` → `winfunc/opcode` [M3-C002]  
  - `sst/opencode` → `anomalyco/opencode` [M3-C002]  
- Dos repositorios (`anthropics/dxt` y `anthropics/mcpb`) redirigen a `modelcontextprotocol/mcpb` (2.081 estrellas al 2026-08-17), indicando una estandarización del formato fuera de Anthropic [M3-C003].  

## Licencias ausentes en repositorios populares

- **Seis repositorios oficiales altamente populares carecen de archivo LICENSE detectable** por la API de GitHub, lo que implica riesgo legal para uso comercial:  
  - `anthropics/claude-code` (141.771 estrellas) [M3-C004]  
  - `anthropics/skills` (169.981 estrellas) [M3-C004]  
  - `anthropics/prompt-eng-interactive-tutorial` (37.693 estrellas) [M3-C004]  
  - `anthropics/claude-agent-sdk-demos` (2.721 estrellas) [M3-C004]  
  - `anthropics/claude-agent-sdk-typescript` (1.704 estrellas) [M3-C004]  
  - `modelcontextprotocol/inspector` (10.679 estrellas) [M3-C004]  
- Ausencia de licencia = **sin permiso explícito de uso**, independientemente de popularidad [M3-C004].  

## Limitaciones de la métrica de reputación

- La fórmula de reputación **no evalúa**:  
  - Calidad del código (las estrellas miden popularidad, no ingeniería) [M3-C006]  
  - Seguridad (no sustituye auditoría previa a la instalación de plugins) [M3-C006]  
  - Ajuste al caso de uso específico del usuario [M3-C006]  
  - Está sesgada hacia proyectos antiguos (más tiempo para acumular estrellas e issues) [M3-C006]  
- Su propósito es **ordenar candidatos**, no tomar decisiones automáticas [M3-C006].  

## Riesgos de cadena de suministro

- Tres vectores de riesgo documentados en el ecosistema:  
  1. **Plugins ejecutan código arbitrario** con privilegios del usuario; Anthropic **no verifica su contenido** [M3-C009]  
  2. **Skills pueden invocar herramientas** de formas no alineadas con su propósito declarado [M3-C009]  
  3. Skills o servidores que consumen **datos externos vía URL** pueden recibir instrucciones maliciosas o verse comprometidos por cambios en dependencias [M3-C009]  

## Artifacts de Claude Code: alcance y limitaciones

- Un **artifact** es una página web interactiva autocontenida, publicada en una URL privada en `claude.ai` [M3-C013]  
- Se actualiza en tiempo real mientras dura la sesión, pero **no es una aplicación completa**:  
  - No tiene backend  
  - No puede persistir datos de formularios  
  - No soporta múltiples rutas [M3-C013]  
- Para herramientas internas con backend, la documentación oficial recomienda **despliegue en infraestructura propia** [M3-C013]  

**Si te llevas UNA cosa:** La ausencia de licencia en repositorios populares como `claude-code` (141k+ estrellas) representa un riesgo legal real para uso comercial, independientemente de su adopción—nunca asumas permisos de uso sin una licencia explícita.
