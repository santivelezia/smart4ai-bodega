# Categoría 5 · LLM-as-Judge y Behavioral/Trace Evaluation
> Sub-preguntas: B2 (LLM-as-judge correctamente), B3 (trace eval y regression suites)

---

## B2 · LLM-as-Judge Correctamente: Evitar Biases

### Los 12 tipos de bias documentados (CALM framework) [F19]
"Justice or Prejudice? Quantifying Biases in LLM-as-a-Judge" (arXiv 2410.02736) identifica 12 biases:
1. **Positional bias** — favorece respuestas según su posición en el prompt (el más documentado)
2. **Verbosity bias** — favorece respuestas más largas independientemente de calidad
3. **Sycophancy/self-rating bias** — Claude juzgando Claude outputs da scores inflados sistemáticamente
4. **Central tendency effect** — comprime predicciones hacia el centro de la escala (evita extremos) [F20]
5. **Authority bias** — favorece respuestas atribuidas a fuentes de mayor status
6. **Familiarity bias** — favorece estilo similar al propio training data del judge
7. **Recency bias** — sobrepondera respuestas recientes en multi-turn
8. Y 5 más documentados en CALM

**Resultado crítico** (JudgeBench-Pro, arXiv 2602.09383): incluso los LLMs más potentes muestran error rates >50% en evaluación robusta con biases. No es un problema resuelto [F21].

### Cómo hacer LLM-as-judge correctamente (mitigaciones concretas)

#### Mitigación 1: Multi-Judge Panel Heterogéneo [F19]
El estándar de facto en 2026:
- Mínimo 3 jueces de proveedores distintos: Claude + GPT + Gemini (o Llama)
- Voting mayoritario: la respuesta que 2/3 jueces prefieren gana
- **NUNCA** Claude juzgando outputs de Claude — introduce sycophancy bias sistemático

```python
class MultiJudgePanel:
 def __init__(self, judges: list[LLMJudge]):
 # Regla: los jueces deben ser de proveedores distintos
 assert len({j.provider for j in judges}) == len(judges), \
 "Todos los jueces deben ser de proveedores distintos"
 self.judges = judges
 
 async def evaluate(self, question: str, answer: str, rubric: str) -> JudgeResult:
 scores = await asyncio.gather(*[
 j.score(question, answer, rubric) for j in self.judges
 ])
 
 # Majority voting
 passed = sum(1 for s in scores if s.passed) >= len(self.judges) // 2 + 1
 avg_score = sum(s.score for s in scores) / len(scores)
 
 return JudgeResult(passed=passed, score=avg_score, individual_scores=scores)
```

#### Mitigación 2: Rúbricas Estructuradas con Criterios Binarios [F19]
- Evitar escalas de 1-10 genéricas (sufren de central tendency effect)
- Preferir criterios binarios específicos: "¿La respuesta cita al menos 1 fuente verificable? Sí/No"
- Cada criterio de la rúbrica debe ser independientemente evaluable

```
RUBRICA PARA AGENTE INVESTIGADOR:
□ Criterio 1 (peso 25%): Cada claim tiene fuente trazable [Sí=1, No=0]
□ Criterio 2 (peso 25%): La respuesta responde la pregunta sin off-topic [Sí=1, No=0] 
□ Criterio 3 (peso 25%): No hay alucinaciones detectables [Sí=1, No=0]
□ Criterio 4 (peso 25%): El formato es el solicitado [Sí=1, No=0]
Score final = suma ponderada. Pasa si score ≥ 0.75
```

#### Mitigación 3: Positional Bias — Randomizar el Orden [F22]
"Judging the Judges" (arXiv 2406.07791): positional bias varía significativamente entre judges y tareas.
- Randomizar qué respuesta aparece primero en comparaciones pairwise
- Correr cada comparación 2 veces con orden invertido y promediar
- La 3 métrica de "repetition stability": si el judge cambia de opinión al invertir el orden, el score es inestable

#### Mitigación 4: Proveer Reference Answer de Alta Calidad [F23]
"No Free Labels" (arXiv 2503.05061): un judge débil con referencia de alta calidad supera a un judge fuerte sin referencia.
- Proveer siempre la "golden answer" como contexto al judge
- Si no existe golden answer, el judge debe declarar incertidumbre, no inventar

#### Mitigación 5: Quantitative Judge Calibration [F24]
"Quantitative LLM Judges" (arXiv 2506.02945, jun 2025):
- Usar regression post-hoc para alinear scores del judge con scores humanos
- Más eficiente que fine-tuning: entrena solo el calibrador, no el judge completo
- Mejora predictive power sin cambiar el judge base

### AgentRewardBench: Evaluando los Evaluadores de Agentes [F25]
Paper: arXiv 2504.08942 — primer benchmark para evaluar LLM judges de agentes web.
- 1302 trayectorias × 5 benchmarks × 4 LLMs
- Hallazgo: ningún LLM judge es excelente en todos los benchmarks
- Los métodos rule-based subestiman consistentemente la tasa de éxito de agentes web
- Implicación: combinar LLM judge + rule-based eval, nunca solo uno

