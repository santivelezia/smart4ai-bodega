# Categoría 4 · Frameworks de Evaluación y CI/CD para Agentes
> Sub-preguntas: B1 (frameworks SOTA), B5 (automatización pre-producción)

---

## B1 · Frameworks de Evaluación SOTA 2026

### Tabla comparativa

| Framework | Evalúa | Pricing (est. 2026) | Setup | Mejor para |
|---|---|---|---|---|
| **Promptfoo** | Prompt evals, CI/CD gates, multi-model comparison | Open source + hosted | Bajo (YAML config) | CI/CD gates, PR blocks, rápido setup [F18] |
| **Braintrust** | Trace-level scoring, PR comments, A/B comparisons | Freemium + enterprise | Medio | Comparación de versiones, span-level eval [F18] |
| **LangSmith** | Traces LangChain, offline+online evals, pytest-style | $39/mes Developer → Enterprise | Alto si no usas LangChain | Agentes LangChain, observabilidad completa [F18] |
| **Langfuse** | Observabilidad, prompt versioning, cost tracking | Open source + cloud | Bajo-medio | Teams que quieren self-hosted [F18] |
| **Agentops** | Agent traces, session tracking, cost per run | Freemium | Bajo | Monitoreo rápido sin heavy setup [F18] |
| **Inspect (UK AISI)** | Safety evals, red-teaming, government-grade | Open source | Alto | Evaluación de safety/alignment [F18] |
| **DeepEval** | Unit-test style para LLM outputs, synthetic data | Open source + cloud | Bajo | Developers que prefieren Python pytest [F18] |
| **Phoenix (Arize)** | ML observability, LLM traces, drift detection | Freemium + enterprise | Medio | Producción con drift monitoring [F18] |

### Cuándo usar qué

**Para CI/CD gates (PR blocks)** → **Promptfoo** [F18]
- Integración nativa con GitHub Actions en minutos
- `--fail-on-error` bloquea merge automáticamente
- Output en JSON/JUnit/HTML para artifacts CI
- Costo de un eval run ~$0.64 con 20 conversations (frontier models) [F18]

**Para comparación A/B de versiones** → **Braintrust** [F18]
- Post PR comment con score table automáticamente
- Span-level evaluation (scoring de cada reasoning step)
- `use_proxy: true` cachea llamadas repetitivas (ahorra costo)

**Para observabilidad de producción** → **Langfuse** o **Phoenix (Arize)** [F18]
- Drift detection en producción
- Self-hosted si compliance lo requiere

**Para agentes en LangChain/LangGraph** → **LangSmith** [F18]
- Offline evals: code-based graders baratos para cada commit
- Online evals: LLM-as-judge reservado para preview/production

### Costos reales de evaluación nightly [F18]
- 4 runs nightly × 20 conversations × frontier model ≈ $2.56/noche = **$75/mes**
- Optimización: `cancel-in-progress: true` para cancelar runs viejos en nuevos commits
- Caching de prompts reduce token usage significativamente

---

## B5 · Automatizar Validación Pre-Producción: CI/CD para Agentes

### Patrón de Eval Gate en CI/CD [F18]

El principio: **los evals como gate de deployment**, no como herramienta de debugging posterior.

```
PR abierto → [Eval run automático] → [¿Pass rate ≥95%?]
 → NO → CI falla · merge bloqueado
 → SÍ → CI pasa · merge permitido
 → [Deploy a preview]
 → [Eval online en producción]
```

### Implementación con Promptfoo + GitHub Actions [F18]

```yaml
# .github/workflows/agent-eval-gate.yml
name: Agent Eval Gate

on:
 pull_request:
 paths:
 - 'agents/**'
 - 'prompts/**'
 - 'promptfooconfig.yaml'

jobs:
 evaluate:
 runs-on: ubuntu-latest
 steps:
 - uses: actions/checkout@v4
 
 - uses: actions/setup-node@v4
 with:
 node-version: '22'
 cache: 'npm'
 
 - name: Cache promptfoo results
 uses: actions/cache@v4
 with:
 path: ~/.cache/promptfoo
 key: ${{ runner.os }}-promptfoo-${{ hashFiles('prompts/**') }}
 
 - name: Run eval
 env:
 OPENAI_API_KEY: ${{ secrets.OPENAI_API_KEY }}
 ANTHROPIC_API_KEY: ${{ secrets.ANTHROPIC_API_KEY }}
 PROMPTFOO_CACHE_PATH: ~/.cache/promptfoo
 run: |
 npx promptfoo@latest eval \
 -c promptfooconfig.yaml \
 -o results.json \
 -o report.html \
 -o results.junit.xml
 
 - name: Enforce quality gate (95% pass rate)
 run: |
 FAILURES=$(jq '.results.stats.failures' results.json)
 TOTAL=$(( $(jq '.results.stats.successes' results.json) + FAILURES ))
 PASS_RATE=$(echo "scale=2; $(jq '.results.stats.successes' results.json) * 100 / $TOTAL" | bc)
 if [ "$FAILURES" -gt 0 ]; then
 echo "❌ Gate failed: $FAILURES failures (Pass rate: ${PASS_RATE}%)"
 exit 1
 fi
 echo "✅ All tests passed! Pass rate: ${PASS_RATE}%"
 
 - name: Upload artifacts
 if: always()
 uses: actions/upload-artifact@v4
 with:
 name: eval-results-${{ github.sha }}
 retention-days: 30
 path: results.json report.html results.junit.xml
```

### Implementación con Braintrust CI [F18]

```yaml
- name: Run Evals with Braintrust
 uses: braintrustdata/eval-action@v1
 with:
 api_key: ${{ secrets.BRAINTRUST_API_KEY }}
 runtime: node # or python
 root: evals/
 terminate_on_failure: true # bloquea merge si falla
 use_proxy: true # cachea LLM calls repetitivas
```

### Separación Capability Evals vs. Regression Evals [F18]
Distinción crítica para CI eficiente:

| Tipo | Propósito | Pass rate esperado | Cuándo correr |
|---|---|---|---|
| **Regression evals** | Proteger comportamiento existente | ~100% | Cada PR |
| **Capability evals** | Medir progreso en tareas difíciles | ~30-70% | Nightly |

- Regression evals en CI: rápidos, baratos, code-based graders
- Capability evals nightly: más conversaciones, múltiples modelos, LLM-as-judge

### Número de trials por tarea [F18]
- Correr 3-5 trials por tarea para compensar no-determinismo del LLM
- Si 3/5 trials pasan → tarea pasa
- Alertar si varianza entre trials es alta (señal de prompt inestable)

### Patrón Nightly para Agentes en Producción [F18]
- Red Hat recomienda: 20 conversations generadas nightly, $0.64/run con frontier models
- 4 workflows nightly ≈ $2.56/noche → **$75/mes** para un agente de producción
- Log failures nightly en spreadsheet para detectar rising error rates

**Implicación ALAN v2.0**: Todo agente generado por ALAN debe tener al mínimo un `promptfooconfig.yaml` con 10-20 test cases, y ese config debe correr en CI antes de que ALAN lo marque como `done`. ALAN puede generar este config automáticamente desde el brief.

**Si te llevas UNA cosa**: Promptfoo en CI con `--fail-on-error` y threshold 95% es el setup mínimo viable. Cuesta $0.64/run y bloquea regresiones antes de que lleguen a producción.
