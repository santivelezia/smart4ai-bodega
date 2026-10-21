# 02 · Fundamentos y arquitectura de agentes Claude

> *Qué es un agente Claude moderno, sus 7 componentes core, los 5 patrones canónicos de Anthropic, y heurísticas para decidir cuándo usar workflow vs agente vs multi-agent.*

## Fuentes (F-codes usados inline)

- [F1] Claude Code Overview · https://code.claude.com/docs/en/overview
- [F2] Agent SDK Overview · https://code.claude.com/docs/en/agent-sdk/overview
- [F3] Building Effective Agents · https://www.anthropic.com/engineering/building-effective-agents
- [F4] Multi-agent Research System · https://www.anthropic.com/engineering/multi-agent-research-system
- [F5] Best Practices Claude Code · https://code.claude.com/docs/en/best-practices
- [F6] HF Papers · From LLM Reasoning to Autonomous AI Agents (survey 2025-04) · https://hf.co/papers/2504.19678
- [F7] HF Papers · MALT (Dec 2024) · https://hf.co/papers/2412.01928
- [F8] HF Papers · LaRMA (Mar 2025) · https://hf.co/papers/2503.11074

---

## 1 · Definición operativa de "agente Claude 2026"

Claude Code es definido oficialmente como *"agentic coding tool that reads your codebase, edits files, runs commands, and integrates with your development tools"* [F1]. La diferencia con un chatbot tradicional es operacional: el agente actúa autónomamente, decide qué tools usar, y no espera por cada respuesta del humano [F1].

El Claude Agent SDK *"gives you the same tools, agent loop, and context management that power Claude Code, programmable in Python and TypeScript"* [F2]. Es decir: lo que ves en el CLI es lo mismo que tienes vía library, con la misma API. Esto significa que **el patrón que aprendes en Claude Code se transfiere 1:1 al SDK** cuando llegue el momento de production deployment.

## 2 · Los 7 componentes core de un agente Claude moderno

Componente | Doc canónica | Propósito
---|---|---
**System prompt** (CLAUDE.md, agent.md) | `/en/memory` [F1] | Instrucciones persistentes, código style, architecture decisions
**Auto-memory** | `/en/memory#auto-memory` [F1] | Learnings entre sesiones sin que el user escriba
**Tools** (built-in + custom) | `/en/agent-sdk/overview` [F2] | Read/Write/Edit/Bash/Monitor/Glob/Grep/WebSearch/WebFetch/AskUserQuestion + custom
**MCPs** | `/en/mcp` [F1] | Integración con sistemas externos (Notion, Slack, GitHub, DB, Figma)
**Sub-agents** | `/en/sub-agents` [F1] | Spawn workers con contexto aislado para sub-tareas
**Hooks** | `/en/hooks` [F1] | Shell o HTTP triggers antes/después de eventos lifecycle
**Skills** | `/en/skills` [F1] | Workflows empacados como `/skill-name` cargables on-demand

Todos los componentes están disponibles en CLI, IDE extensions, Desktop, Web y SDK — *"each surface connects to the same underlying Claude Code engine, so your CLAUDE.md files, settings, and MCP servers work across all of them"* [F1].

## 3 · Patrones de arquitectura

### 3.1 · Los 5 patrones canónicos de Anthropic [F3]

Anthropic publica explícitamente 5 patrones de construcción de agentes ordenados por complejidad creciente:

1. **Prompt chaining** — secuencia lineal con check points entre etapas. Útil cuando hay sub-pasos claros (extract → analyze → format).
2. **Routing** — un clasificador decide cuál especialista invocar. Útil cuando hay categorías discretas de input.
3. **Parallelization** — múltiples invocaciones concurrentes + voting/aggregation. Útil para reducir varianza o cubrir aspectos paralelos.
4. **Orchestrator-workers** — lead Claude delega sub-tareas a workers Claude. Útil cuando la tarea se descompone dinámicamente.
5. **Evaluator-optimizer** — generator + critic iteran hasta converger. Útil cuando hay criterio de calidad evaluable.

**Caso real de orchestrator-workers**: Anthropic publicó un multi-agent research system donde un Claude orquestador coordina sub-agentes que ejecutan exploraciones paralelas [F4]. Los challenges documentados: token cost de contexto compartido, error propagation entre subagentes, dificultad para evaluar quality del output multi-agent.

### 3.2 · Patrones SOTA emergentes (académicos, no canónicos Anthropic)

Marcado `[INFERENCIA]` porque NO aparecen en docs oficiales Anthropic, pero sí en survey papers HF [F6,F7,F8]:

- **ReAct** (Reason + Act loop) — patrón de "pensar → actuar → observar → pensar" que aparece en LangChain, AgentLite, AutoGen.
- **Reflection** — auto-crítica iterativa donde el agente revisa su output antes de finalizar.
- **Ensemble** — múltiples LLMs votan; reduce hallucinations al precio de N× costo.
- **Planner/Executor split** (MALT, CoPlanner) — un agente planifica, otro ejecuta; verifier dedicado mejora MATH/GSM8k. Joint outcome-based rewards [F7].
- **Hybrid LRM + LLM** (LaRMA Mar 2025) — Large Reasoning Models como DeepSeek-R1 superan en reasoning pero fallan en execution; LLM tradicional superior en execution. Hybrid es óptimo, con caveats: computational cost alto, overthinking, fact-ignoring tendencies de los LRM [F8].