---

## B3 · Behavioral/Trace Evaluation y Regression Suites

### Qué es Trace Evaluation

[F26] Una traza registra CADA paso del agente: tool calls, argumentos, reasoning intermedio, latency, token usage. Trace evaluation evalúa el PROCESO, no solo el resultado final.

Dimensiones de evaluación por traza:

| Dimensión | Qué evalúa |
|---|---|
| Tool correctness | ¿Eligió la herramienta correcta? |
| Argument validity | ¿Los argumentos del tool call eran correctos? |
| Step efficiency | ¿El número de pasos es razonable? ¿Costo/tiempo aceptable? |
| Policy compliance | ¿Siguió las reglas de safety/guardrails? |
| Plan alignment | ¿El plan inicial coincide con el objetivo? |

### Paper clave: Structural Testing de Agentes LLM [F27]
"Automated structural testing of LLM-based agents" (arXiv 2601.18827, ene 2026):
- Usa **OpenTelemetry** para capturar trayectorias de agentes
- **Mocking** para hacer el comportamiento del LLM reproducible (deterministic testing)
- **Assertions** para verificar automáticamente el comportamiento esperado
- Permite: test automation pyramid, regression testing, TDD, multi-language testing
- Reduce costos de testing y mejora coverage con earlier defect detection
- Código disponible: GitHub (open source)

### Cómo construir Regression Suites para Agentes

```python
# Patrón de regression suite con pytest + LangSmith
import pytest
from langsmith import Client

class AgentRegressionSuite:
 def __init__(self, agent, golden_dataset_name: str):
 self.agent = agent
 self.client = Client()
 self.golden_dataset = self.client.read_dataset(name=golden_dataset_name)
 
 @pytest.mark.parametrize("example", golden_dataset.examples)
 async def test_regression(self, example):
 result = await self.agent.run(example.input)
 
 # Checks de regresión (no LLM judge — code-based para CI)
 assert result.tool_calls == example.expected_tool_calls, \
 f"Tool call mismatch: {result.tool_calls} != {example.expected_tool_calls}"
 assert not result.has_malformed_args, "Malformed tool arguments detected"
 assert result.task_completed, "Task did not complete successfully"
 assert result.latency_ms < 5000, f"Latency too high: {result.latency_ms}ms"
```

### Estructura del Golden Dataset [F26]

```
Golden Set (100-200 casos críticos para release decisions):
├── critical_scenarios/ ← Escenarios donde el agente ha fallado antes
├── representative_cases/ ← Top 5 task types del uso real
├── edge_cases/ ← Inputs extremos/incompletos/ambiguos
└── regression_cases/ ← Bugs específicos que se han corregido

Broader Scenario Library:
└── discovery/ ← Casos para diagnóstico, no gates de release

Quarantine Area:
└── new_failures/ ← Fallos de producción pendientes de clasificar
```

**Protocolo de mantenimiento** [F26]:
- Añadir ejemplos de producción semanalmente
- Auditoria mensual de relevancia
- Refresh trimestral completo

### Generando Synthetic Eval Datasets [F26]

| Técnica | Cómo | Cuándo |
|---|---|---|
| LLM-powered generation | GPT-5/Opus genera QA pairs para escenarios del brief | Cuando no hay datos de producción |
| Persona-based simulation | Test con diferentes tipos de usuarios (técnico/no técnico) | Agentes de conversación |
| Adversarial generation | Probar debilidades con edge cases | Siempre — como complement |
| Scenario libraries | Interacciones realistas desde escenarios predefinidos | Setup inicial |

**Best practice**: Combinar synthetic (cobertura de escenarios) + production logs (realismo) + expert-curated (casos críticos) [F26]

### Detección de Agent Behavioral Drift en Producción [F26]

- **Prediction drift**: monitorear distribución de outputs vs. baseline
- **Data drift**: monitorear distribución de inputs que recibe el agente
- **Concept drift**: el contexto del dominio cambió (external, no el agente)
- Tool: Galileo Signals automatiza análisis de failure modes en trazas de producción
- Alertar si: hallucination rate sube >3%, tool-call accuracy cae >5%, TSR cae >3%

**Implicación ALAN v2.0**: ALAN debe generar automáticamente un golden_dataset inicial de 20-50 casos desde el brief, más un `pytest`-based regression suite. El agente no se marca como "done" hasta que el regression suite pasa 100%.

**Si te llevas UNA cosa**: La trace evaluation (OpenTelemetry + mocking + assertions) convierte el testing de agentes de arte oscura en ingeniería estándar. Implementarla desde el inicio cuesta 2x más; no implementarla cuesta 10x más en producción.
