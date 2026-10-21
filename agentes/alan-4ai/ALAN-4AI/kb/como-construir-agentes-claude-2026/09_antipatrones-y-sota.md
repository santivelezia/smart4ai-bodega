# 09 · Anti-patrones canónicos y SOTA 2024-2026

> *5 anti-patterns canónicos Anthropic + anti-patterns específicos (skills, sub-agents, security). SOTA papers HF: surveys, benchmarks, architectures, safety. Frameworks comerciales. Research priorities Anthropic 2026.*

## Fuentes

- [F1] Best practices · failure patterns · https://code.claude.com/docs/en/best-practices
- [F2] Building effective agents · anti-patterns · https://www.anthropic.com/engineering/building-effective-agents
- [F3] Skills lifecycle · https://code.claude.com/docs/en/skills
- [F4] Sub-agents · https://code.claude.com/docs/en/sub-agents
- [F5] Anthropic Research index · https://www.anthropic.com/research
- [F6] HF Papers · From LLM Reasoning to Autonomous AI Agents · https://hf.co/papers/2504.19678
- [F7] HF Papers · MALT · https://hf.co/papers/2412.01928
- [F8] HF Papers · CoPlanner · https://hf.co/papers/2410.20007
- [F9] HF Papers · LaRMA · https://hf.co/papers/2503.11074
- [F10] HF Papers · FutureX · https://hf.co/papers/2508.11987
- [F11] HF Papers · FlowBench · https://hf.co/papers/2406.14884
- [F12] HF Papers · TrustAgent · https://hf.co/papers/2402.01586
- [F13] HF Papers · PlanGenLLMs survey · https://hf.co/papers/2502.11221
- [F14] HF Papers · ThinkGeo · https://hf.co/papers/2505.23752

---

# Parte A · Anti-patrones canónicos

## A1 · Los 5 failure patterns oficiales de Anthropic [F1]

### 1. The kitchen sink session
> *"You start with one task, then ask Claude something unrelated, then go back to the first task. Context is full of irrelevant information."*
**Fix**: `/clear` entre unrelated tasks.

### 2. Correcting over and over
> *"Claude does something wrong, you correct it, it's still wrong, you correct again. Context is polluted with failed approaches."*
**Fix**: Después de 2 failed corrections, `/clear` y write better initial prompt incorporating what you learned.

### 3. The over-specified CLAUDE.md
> *"If your CLAUDE.md is too long, Claude ignores half of it because important rules get lost in the noise."*
**Fix**: Ruthlessly prune. If Claude already does something correctly without the instruction, delete it or convert to a hook.

### 4. The trust-then-verify gap
> *"Claude produces a plausible-looking implementation that doesn't handle edge cases."*
**Fix**: Always provide verification (tests, scripts, screenshots). *"If you can't verify it, don't ship it."*

### 5. The infinite exploration
> *"You ask Claude to 'investigate' something without scoping it. Claude reads hundreds of files, filling the context."*
**Fix**: Scope investigations narrowly o use sub-agents (exploration NO consume main context).

## A2 · Anti-patterns frameworks [F2]

3 anti-patterns explícitos de Anthropic sobre frameworks de agentes:

1. **Framework over-reliance**: *"Frameworks often create extra layers of abstraction that can obscure the underlying prompts and responses, making them harder to debug."*

2. **Complexity creep**: *"Frameworks can also make it tempting to add complexity when a simpler setup would suffice."*

3. **Black-box assumptions**: *"Incorrect assumptions about what's under the hood are a common source of customer error."*

Aplicación: si el framework dificulta inspeccionar el prompt final que llega al modelo, descártalo o sácalo de la lista de candidatos.

## A3 · Anti-patterns specifically para Skills [F3]

❌ **SKILL.md body largo** → cada línea es recurring token cost (lifecycle: skill stays in context for the rest of the session). Recomendación: *"Keep SKILL.md under 500 lines. Move detailed reference material to separate files."*

❌ **Description sin keywords claros** que user would say naturally → Claude no sabe cuándo cargar el skill auto.

❌ **`context: fork` sin task explícita** → *"the subagent receives the guidelines but no actionable prompt, and returns without meaningful output"*.

❌ **Description larga > 1,536 chars** → keywords críticos se truncan en el listing.

## A4 · Anti-patterns Sub-agents [F4]

❌ **Description vaga** → Claude no sabe cuándo delegar
❌ **Tools list demasiado amplia** → mismo context cost que main agent
❌ **Trivial task subagent** (<3 file reads) → overhead supera savings
❌ **Subagent writes a FS sin permiso** → rompe sandbox de exploración

## A5 · Anti-patterns security [F3]

