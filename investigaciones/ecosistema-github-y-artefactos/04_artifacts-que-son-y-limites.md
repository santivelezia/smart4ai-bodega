> **Publicada por Smart4AI · fecha de corte 2026-08-17 · licencia CC BY-NC 4.0** (puedes usarla y adaptarla sin fines comerciales, dando crédito a Smart4AI).
> Parte de: Universo Claude 2026 · Módulo 3: ecosistema en GitHub, artefactos y Projects. Las etiquetas entre corchetes (por ejemplo `[M2-C001: url]`) son la fuente de cada dato. Precios, límites y conteos cambian: verifícalos en la fuente oficial antes de usarlos.

## Definición y naturaleza de los artifacts

- Un artifact de Claude Code es una **página web viva e interactiva**, autocontenida, publicada desde una sesión activa a una URL privada en `claude.ai` que se actualiza en tiempo real mientras la sesión persiste [M3-C013].
- **No es una aplicación**: carece de backend, no puede persistir datos enviados mediante formularios, ni servir múltiples rutas; es estrictamente un único documento HTML/MD renderizado [M3-C013].
- La documentación oficial recomienda desplegar herramientas internas con backend en infraestructura propia, no como artifacts [M3-C013].

## Restricciones técnicas: CSP, formato y tamaño

- Los artifacts operan bajo una **Content Security Policy (CSP) estricta** con cinco restricciones duras:
  - Solo permiten recursos externos de **Google Fonts** y datos provenientes de **conectores MCP**.
  - Bloquean scripts, hojas de estilo, fuentes e imágenes de otros hosts.
  - Prohíben llamadas `fetch`, `XMLHttpRequest` y `WebSocket` a dominios externos.
  - No admiten backend ni múltiples rutas; los enlaces relativos no resuelven.
  - El archivo fuente debe ser `.html`, `.htm` o `.md`.
  - El tamaño renderizado **no debe exceder 16 MiB** [M3-C014].

## Requisitos de plan, autenticación y cumplimiento

- Los artifacts están **deshabilitados** en organizaciones con cualquiera de estas políticas activas:
  - Customer-managed encryption keys (CMEK)
  - HIPAA
  - Zero Data Retention (ZDR) [M3-C015].
- Requieren una **sesión autenticada con cuenta claude.ai**; no funcionan con:
  - API keys
  - Tokens de gateway
  - Credenciales de proveedor cloud (AWS, GCP, Azure) [M3-C015].
- **No están disponibles** en ninguna integración de terceros: Amazon Bedrock, Google Cloud Vertex AI ni Microsoft Foundry [M3-C015].

## Acceso a conectores MCP desde artifacts

- Las llamadas a conectores MCP se ejecutan **bajo la identidad del visitante**, no del autor del artifact [M3-C016].
- Cada visitante debe **aprobar explícitamente** el acceso al conector antes de la primera llamada [M3-C016].
- Si un visitante no tiene el conector configurado, las secciones dinámicas del artifact **no se renderizan** o aparecen vacías [M3-C016].
- Esto permite dashboards personalizados: dos usuarios pueden ver datos distintos al abrir la misma URL [M3-C016].

## Compartición y alcance de visibilidad

- **Ningún plan permite compartir artifacts con conectores MCP mediante enlace público** [M3-C017].
- En planes **Team y Enterprise**, los artifacts pueden:
  - Permanecer privados, o
  - Compartirse dentro de la organización [M3-C017].
- En planes **Pro y Max**, donde el único mecanismo de compartición es el enlace público, cualquier artifact que use conectores **queda forzosamente privado para su autor** [M3-C017].

## Patrones recomendados de uso

La documentación oficial destaca **cinco patrones efectivos** para artifacts [M3-C018]:

- **Recorrer un cambio**: renderizar diffs con anotaciones marginales interactivas.
- **Comparar alternativas**: mostrar múltiples variantes en una sola página para evaluación conjunta.
- **Ajustar con controles interactivos**: sliders, toggles o inputs que modifican parámetros en tiempo real.
- **Devolver resultado a la sesión**: botón que genera texto listo para pegar en el chat o terminal.
- **Seguir trabajo en curso**: lista de tareas que se marca progresivamente durante una operación larga.

## Costo en tokens y optimización

- Generar un artifact **consume tokens de salida** como cualquier otra respuesta generada [M3-C019].
- El costo aumenta significativamente con:
  - CSS inline
  - JavaScript para interactividad
  - Imágenes embebidas como **data URI** (especialmente raster: PNG, JPEG) [M3-C019].
- Recomendaciones oficiales para reducir costo:
  - Preferir **SVG o HTML/CSS** sobre imágenes raster.
  - Omitir interactividad innecesaria.
  - Resumir datasets grandes en lugar de incrustarlos completos [M3-C019].

## Integración con sistemas de diseño

- Claude aplica una **skill de diseño integrada** al generar artifacts [M3-C024].
- Esta skill **detecta automáticamente** si el proyecto ya incluye un sistema de diseño (por ejemplo, en `CLAUDE.md`) y lo respeta [M3-C024].
- Precedencia declarada en decisiones de estilo:
  1. Instrucciones explícitas en el **prompt**
  2. Sistema de diseño detectado en el proyecto
  3. Decisiones por defecto de Claude [M3-C024].
- Para asegurar coherencia de marca, basta con definir **design tokens accesibles** en el contexto del proyecto [M3-C024].

**Si te llevas UNA cosa:** Los artifacts son prototipos interactivos efímeros, no aplicaciones reales: están limitados por una CSP estricta, requieren autenticación humana, no funcionan en entornos regulados (HIPAA/ZDR), y su lógica dinámica depende de quién los ve — no de quién los creó.
