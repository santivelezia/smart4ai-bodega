# Categoría 8 · Anti-Patterns y Failure Modes de Meta-Agentes
> Sub-pregunta: T2 (anti-patterns específicos de agent-builders, más allá de los 5 de Anthropic)

---

## Taxonomía de Failure Modes: "Why Do Multi-Agent LLM Systems Fail?" [F35]

El estudio más riguroso disponible (arXiv 2503.13657, mar 2025):
- 5 frameworks MAS analizados × 150+ tareas
- 6 human annotators expertos (Cohen's κ = 0.88 — muy alta confiabilidad)
- **14 failure modes únicos** identificados en 3 categorías

### Categoría I: Specification & System Design Failures [F35]

| Failure Mode | Descripción | Frecuencia |
|---|---|---|
| **Ambiguous role definition** | Los roles de los agentes no están suficientemente diferenciados; generan outputs solapados o contradictorios | Alta |
| **Insufficient capability declaration** | Los agentes no declaran explícitamente qué pueden y qué no pueden hacer | Alta |
| **Missing error escalation paths** | No existe path definido cuando un agente falla; el sistema se congela o entra en loop | Media |
| **Underspecified termination conditions** | El pipeline no sabe cuándo terminar; continúa indefinidamente o termina demasiado pronto | Alta |

### Categoría II: Inter-Agent Misalignment [F35]

| Failure Mode | Descripción | Frecuencia |
|---|---|---|
| **Context leakage** | Un agente pasa información irrelevante o sensible al siguiente; contamina su razonamiento | Media |
| **Format incompatibility** | El output format del agente A no coincide con el input format esperado por el agente B | Alta |
| **Assumption propagation** | Un agente hace una suposición incorrecta y el siguiente la toma como hecho verificado | Alta |
| **Role drift under pressure** | Bajo carga o contexto largo, los agentes empiezan a actuar fuera de su rol definido | Media |

### Categoría III: Task Verification & Termination Failures [F35]

| Failure Mode | Descripción | Frecuencia |
|---|---|---|
| **Premature task closure** | El agente marca la tarea como completada sin verificar el resultado real | Alta |
| **Evaluation blindness (sycophancy)** | El agente autoevalúa su output positivamente; features incompletas se marcan como done | Alta |
| **Infinite verification loops** | El agente verifica indefinidamente sin criterio de halt | Media |
| **Partial completion reporting** | El agente reporta éxito cuando completó solo parte de la tarea | Alta |
| **Silent failure** | El agente falla silenciosamente sin reportar el error al orchestrator | Media |
| **Conflicting success metrics** | Diferentes agentes usan diferentes métricas de éxito para la misma tarea | Media |

**Intervenciones que SÍ funcionan** [F35]: mejorar specification de roles + enhanced orchestration strategies (reducen los failures más comunes)
**Lo que NO funciona**: solo cambiar el modelo base sin cambiar la arquitectura de orquestación

---

## Anti-Patterns Específicos de Meta-Agentes (Agent Builders) [F36]

> Más allá de los 5 anti-patterns de Anthropic y los 4 de memoria, estos son específicos para sistemas que generan otros agentes.

### Anti-Pattern 1: Context Accumulation Sin Curation [F36]
**Descripción**: Meta-agentes que pasan TODO el historial de diseños anteriores al próximo diseño.
**Qué pasa**: El meta-agente "does not meaningfully leverage prior designs" y "performs worse than baseline" con este approach (paper arXiv 2025, "Inefficiencies of Meta Agents for Agent Design").
**Contramedida**: Solo pasar los N best-performing agentes al contexto del próximo (evolutionary context curation), no todos.

### Anti-Pattern 2: Specification Drift (Context Drift Death Spiral) [F36]
**Descripción**: Los agentes generados derivan de las specs originales después de docenas de turns; el estado interno acumula artefactos que corrompen decisiones futuras.
**Señales**: El agente generado hace cosas diferentes en el turn 1 vs. el turn 30 del pipeline.
**Contramedida**: La spec como anchor invariante (ver A2). Re-anclar a la spec en cada gate checkpoint. No parchear implementación — regenerar desde spec.

### Anti-Pattern 3: Recursive Context Leakage [F36]
**Descripción**: Bucles de auto-planificación entran en "recursive black hole" — el contexto se infla recursivamente hasta exceder el límite.
**Caso real**: Manus AI agent incident — looped recursively, exceeded context bounds.
**Contramedida**: Hard limit de profundidad de recursión (max N=3 niveles). Timer hard limit de 60s por sub-tarea. Monitor de tokens: si excede 80% del context window → truncar + resumir.

### Anti-Pattern 4: Evaluation Blindness / Sycophancy en Self-Eval [F36]
**Descripción**: Agentes generados se autoevalúan positivamente. Features incompletas o backends no funcionales se marcan como "superficialmente completos".
**Evidencia**: Extended runs de 5-6+ horas exponen fallos sistemáticos de self-evaluation.
**Contramedida**: Nunca self-eval como gate de producción. Siempre un evaluador externo (cross-validation con modelo diferente).

### Anti-Pattern 5: Capability Inheritance Bugs [F36]
**Descripción**: Sub-agentes heredan capabilities incompletas o incorrectas del generator. "Identity Fragmentation" — sesiones simultáneas del mismo agente se comportan diferente después de horas a pesar de config idéntica.
**Contramedida**: Cada agente generado tiene capabilities[] declaradas explícitamente en su spec, no heredadas implícitamente. Test de regresi���n con múltiples sesiones simultáneas.

### Anti-Pattern 6: Auditability Blindness [F36]
**Descripción**: Sistemas de generación automática de agentes complejos que son difíciles de auditar o controlar antes de su deployment.
**Consecuencia**: Safety risks y falta de compliance en contextos regulados.
**Contramedida**: Message-Action Traces (MAT) con contratos explícitos por step (ver arXiv 2603.18096 — Trace-Based Assurance Framework).

---

## AgentDropoutV2: Solución al Error Propagation en MAS [F37]

Paper: arXiv 2602.23258 (feb 2026) — framework de test-time rectify-or-reject pruning.
- Actúa como "active firewall": intercepta outputs de agentes y corrige errores antes de propagarlos
- Usa retrieval-augmented rectifier con pool de failure patterns conocidos
- Outputs irreparables son "pruned" para prevenir propagación
- Resultado: +6.3 puntos promedio en math benchmarks
- **Implicación ALAN**: Implementar un validation layer entre el code-generator sub-agente y el output final. Interceptar y corregir antes de marcar como done.

---

## MCP Production Failure Modes (2026) [F38]

"Bridging Protocol and Production" (arXiv 2603.13417, mar 2026) — 3 gap críticos en MCP para producción:

| Gap | Descripción | Solución propuesta |
|---|---|---|
| Identity propagation | MCP no propaga quién llama a qué tool | CABP: Context-Aware Broker Protocol con identity-scoped routing |
| Adaptive tool budgeting | No hay gestión de presupuesto de tool calls | ATBA: Adaptive Timeout Budget Allocation |
| Structured error semantics | Errores son strings libres, no machine-readable | SERF: Structured Error Recovery Framework |

**5 dimensiones de fallo en producción MCP**: server contracts, user context, timeouts, errors, observability.

---

## Herramientas para Detección y Atribución de Fallos [F39]

| Herramienta/Paper | Función | Estado |
|---|---|---|
| **VerifyMAS** (arXiv 2605.17467, may 2026) | Atribución de fallos vía hypothesis verification sobre trayectorias completas | Open source |
| **AEGIS** (arXiv 2509.14295, sep 2025) | Generación + identificación automática de errores en MAS mediante inyección controlada | Open source |
| **Agentable** | Static analysis tool para detectar 8 tipos de defectos en código de agentes LLM | 88.79% accuracy |
| **EU-Agent-Bench** | Benchmark de compliance con EU law para agentes | Open source (preview) |

---

## Checklist Anti-Pattern para ALAN v2.0

Antes de marcar un agente como "done", verificar:

```
□ ¿El output del agente fue evaluado por un modelo DIFERENTE al que lo generó?
□ ¿La spec está anclada y no ha derivado durante la generación?
□ ¿Hay un hard limit de recursión si el agente puede spawnar sub-agentes?
□ ¿Las capabilities del agente están declaradas EXPLÍCITAMENTE en su spec?
□ ¿El contexto del meta-agente no excedió el 80% del context window durante la generación?
□ ¿Las condiciones de terminación del pipeline están definidas y verificadas?
□ ¿El agente reporta errores explícitamente (no falla silenciosamente)?
□ ¿Hay un Message-Action Trace habilitado para el agente generado?
```

**Si te llevas UNA cosa**: La causa #1 de fallos en meta-agentes en 2026 es el **Evaluation Blindness** — el agente marca sus propios outputs como correctos cuando no lo son. La única solución es un evaluador externo heterogéneo (cross-validation con modelo diferente) como gate obligatorio.