❌ **Trust skill checked-in en repo sin review** — *"a skill can grant itself broad tool access via `allowed-tools`"*. Mitigation: review project skills antes de trustear workspace.

❌ **MCP server without permission scoping** — granting `MCP(filesystem)` global permite writes anywhere. Mejor: granular `MCP(filesystem:read)`.

❌ **Bypass permissions sin contexto** — bypassPermissions mode SIGUE ejecutando hooks, pero confiar en ellos como única defensa es frágil.

## A6 · Anti-pattern descubierto en práctica Smart4AI 2026

❌ **Usar `ANTHROPIC_API_KEY` directamente para Claude Code cuando user tiene plan Max** → cobra API saldo innecesariamente.

Solución (validada después de $5 USD quemados accidentalmente):
- Con plan Max, evita configurar `ANTHROPIC_API_KEY` directa en Claude Code (se cobraría API)
- Claude Code no detecta auto la nueva variable
- un router multi-modelo en `(infraestructura interna)adapters/claude.ts` lee la variable explícitamente

Regla complementaria: **antes de cualquier operación que cueste >$1 USD, advertir explícitamente con costo estimado al user**.

## A7 · Anti-pattern planning hallucinations [F7][F8][F11]

Descubierto en papers MALT, CoPlanner, FlowBench:
- Single LLM haciendo planning + execution sin verifier → planning hallucinations frecuentes
- Solución SOTA: **separated planning agent + verifier agent dedicated**

Aplicación para agentes Claude: usa el patrón orchestrator-worker con un sub-agent dedicado a verificación de plan antes de execution.

## A8 · Anti-pattern verificación insuficiente [F1]

> *"Claude produces a plausible-looking implementation that doesn't handle edge cases."*

Mitigation explícita: *"Always provide verification (tests, scripts, screenshots). If you can't verify it, don't ship it."*

---

# Parte B · State of the art 2024-2026

## B1 · Surveys CANON [F6][F13]

### B1.1 · From LLM Reasoning to Autonomous AI Agents (Abril 2025) [F6]

Taxonomía de evaluation benchmarks + frameworks para autonomous AI agents. Cubre:
- Knowledge reasoning
- Math problem-solving
- Code generation
- Software engineering
- Factual grounding
- Domain-specific evaluations
- Multimodal tasks
- Embodied tasks

Menciona explícitamente tres protocolos emergentes:
- **Agent Communication Protocol (ACP)**
- **Model Context Protocol (MCP)** — el más maduro y adoptado
- **Agent-to-Agent Protocol (A2A)**

### B1.2 · PlanGenLLMs (Febrero 2025) [F13]

Survey de LLM planners across:
- Completeness
- Executability
- Optimality
- Representation
- Generalization
- Efficiency

Domains: web navigation, travel planning, database querying.

## B2 · Architectures emergentes

### B2.1 · MALT (Diciembre 2024) [F7]

Sequential multi-agent setup con heterogeneous LLMs:
- **Generator** propone solución
- **Verifier** valida
- **Refinement model** corrige

Joint outcome-based rewards. Llama 3.1 8B. Improves MATH, GSM8k, CQA vs single agent.

**Insight**: trajectory-expansion + credit-assignment strategy clave para training cooperative multi-agent.

### B2.2 · CoPlanner (Octubre 2024) [F8]

Cooperative multi-agent con:
- **Planning agent** entrenado via PPO
- **Reasoning agent** ejecuta plan

LLaMA-3-8B. Benchmark: LogiQA, BBH. Demuestra que separar planning de reasoning mejora multi-step problems.

### B2.3 · LaRMA · LRM vs LLM en agent scenarios (Marzo 2025) [F9]

Framework para evaluar Large Reasoning Models (LRM, ej DeepSeek-R1) vs LLMs.

**Findings**:
- LRMs superiores en reasoning
- LLMs superiores en execution
- **Hybrid LLM-LRM es óptimo**

**Caveats documentados**:
- Computational cost alto
- Overthinking en LRMs
- Fact-ignoring tendencies

### B2.4 · AgentLite (Febrero 2024)

Library open-source para reasoning strategies + agent architectures. Soporta chain-of-thought, ReAct, Reflection. Single + multi-agent group chat.

## B3 · Benchmarks importantes [F10][F11][F14]

### B3.1 · FutureX (Agosto 2025) [F10]

Dynamic, live benchmark para LLM agents en future prediction. **Aborda**:
- Real-time updates
- Data contamination
- Temporal validity

Failure modes documentados. Adaptive reasoning challenges.

### B3.2 · ThinkGeo (Abril 2026) [F14]

Tool-augmented agents para remote sensing tasks. ReAct-style interaction loop. Multi-step planning + structured tool use. Domain: urban planning, disaster assessment con satellite imagery (RGB + SAR).