### 3.3 · Patrón Writer/Reviewer (parallel sessions, Anthropic) [F5]

Caso práctico citado en Best Practices:
- **Session A (Writer)** implementa con su contexto fresh.
- **Session B (Reviewer)** revisa con contexto SEPARADO. La separación importa: *"A fresh context improves code review since Claude won't be biased toward code it just wrote"* [F5].
- Session A recibe feedback y address issues.

Variantes: Writer/Tester (uno escribe tests, otro código que los pasa), Writer/Documenter, Writer/Security-Reviewer.

### 3.4 · Patrón pipeline / non-interactive [F5]

`claude -p "prompt"` corre headless. Output formats: text (default), json (`--output-format json`), streaming JSON (`--output-format stream-json`). Encaja en CI/CD, pre-commit hooks, batch processing. Ejemplos canónicos: análisis de logs por anomalías, traducción de strings nuevas, review de seguridad sobre diff.

## 4 · Cuándo usar workflow vs agente vs multi-agent

### 4.1 · La heurística #1 de Anthropic [F3]

*"Finding the simplest solution possible, and only increasing complexity when needed."*

Para la mayoría de aplicaciones, *"optimizing single LLM calls with retrieval and in-context examples is usually enough"* [F3]. Es decir: **antes de construir un agente, intenta con un solo LLM call bien diseñado**.

### 4.2 · Workflow vs Agent decision logic [F3]

**Use workflows** cuando:
- Tasks bien definidas con predictable steps
- *"Workflows offer predictability and consistency for well-defined tasks"*

**Use agents** cuando:
- *"Flexibility and model-driven decision-making are needed at scale"*
- Problemas open-ended donde *"it's difficult or impossible to predict the required number of steps"*

### 4.3 · El trade-off central [F3]

> *"Agentic systems often trade latency and cost for better task performance"* — Anthropic

Solo vale la pena cuando demonstrable improvements justify the expense. Si la mejora marginal sobre un single LLM call no es medible, **no construyas el agente**.

### 4.4 · Workflow recomendado oficial: Explore → Plan → Implement → Commit [F5]

Para tareas no triviales:
1. **Explore** (plan mode activado, sin edits) — Claude lee files, responde preguntas
2. **Plan** — Claude propone implementation plan; `Ctrl+G` abre el plan en editor para ajustar
3. **Implement** — switch out of plan mode, código, verifica
4. **Commit** — descriptive message + PR

**Skip plan mode cuando**: scope claro + small fix (typo, log line, rename).
**Use plan mode cuando**: uncertainty about approach, multiple files, unfamiliar code.

## 5 · Antes de construir: dar a Claude forma de verificar su trabajo

> *"Include tests, screenshots, or expected outputs so Claude can check itself. This is the single highest-leverage thing you can do."* [F5]

Comparación concreta:

| Vague | Verificable |
|---|---|
| "implement a function that validates email addresses" | "write validateEmail. test cases: user@example.com→true, invalid→false, user@.com→false. run tests after implementing" |
| "make the dashboard look better" | "[paste screenshot] implement this design. take screenshot of result, compare, list differences and fix" |
| "the build is failing" | "the build fails with this error: [paste]. fix it and verify the build succeeds. address the root cause, don't suppress" |

Sin verificación clara, *"you become the only feedback loop, and every mistake requires your attention"* [F5]. Con verificación, el agente itera autónomamente hasta converger.

## 6 · Decisión: agent dentro de Claude Code vs Claude Agent SDK standalone

Anthropic publica esta matriz [F2]:

| Use case | Best |
|---|---|
| Interactive development | Claude Code CLI |
| CI/CD pipelines | Agent SDK |
| Custom applications | Agent SDK |
| One-off tasks | Claude Code CLI |
| Production automation | Agent SDK |

*"Many teams use both: CLI for daily development, SDK for production. Workflows translate directly between them."* [F2]

Path típico: prototipar en CLI → cuando funciona, portar a SDK → si necesitas hosted runtime + sandbox isolation, mover a Managed Agents (REST API hosted por Anthropic).

## 7 · Diversidad de motor para alta confianza

Patrón validado en práctica: combinar Claude con cross-validation de otro motor (GPT-4o-mini, DeepSeek) reduce hallucinations en claims críticos. No es solo redundancia; es **divergencia controlada**: dos motores entrenados diferente que coinciden producen alta confianza, dos que difieren marcan claim como `contradicted` y deben ir a contradicciones-y-gaps.

---

## Si te llevas UNA cosa

**Antes de construir un agente, prueba con un single LLM call bien diseñado.** Solo escala a workflow → agent → multi-agent cuando el LLM call directo no resuelve el problema. Anthropic mismo dice: *"agentic systems often trade latency and cost for better task performance"* — el trade-off solo vale si la mejora es medible.
