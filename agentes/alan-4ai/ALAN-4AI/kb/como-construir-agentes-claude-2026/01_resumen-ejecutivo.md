# 01 · Resumen ejecutivo · 10 insights críticos para construir agentes Claude al máximo nivel (2026)

> Cierra una semana de trabajo en 5 minutos de lectura. Para detalle por componente, ver categorías 02-09.

---

## 1 · Empieza por el LLM call más simple, no por el agente

> *"Optimizing single LLM calls with retrieval and in-context examples is usually enough."* — Anthropic Engineering [02]

Antes de construir un agente, prueba con un solo LLM call bien diseñado. Solo escala a workflow → agent → multi-agent cuando la mejora marginal es **medible**. *"Agentic systems often trade latency and cost for better task performance"*: el trade-off solo vale si la mejora justifica el costo.

## 2 · Los 5 patrones canónicos de Anthropic (no más, no menos)

Anthropic publica explícitamente: (1) Prompt chaining, (2) Routing, (3) Parallelization, (4) Orchestrator-workers, (5) Evaluator-optimizer. **No están: ReAct, Reflection, Ensemble** — esos son SOTA de papers académicos. Usa los canónicos por default; trae los académicos cuando tengas evidencia de que ayudan. [02, 09]

## 3 · Claude Code y Claude Agent SDK son lo mismo bajo el hood

> *"The Agent SDK gives you the same tools, agent loop, and context management that power Claude Code, programmable in Python and TypeScript."* [05]

Prototipar en CLI → portar a SDK para producción → eventualmente Managed Agents para escala. La distinción NO es de capability, es de runtime: ¿quién invoca y dónde corre?

## 4 · Sub-agents existen para preservar context, no para velocidad

> *"Use one when a side task would flood your main conversation with search results, logs, or file contents you won't reference again."* [03]

La regla de oro: ¿el output que necesitas cabe en un párrafo? → subagent. ¿<3 file reads? → inline. Sub-agent Haiku para exploration + main Opus para decisiones = 12.5x ahorro sin sacrificar calidad. [03]

## 5 · Skills extienden Claude, MCPs lo conectan

> Skills empacan **workflows** (procedures, conventions, prompts). MCPs conectan **tools externos** (APIs, DBs, services). [06]

Si necesitas que Claude HAGA algo nuevo en otro sistema → MCP. Si necesitas que Claude SIGA un workflow tuyo → Skill. Para tareas con side effects (deploy, commit prod), `disable-model-invocation: true` siempre.

## 6 · Prompt caching es la palanca #1 de costo

Un agente con 5,000 tokens system prompt usado 100 veces/día baja de **$2.50/day a $0.05/day (98% savings)** sólo activando `cache_control`. Mide cache hit rate como métrica de costo más importante: si está bajo 70%, hay leverage masivo. [07]

## 7 · Memory en agentes Claude tiene 3 capas

- **CLAUDE.md** → instrucciones persistentes (cross-session) — write, commit, share team
- **Auto-memory** → learnings que Claude descubre solo (build commands, debugging insights) — toggle con `autoMemoryEnabled`
- **Memory MCP** → knowledge graph relational (entity-centric queries) — sólo cuando flat data no basta

No las mezcles: cada una es óptima para un caso. [07]

## 8 · 5 anti-patterns canónicos que TODOS cometemos

1. **Kitchen sink session** — fix: `/clear` entre tasks
2. **Correcting over and over** — fix: después de 2 fails, `/clear` + better prompt
3. **Over-specified CLAUDE.md** — fix: prune ruthless
4. **Trust-then-verify gap** — fix: always provide verification (tests, screenshots)
5. **Infinite exploration** — fix: scope narrow o usa subagents

Se sienten productivos pero envenenan el context. La defensa es disciplina deliberada. [09]

## 9 · La regla de costo Smart4AI v1.6

**Claude Code SIEMPRE plan Max** (claude.ai token), **NUNCA `ANTHROPIC_API_KEY`** directo. Un router multi-modelo (Opus/Sonnet/DeepSeek/GPT-4o-mini/Kimi/MCPs gratis) reduce 60-80% vs all-Opus. **Antes de cualquier operación >$1 USD, advertir explícitamente con costo estimado**. [08]

## 10 · El gap más importante vs SOTA 2026

Los patrones que la academia valida pero Anthropic no canoniza en sus docs:
- **Planner/Executor split** (MALT, CoPlanner) — separar planning de execution mejora reasoning
- **Verifier agents dedicados** — captura errors antes de output
- **Hybrid LRM + LLM** (LaRMA) — combina lo mejor de cada uno
- **Live benchmarks** > static — contamination y temporal validity son reales

Smart4AI ya hace cross-validation (Stage 6) y quality audit (Stage 11). Falta evaluar adoptar planner/executor explícito en futuros agentes. [09]

---

## Si te llevas UNA cosa de toda la investigación

**No construyas un agente nuevo sin antes responder estas 3 preguntas:**
1. ¿Lo resuelve un single LLM call con buen prompt? Si sí → para ahí.
2. ¿Cómo voy a verificar que el agente funciona? Si no tienes verificación clara → no lo shippees.
3. ¿Cuál es el costo proyectado mes 1 con prompt caching activado? Si no sabes → mide antes de escalar.

Los anti-patterns no son fallas técnicas; son fallas de disciplina. La diferencia entre un agente útil y uno que estorba está en aplicar las 5 reglas anti-pattern todos los días.
