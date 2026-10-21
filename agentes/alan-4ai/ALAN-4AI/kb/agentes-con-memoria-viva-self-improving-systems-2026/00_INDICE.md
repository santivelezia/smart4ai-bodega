# Índice · Agentes con Memoria Viva y Self-Improving Systems 2026

> KB generado por `una investigación Smart4AI` · 2026-05-28
> Uso: Project Knowledge Claude.ai · Stage 0 el constructor de agentes · template Patrón 5

## Archivos de este Knowledge Base

| Archivo | Contenido | Q cubiertos | Claims |
|---|---|---|---|
| `01_resumen-ejecutivo.md` | Decisiones clave, SOTA snapshot, framework recomendado | Todos | Síntesis |
| `02_panorama-frameworks-sota.md` | Mem0, Letta, Cognee, O-Mem, U-Mem, AgentFly, Live-Evo, HGM | Q01, Q15 | 9 |
| `03_arquitectura-memoria-jerarquica.md` | 5 capas, ByteRover, GAAMA, xMemory, H-MEM, checkpointing, cross-agent sync | Q02, Q03, Q13 | 11 |
| `04_mecanismos-aprendizaje-continuo.md` | Reflexion, MARS, Agent-R, Live-Evo, ARIA, MetaAgent, uncertainty | Q04, Q05, Q06 | 12 |
| `05_gobernanza-drift-constitution.md` | Agent Drift, ASI, SYCON Bench, Memento-Skills, constitution versioning | Q07, Q08 | 6 |
| `06_anti-patterns-criticos.md` | Catastrophic forgetting, sycophancy, memory bloat, false memories, MEMTRACK | Q09 | 5 |
| `07_compliance-legal-latam.md` | Habeas Data CO, LGPD BR, LFPDPPP MX, Oblivionis unlearning, delete-on-request | Q10 | 4 |
| `08_operaciones-costos-build-vs-buy.md` | Oracle ARM pricing, ByteRover $0 infra, MemPO -73% tokens, Mem0 vs Cognee decision | Q11, Q12 | 6 |
| `09_template-hefesto.md` | **DELIVERABLE PRINCIPAL** — skeleton code 5 sistemas × 3 tipos de agente | Q14 | Síntesis |
| `98_contradicciones-y-gaps.md` | Contradicciones detectadas, fuentes con error, gaps a investigar | — | — |
| `99_fuentes-y-bibliografia.md` | 31 papers HF + 3 repos GitHub + errores documentados | — | — |

## Preguntas de Validación (Retrieval Test)

Para verificar que este KB es útil, otro Claude debe responder estas preguntas solo leyendo los archivos:

1. ¿Qué framework concreto usa HERMES para Memoria Personal? → `02_panorama-frameworks-sota.md` + `08_operaciones-costos-build-vs-buy.md`
2. ¿Cómo evita HERMES catastrophic forgetting? → `06_anti-patterns-criticos.md`
3. ¿Cuál es el costo proyectado de memoria viva para 12 meses? → `08_operaciones-costos-build-vs-buy.md`
4. ¿Qué código skeleton inyecta el constructor de agentes en cada agente nuevo? → `09_template-hefesto.md`
5. ¿Qué documentos legales necesito antes de guardar memoria de un cliente colombiano? → `07_compliance-legal-latam.md`
6. ¿Cuáles son los 3 anti-patterns más caros y cómo prevenirlos? → `06_anti-patterns-criticos.md`
7. ¿Cómo se sincroniza memoria entre agentes sin SPOF? → `03_arquitectura-memoria-jerarquica.md`

## Scope Completo

- **Sub-preguntas investigadas**: 15/15
- **Claims atómicos**: 56 (45 verified · 11 INFERENCIA · 0 contradicted)
- **Fuentes primarias**: 34 (31 papers HF + 3 repos GitHub)
- **Perplexity MCP**: FUENTE_FAIL (requiere Chrome remote debugging)
- **Gemini MCP**: excluido por invocación (`fuentes_excluidas=gemini`)

## Cómo usar este KB

```
# Subir a Project Knowledge de Claude.ai:
# Seleccionar todos los archivos .md de esta carpeta (excepto 98_ y 99_)
# O cargar como ZIP completo

# Referenciar en el constructor de agentes Stage 0:
# Ver 09_template-hefesto.md → sección "Código Skeleton"
```

---

*Última actualización: 2026-05-28 · una investigación Smart4AI*
