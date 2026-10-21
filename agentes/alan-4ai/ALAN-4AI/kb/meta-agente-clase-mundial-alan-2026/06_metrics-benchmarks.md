# Categoría 6 · Métricas y Benchmarks para Calidad de Agentes 2026
> Sub-pregunta: B4 (métricas, benchmarks, thresholds)

---

## Framework de 3 Capas para Medir Calidad de Agentes [F28]

La medición de calidad en producción 2026 tiene 3 capas:
1. **Outcome metrics** — ¿completó la tarea?
2. **Trajectory metrics** — ¿fue eficiente y seguro el camino?
3. **System metrics** — costo y latencia

---

## Thresholds de Producción Estandarizados 2026 [F28]

| Métrica | Definición | Threshold producción | Alerta |
|---|---|---|---|
| **Task Success Rate (TSR)** | % conversaciones que alcanzan el objetivo del usuario | ≥85% autónomo · ≥95% con oversight humano | Alert si cae >3% en 24h |
| **Tool-Call Accuracy** | % de tool/API calls que tienen éxito correctamente | ≥90% action success rate | Alert si cae <85% |
| **Cost per Task** | Token spend + tool-call count por tarea completada | Depende del agente; trackear costo/tsuccess | Alert si sube >20% vs baseline |
| **Latency p50** | Mediana de tiempo de respuesta | <2s conversación · <5s tareas complejas | Alert si p50 >3s |
| **Latency p95** | 95th percentile de latencia | <5s conversación · <15s tareas complejas | Alert si p95 >8s |
| **Hallucination Rate** | Frecuencia de hechos fabricados o acciones inventadas | <3% en sistemas de producción | Alert si sube >3% |
| **Escalation Rate** | % de casos que requieren intervención humana | <10% para agentes maduros | Alert si sube >15% |
| **Agent Drift** | Degradación de performance sobre tiempo | Alert si TSR cae >5% o hallucination sube >10% | Monitoreo continuo |

> Los top modelos en 2026 alcanzan 90%+ en Terminal-Bench Hard y 30-40% en GAIA. SWE-bench >50% = production-ready para coding agents [F28].

---

## Métricas Más Allá del Task Completion [F28]

El task completion es necesario pero no suficiente. También medir:

| Métrica | Qué mide |
|---|---|
| **Trajectory Quality** | ¿Tomó los pasos correctos con las herramientas correctas? Recovery rate tras errores. |
| **Intent Recognition Precision/Recall** | ¿Entendió la tarea correctamente? |
| **Context Retention** | ¿Mantiene coherencia en conversaciones multi-turn? |
| **CSAT** | Outcome + interaction + confidence scores del usuario |
| **Friction Metrics** | Queries repetidas, preguntas de clarificación, malentendidos |
| **Safety/Policy Adherence** | Violaciones por 100 tareas |
| **Repeat Usage Rate** | Indicador de confianza del usuario en el agente |

---

## Benchmarks de Referencia 2026 [F28]

| Benchmark | Evalúa | Top scores 2026 | Mejor para |
|---|---|---|---|
| **GAIA** | Assistant general (web browsing, file handling, reasoning) | 30-40% | Agentes de propósito general |
| **SWE-bench Verified** | Resolución real de issues GitHub | >50% = production-ready | Coding agents |
| **Terminal-Bench Hard** | Ejecución de tareas a nivel sistema | 90%+ (GLM-4.7 Thinking) | Infrastructure agents |
| **τ-bench (tau-bench)** | Customer service (adherencia a policy, multi-turn) | 50-70% | Customer service agents |
| **AgentBench** | Cobertura amplia (OS, databases, games) | Varía | Evaluación general |
| **BFCL v3** | Function/API calling accuracy | N/A | Tool-use reliability |
| **WebArena** | Web navigation realista | N/A | Web automation |
| **AgentRewardBench** | Calidad de LLM judges para web agents | N/A | Meta-evaluación |

### Cómo elegir el benchmark correcto [F28]
- **Coding agent** → SWE-bench Verified + Aider Polyglot
- **Infrastructure agent** → Terminal-Bench Hard
- **Customer service agent** → τ-bench
- **General assistant** → GAIA
- **Tool-using agent** → BFCL v3

### Advertencia sobre public benchmarks [F28]
> "Discount headline numbers by 15-20 points for production estimates. Your numbers from your own eval beat public benchmarks every time."

El benchmark más útil es uno propio con 50-100 tareas representativas del workflow real.

---

## Best Practices de Evaluación en Producción [F28]

1. **Empezar con eval propio**: 50-100 tareas representativas del flujo real → tus números superan cualquier benchmark público
2. **Usar benchmarks públicos como filtros, no rankings**: SWE-bench >50% es table stakes para coding agents, no diferenciador
3. **Combinar benchmarks públicos + evals privados**: ningún benchmark único es suficiente
4. **Trackear costo/latencia por tarea exitosa**: no promedios generales, específicamente por successful tasks
5. **Nunca evaluar solo el modelo**: evaluar el SISTEMA completo (modelo + tools + memoria + planner + verifier + runtime + monitoring)

---

## Construir un Eval Dashboard Mínimo Viable [F26, F28]

```
Dashboard de producción (actualización: cada hora):
├── Task Success Rate (TSR): {X}% [▲/▼ vs ayer]
├── Tool-Call Accuracy: {X}% [▲/▼ vs baseline]
├── Cost per Successful Task: ${X} [▲/▼ vs baseline]
├── Hallucination Rate: {X}% [▲/▼ vs threshold 3%]
├── p50 Latency: {X}ms | p95 Latency: {X}ms
├── Escalation Rate: {X}% [▲/▼ vs threshold 10%]
└── Drift Alert: [GREEN/YELLOW/RED]

Weekly review:
├── Regression suite results (100% expected)
├── Golden dataset coverage
└── Cost trend ($/task por semana)
```

**Implicación ALAN v2.0**: Cada agente generado por ALAN debe tener un dashboard minimal desde el día 1. ALAN puede generar la configuración de este dashboard automáticamente (un `metrics_config.json`) como parte del output del pipeline de generación.

**Si te llevas UNA cosa**: TSR ≥85% autónomo · Tool-Call Accuracy ≥90% · Hallucination <3%. Estos tres thresholds son el contrato mínimo de calidad para cualquier agente en producción 2026.
