# 08 · Calidad, costos y operaciones

> *Framework SMART para success criteria, 6 métodos eval canónicos, grading priorizado, edge cases obligatorios. Cost: pricing, un router multi-modelo, fan-out CLI, context engineering /clear y /compact.*

## Fuentes

- [F1] Define success criteria · https://platform.claude.com/docs/en/test-and-evaluate/define-success
- [F2] Best practices · context + cost · https://code.claude.com/docs/en/best-practices
- [F3] Common workflows · headless · https://code.claude.com/docs/en/common-workflows
- [F4] Prompt caching · https://platform.claude.com/docs/en/build-with-claude/prompt-caching
- [F5] Anthropic Context Engineering · https://www.anthropic.com/engineering/context-engineering

---

# Parte A · Calidad / evaluación

## A1 · Framework SMART de Anthropic [F1]

Good success criteria son:
- **Specific** — "accurate sentiment classification", no "good performance"
- **Measurable** — quantitative metrics o well-defined qualitative scales
- **Achievable** — basado en industry benchmarks, prior experiments, AI research
- **Relevant** — alineado con purpose de aplicación y user needs

Hasta temas "hazy" como ethics se pueden cuantificar:
> *"Less than 0.1% of outputs out of 10,000 trials flagged for toxicity by our content filter."* [F1]

## A2 · Common success criteria (multidimensional) [F1]

Evaluation across:
- Task fidelity (incluye edge cases)
- Consistency (similar input → similar output)
- Relevance and coherence
- Tone and style
- Privacy preservation
- Context utilization
- Latency
- Price

Ejemplo Multidimensional bueno:
> *"On a held-out test set of 10,000 diverse Twitter posts, our sentiment analysis model should achieve:
> - F1 score ≥ 0.85
> - 99.5% non-toxic outputs
> - 90% of errors are inconvenience (not egregious)
> - 95% response time < 200ms"* [F1]

## A3 · 3 eval design principles [F1]

1. **Task-specific** — evals que reflejen real-world task distribution + edge cases
2. **Automate when possible** — multiple-choice, string match, code-graded, LLM-graded
3. **Volume > quality** — more questions con automated grading > fewer high-quality human

## A4 · Los 6 métodos eval canónicos [F1]

| Método | Best for | Pros | Cons |
|---|---|---|---|
| **Exact match** | Categorical (sentiment) | Fast, unambiguous | Rigid, no nuance |
| **Cosine similarity (SBERT)** | Consistency (FAQ bot) | Captures semantic similarity | Needs embeddings infra |
| **ROUGE-L** | Summarization quality | Measures coherent overlap | Bag-of-words bias |
| **LLM-Likert (1-5)** | Tone, subjective | Captures empathy/professionalism | LLM judge variance |
| **LLM binary** | Privacy (PHI detection) | Context-aware | LLM judge cost |
| **LLM ordinal** | Context utilization | Multi-turn aware | Needs detailed rubric |

## A5 · Grading methods priorizados [F1]

1. **Code-based grading** — most reliable, scalable, lacks nuance
 - Exact match: `output == golden_answer`
 - String match: `key_phrase in output`
2. **Human grading** — most flexible/quality, slow/expensive · AVOID if possible
3. **LLM-based grading** — fast, flexible, scalable, suitable for complex judgement · TEST reliability first

## A6 · Tips LLM-based grading [F1]

- **Detailed clear rubrics** — "The answer should always mention 'Acme Inc.' in the first sentence. If not → 'incorrect'."
- **Empirical/specific output** — "Output only 'correct' or 'incorrect'" o 1-5
- **Encourage reasoning** — `<thinking>` then `<result>` tags; discard reasoning post-extraction
- **Use DIFFERENT model** to grade vs generate (avoid self-rating bias)

Ejemplo canónico [F1]:
```python
def build_grader_prompt(answer, rubric):
 return f"""Grade this answer based on the rubric:
 <rubric>{rubric}</rubric>
 <answer>{answer}</answer>
 Think through your reasoning in <thinking> tags, then output 'correct' or 'incorrect' in <result> tags."""
```

## A7 · Edge cases obligatorios al diseñar evals [F1]

1. Irrelevant/nonexistent input data
2. Overly long input data o user input
3. Poor, harmful, irrelevant user input (chat use cases)
4. Ambiguous test cases donde even humans no llegarían a consensus

## A8 · Verification dentro del agentic loop [F2]

> *"Include tests, screenshots, or expected outputs so Claude can check itself. This is the single highest-leverage thing you can do."*

Trade-off ahorrado: sin verificación clara, *"you become the only feedback loop, and every mistake requires your attention"*. Con verificación, el agente itera autónomamente hasta converger.

Verification puede ser:
- Test suite que Claude corre
- Linter
- Bash command que checa output
- Screenshot comparison (Claude in Chrome extension)
- Plain assertion: "must include phrase X in response"

---

# Parte B · Costos y operaciones

## B1 · Pricing Claude (2026 referencias) [F4]

### B1.1 · Opus 4.7

| Token type | $/1M tokens |
|---|---|
| Base input | $5 |
| 5m cache write | $6.25 |
| 1h cache write | $10 |
| Cache hit/refresh | $0.50 |
| Output | $25 |

### B1.2 · Tendencias relevantes

- Sonnet típicamente ~5x más barato que Opus
- Haiku típicamente ~5x más barato que Sonnet
- Cache hit es ALWAYS 0.1x de base input

