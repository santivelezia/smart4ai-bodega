# Contradicciones, Gaps y Limitaciones de esta Investigación

> Generado por una investigación Smart4AI · Stage 10 · 2026-05-28

## Fuentes No Accesibles Durante Stage 3

| Fuente | Error | Impacto |
|---|---|---|
| Perplexity MCP | Chrome remote debugging no disponible (ECONNREFUSED ::1:9222) | Alto — reemplazado con HF papers + WebFetch |
| SIC Colombia (Habeas Data) | SSL certificate error | Medio — claims Q10 marcados INFERENCIA |
| OpenAI pricing page | HTTP 403 | Bajo — pricing conocido de fuentes públicas |
| Oracle pricing | HTTP 403 | Bajo — pricing estimado, marcado INFERENCIA |
| LangGraph docs | Redirects en cadena (308) | Medio — Letta tiered memory marcada INFERENCIA |
| Claude memory docs | Redirect a platform.claude.com (404) | Bajo — Anthropic memory API no documentada en este run |
| ChatGPT memory docs | HTTP 403 | Bajo — caso de estudio Q15 no cubierto con fuente directa |

## Claims Marcados INFERENCIA (11 de 56)

Estos claims son razonables pero NO tienen fuente directamente verificada en este run:

- **C013** — Letta tiered memory (in-context/recall/archival): docs.letta.com no cargó
- **C023** — Señales implícitas de preferencia de usuario: inferencia lógica sin paper específico
- **C031** — Constitution versioning git+Telegram workflow: patrón inferido, no implementación de referencia
- **C037** — Colombia Ley 1581 derechos (5 derechos): SIC.gov.co no accesible (SSL)
- **C040** — Checklist LATAM compliance: inferencia combinando conocimiento general de leyes
- **C041** — Oracle ARM + OpenAI pricing: pricing estimado de fuentes conocidas pero bloqueadas
- **C048** — Redis pub/sub cross-agent sync: patrón inferido de principios distributed systems
- **C049** — el constructor de agentes template CORE 5/5: síntesis inferida de múltiples papers
- **C050** — el constructor de agentes template Ops 4/5 + Comerciales 3/5: inferencia de gradación
- **C055** — Memory interface para sync (Roadmap paper): extrapolación de principios
- **C056** — Memento-Skills como Procedural Memory: aplicación inferida del patrón

## Gaps Temáticos

### Q03 — Checkpointing (parcial)
LangGraph checkpointer (SQLite/PostgreSQL/Redis backends) no fue posible verificar directamente. Los claims se basan en MemGPT/Letta patrones y ByteRover como aproximación.

### Q10 — Compliance LATAM (parcial)
Solo se cubrió Colombia (Habeas Data) con inferencia. LGPD Brasil y LFPDPPP México no tienen fuentes directas en este run. Para producción comercial LATAM: contratar asesoría legal local.

### Q15 — Case Studies (Lindy, Devin, ChatGPT)
Lindy memory y ChatGPT memory específicos no se pudieron verificar (páginas bloqueadas). Solo Live-Evo y HGM tienen fuentes verificadas.

## Contradicciones Detectadas

### ByteRover vs pgvector
- **ByteRover** (C009, C042) propone CERO infraestructura externa — todo en markdown files, SIN vector DB ni embedding service
- **GAAMA, H-MEM, Memora** (C010, C012) usan vector embeddings y knowledge graphs como fundamento

**Resolución**: no es contradicción real. ByteRover es válido para agentes lightweight/single-user. GAAMA/H-MEM son superiores para multi-sesión complejo. Smart4AI v1 puede usar ByteRover approach; v2 multi-tenant necesita pgvector+graph.

### Alignment tuning: ayuda vs daña
- **SYCON Bench** (C029): alignment tuning AMPLIFICA sycophancy
- **SMART** (C033): RL con reasoning optimization reduce sycophancy

**Resolución**: alignment tuning estándar (RLHF de instruction following) amplifica sycophancy. RL específicamente diseñado para reasoning quality (como UA-MCTS en SMART) lo reduce. Son técnicas distintas con efectos opuestos.

## Recomendaciones para Investigación de Seguimiento

1. **D2 — LangGraph checkpointing**: verificar directamente docs.langchain.com/langgraph checkpointing backends con cuenta activa
2. **D3 — Colombia legal completo**: contratar revisión legal de Habeas Data para el sistema de memoria de HERMES con datos de usuarios colombianos
3. **D4 — ChatGPT/Lindy memory**: comparativa con acceso real a las plataformas
4. **D5 — Oracle ARM benchmarks**: medir performance real de pgvector en Oracle ARM 24GB con 12 agentes simultáneos

---

*Si te llevas UNA cosa: los 11 claims INFERENCIA son el área más frágil del KB — priorizar verificación de C031 (constitution versioning) y C037 (Habeas Data) antes de implementar en producción.*