Demonstrates que agents superan single-LLM en domain-specific tasks complejas.

### B3.3 · FlowBench (Junio 2024) [F11]

Benchmark workflow-guided planning para LLM agents. Identifica **"planning hallucinations"** como falla común. Confirma que workflow-guided > pure autonomy para tasks complejas.

### B3.4 · PlanBench (foundational, 2022)

Benchmark canónico para planning capabilities. Highlights gaps vs state-of-the-art planning solvers de IA clásica. Sigue siendo referenciado en 2026.

## B4 · Safety / alignment

### B4.1 · TrustAgent (Octubre 2024) [F12]

Agent Constitution con strategies en 3 fases:
- **Pre-planning**: constraints antes de generar plan
- **In-planning**: check during plan generation
- **Post-planning**: verify después

Trade-off documentado: safety vs helpfulness.

## B5 · Research priorities Anthropic 2025-2026 [F5]

| Fecha | Título | Foco |
|---|---|---|
| 2026-05-08 | Teaching Claude why | Reducir agentic misalignment. Diseño de agentes que entienden el "por qué" de su comportamiento. |
| 2026-04-24 | Project Deal | Claude autonomously negotiated/transacted en marketplace. Demo de agentic capability open-ended. |
| 2026-04-14 | Automated Alignment Researchers | Using LLMs para scalable oversight de AI systems. Multi-agent para alignment. |
| 2025-12-18 | Project Vend phase 2 | AI shopkeeper experiment phase 2. Real-world task completion. |

**Tema común**: long-horizon autonomy + alignment + scalable oversight.

## B6 · Patrones convergentes SOTA (síntesis 2024-2026)

[INFERENCIA basada en análisis cruzado de los papers anteriores]

1. **Planner/Executor split** (CoPlanner, MALT, LaRMA) — separar planning de execution mejora reasoning sin perder performance
2. **Verifier agents dedicated** (MALT) — verifier dedicado captura errors antes de output
3. **Workflow-guided > pure autonomy** (FlowBench) — structured workflows reducen planning hallucinations
4. **Tool-augmented + ReAct loop** (ThinkGeo, AgentLite) — patrón dominante para external data tasks
5. **Hybrid LRM + LLM** (LaRMA) — combina lo mejor de cada uno
6. **Protocol convergence** — ACP + MCP + A2A emergiendo como standards
7. **Live benchmarks > static** (FutureX) — contamination + temporal validity son problemas reales

## B7 · Frameworks comerciales comparativos 2026

[INFERENCIA · rankings cambian rápidamente]

| Framework | Origen | Foco | Estado 2026 |
|---|---|---|---|
| Claude Agent SDK | Anthropic | Code-first agents con Claude Code tooling | Estable; June 2026 nuevos credits |
| LangGraph | LangChain | State machine multi-agent | Mature, lang-agnostic |
| CrewAI | Independent | Role-based multi-agent | Growing, no formal eval |
| AutoGen | Microsoft | Conversation-based multi-agent | Mature, MS-backed |
| AgentLite | Salesforce research | Lightweight task-oriented | Research library |
| LlamaIndex Agents | LlamaIndex | RAG-centric | Mature en RAG space |

## B8 · Gaps observados vs práctica Smart4AI

| Patrón SOTA | Status Smart4AI 2026-05-19 |
|---|---|
| Orchestrator-worker | ✅ Usado (Agente Investigador Profundo, Agente Productor) |
| ReAct loop explícito | ❌ Implícito en Claude Code Agent tool, no codificado |
| Reflection (auto-crítica) | ❌ No usado deliberadamente |
| Ensemble multi-LLM | ✅ Cross-validation Stage 6 con GPT-4o-mini |
| Planner/Executor split | ❌ Single agent hace ambos roles |
| Verifier dedicado | ✅ Quality audit Stage 11 lo hace |
| Hybrid LRM + LLM | ❌ DeepSeek V3.2 usado pero no como LRM |
| MCP adoption | ✅ Pesado (Perplexity, Gemini, Notion, etc.) |
| Skills construido propio | ❌ Pendiente — gap del brief |
| Live benchmarks | ❌ Eval ad-hoc, no continuos |

---

## Si te llevas UNA cosa

**Los 5 anti-patterns canónicos de Anthropic NO son "errores principiantes" — son traps en los que todos caemos repetidamente porque sienten productivos.** Kitchen sink session se siente como progress. Correcting twice se siente como debugging. Over-specified CLAUDE.md se siente como rigor. La única defensa es disciplina deliberada: `/clear` agresivo, prune ruthless de CLAUDE.md, verification gates obligatorios, y nunca shipear lo que no puedes verificar.
