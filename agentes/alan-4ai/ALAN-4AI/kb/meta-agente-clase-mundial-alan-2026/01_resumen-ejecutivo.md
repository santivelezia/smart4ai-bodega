# Resumen Ejecutivo · Meta-agentes de clase mundial 2026
> Audiencia: ALAN v2.0 (Claude) leyendo para implementar. Optimizado para retrieval.

## Los 7 hallazgos accionables más importantes

**1. Tres patrones arquitectónicos dominan en 2026** [F1, F2]
Agent Factory (enterprise fleets), HyperAgents/DGM (auto-mejora), Orchestrator-as-Builder (Claude SDK Task tool). ALAN debe implementar el patrón Orchestrator-as-Builder con capacidad de evolucionar hacia HyperAgents cuando el corpus de agentes generados sea suficiente.

**2. La auto-referencia segura requiere sandboxing + versioned rollback gates** [F3, F6]
Meta's HyperAgents (DGM-H, arXiv 2603.19461) y RAO (arXiv 2605.06639) demuestran que agentes recursivos superan a sistemas estáticos, pero solo con: (a) sandbox aislado para auto-modificación, (b) criterios de halt explícitos, (c) rollback automático ante regresión. ALAN debe nunca auto-modificar en producción sin pasar gate de eval.

**3. Gemini+Braintrust+Promptfoo = stack de evaluación mínimo viable** [F7, F10]
El stack ganador 2026: Promptfoo para CI/CD gates (PR blocks si pass rate <95%), Braintrust para trace-level scoring y comparación A/B, Langfuse para observabilidad. Costo: ~$75/mes para evaluación nightly de un agente de producción.

**4. LLM-as-judge tiene 12 tipos de bias documentados — multi-judge panel mitiga el 80%** [F12, F13]
BiasScope (arXiv 2602.09383) identifica biases automáticamente. La mitigación estándar: panel de 3 jueces heterogéneos (Claude + GPT + Gemini) con voting mayoritario. Auto-juzgarse (Claude juzgando Claude) introduce sycophancy bias sistemático.

**5. Los thresholds de producción están estandarizados en 2026** [F17]
Task Success Rate ≥85% (sin oversight), Tool-Call Accuracy ≥90%, Latency p50 <2s, Hallucination <3%, Escalation <10%. Si ALAN genera agentes que no pasan estos thresholds en eval, no deployar.

**6. La ambigüedad de spec es la causa #1 de fallos — checklist R-G-C-C-O-V la previene** [F22, F23]
Orchid benchmark (arXiv 2604.21505) demuestra que la ambigüedad degrada a todos los LLMs. ClarifyCoder (arXiv 2504.16331) y Ask or Assume (arXiv 2603.26233) confirman que agentes que piden clarificación antes de actuar resuelven 13% más tareas. ALAN debe preguntar antes de implementar.

**7. 14 failure modes documentados para MAS — 3 categorías** [F26, F27]
"Why Do Multi-Agent LLM Systems Fail?" (arXiv 2503.13657, Cohen's κ=0.88): (i) specification & system design failures, (ii) inter-agent misalignment, (iii) task verification & termination. El failure mode #1 en meta-agentes: context accumulation sin curation (agentes que pasan todo el historial degeneran vs. baseline).

## Novedades Q1-Q2 2026 que ALAN debe incorporar [F29]

- **Claude Managed Agents** (beta pública 9 abr 2026): delegación dinámica, handoffs, recuperación de fallos en un solo runtime
- **Dreaming** (Anthropic research preview): agentes revisan sesiones pasadas para auto-mejorarse
- **Google ADK 2.0** (marzo 2026): protocol A2A para comunicación cross-framework
- **OpenAI Agents SDK sandbox nativo**: ejecución de código aislada sin infraestructura externa
- **RAO** (arXiv 2605.06639, mayo 2026): recursive agent optimization — agentes que se auto-delegan superan en efficiency a agentes únicos en tareas largas

## Implicación directa para ALAN v2.0 (síntesis)

ALAN v2.0 debe ser un **Orchestrator-as-Builder** con tres upgrades inmediatos:
1. **Gate de calidad pre-deploy**: todo agente generado pasa 5 eval checks antes de marcarse done
2. **Entrevista de elicitación estructurada**: 4 niveles de progressive disclosure antes de generar una línea de spec
3. **Anti-context-saturation**: checkpointing por stage, reset de contexto entre fases, sub-agentes con ventana limpia

Si te llevas UNA cosa: **el agente que pide clarificación antes de implementar resuelve 13% más tareas que el que asume.**