## B2 · un router multi-modelo (patrón Smart4AI)

Patrón validado en Smart4AI: rutear por tarea según el motor más eficiente:

| Tarea | Modelo recomendado | Por qué |
|---|---|---|
| Critical reasoning, scope decomposition | Opus 4.7 | Razonamiento complejo, justifica costo |
| Refinement, claim extraction (con cache) | Sonnet 4.6 | Balance cost/quality, cache hit 90% off |
| Bulk indexing, classification | DeepSeek V3.2 | 95% más barato, mechanical tasks |
| Cross-validation, second opinion | GPT-4o-mini | Diversidad de motor, 17x más barato que GPT-4o |
| Long context synthesis (200K+) | Kimi K2.6 | 256K context, 4x más barato que Sonnet long |
| Free MCPs | Perplexity, Gemini Deep Research, NotebookLM | $0 |

**Ahorros típicos 60-80% vs all-Opus.**

## B3 · Permission modes para cost control [F2]

`auto` mode usa classifier que blocks risky, evitando interruptions Y reduciendo prompts costosos. Sandboxing OS-level reduce necesidad de approvals manuales.

```json
"permissions": {"defaultMode": "auto"}
```

Trade-off: cuando classifier blockea, eliminar approval del user puede causar el agente parar en non-interactive mode.

## B4 · Context engineering reduce costo [F2][F5]

2 formas:

**(a) `/clear` entre tasks irrelevantes**: evita que context acumule history irrelevante → cada llamada paga por context inflado.

**(b) `/compact <instructions>`**: focused summarization conservando código clave. Auto-compaction triggera cerca del límite preservando code patterns y key decisions.

> *"Context window is the most important resource to manage."* [F2]

## B5 · Pattern fan-out en CLI (cost amortization) [F3]

Para migrations o analyses masivas:

```bash
# 1. Generate task list
claude -p "list all 2,000 Python files that need migrating" > files.txt

# 2. Script loop con --allowedTools scoped
for file in $(cat files.txt); do
 claude -p "Migrate $file from React to Vue. Return OK or FAIL." \
 --allowedTools "Edit,Bash(git commit *)"
done
```

**Tip oficial** [F3]: test on 2-3 archivos primero, refine prompt basado en lo que falla, then run on full set. `--allowedTools` restringe lo que Claude puede hacer (matters en unattended runs).

## B6 · Output formats para parsing programático [F3]

```bash
claude -p "Explain what this project does" # text
claude -p "List all API endpoints" --output-format json # JSON
claude -p "Analyze this log file" --output-format stream-json # streaming
```

Streaming format permite real-time processing y mejor UX en sub-segundos.

## B7 · Receipts y budget tracking patrón

Pattern Smart4AI: cada agent run crea `budget_tracker.json` con entradas por stage:

```json
{
 "run_id": "inv_X_2026-05-19",
 "budget_limit_usd": 4.00,
 "cumulative_cost_usd": 0.85,
 "entries": [
 {"stage": "S0", "task": "filesystem", "model": "n/a", "cost_usd": 0.00},
 {"stage": "S1_scope", "task": "critical-reasoning", "model": "claude-opus-4-7", "tokens_in": 3500, "tokens_out": 4500, "cost_usd_est": 0.15},
 ...
 ]
}
```

Beneficios:
- BudgetTracker kills run si supera limit
- Push a Notion Receipts para audit trail
- Permite comparar costos entre runs y detectar regresiones

## B8 · Run autonomously con auto mode [F2]

```bash
claude --permission-mode auto -p "fix all lint errors"
```

Para non-interactive con `-p`: auto mode aborts si classifier bloquea repeatedly (no hay user fallback).

## B9 · Cost-aware patterns combinados

### Pattern · Explore-then-commit Haiku
1. Sub-agent Haiku para exploration ($0.40/1M tokens vs Opus $5/1M = 12.5x ahorro)
2. Sub-agent retorna summary
3. Main session Opus toma decisión basada en summary

### Pattern · Cache pre-warm para production agent
1. Pre-warm system prompt cache al startup (1 write = $0.0625 para 5K tokens)
2. User requests subsecuentes son cache hits (90% off)
3. Refresh cache cada 5 minutos sin costo

### Pattern · Cross-validation con motor barato
1. Claude Opus genera claim
2. GPT-4o-mini ($0.15/1M input) cross-valida
3. Si discrepan → marca contradicted, no publica

## B10 · Anti-patterns cost

❌ Llamar Opus para tareas mecánicas (clasificación, tagging) cuando Haiku sirve
❌ No cache_control en system prompts grandes repetidos
❌ Running con `--output-format stream-json` sin necesidad (sobrehead parsing)
❌ Sub-agent invocado para trivia (<3 file reads) — overhead supera el savings
❌ No `/clear` entre tasks → context inflado paga base input cada turn
❌ Skipping `web_search` antes de invocar paquete npm/pip → Claude inventa nombres (AP-3)
❌ Usar `ANTHROPIC_API_KEY` directo en Claude Code con plan Max → cobra API ($5+ pérdida observada en Smart4AI)

---

## Si te llevas UNA cosa

**El framework de evaluación es la única forma de SABER si tu agente está mejorando o regresionando.** Sin evals SMART + edge cases + grading priorizado, cada cambio en system prompt es fe ciega. Y para producción, mide cache hit rate como métrica #1 de costo: si está bajo 70%, hay leverage masivo sin tocar el agente.
