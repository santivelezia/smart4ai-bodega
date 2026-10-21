# Contradicciones y Gaps · Meta-agentes de clase mundial 2026

---

## Contradicciones documentadas

### C1: Sobre LLM-as-judge
- **Claim A**: Multi-judge panels con 3 modelos heterogéneos mitigan el 80% de los biases [F19]
- **Claim contradictorio**: JudgeBench-Pro muestra que incluso los LLMs más potentes tienen error rates >50% en evaluación robusta [F21]
- **Resolución**: Los panels mitigan los biases *más comunes* pero no los eliminan. El error rate alto de JudgeBench-Pro es en escenarios deliberadamente difíciles. Para uso práctico, multi-judge + reference answer es el mejor approach disponible, no perfecto.

### C2: Sobre auto-mejora y costo
- **Claim A**: HyperAgents (DGM-H) mejoran de 20% a 50%+ sin más datos [F2]
- **Claim contradictorio**: El paper de "Inefficiencies of Meta Agents" muestra que pasar más contexto de diseños anteriores empeora el performance vs. baseline [F36]
- **Resolución**: La auto-mejora funciona cuando se usa evolutionary context curation (solo best-performing agents), no simple context accumulation. Son técnicas diferentes.

### C3: Sobre benchmarks como predictores de producción
- **Claim A**: SWE-bench >50% = production-ready para coding agents [F28]
- **Claim contradictorio**: Los benchmark scores deben descontarse 15-20 puntos para estimar producción real [F28]
- **Resolución**: No es contradicción — SWE-bench >50% es un filtro mínimo necesario, pero el score de producción real suele ser 15-20 puntos menor.

---

## Gaps identificados (investigación adicional recomendada)

### Gap 1: Métricas de calidad para el meta-agente sí mismo
La investigación cubre métricas para los agentes GENERADOS, pero no hay métricas estandarizadas para medir la calidad del META-AGENTE (ALAN) como builder. ¿Cómo medir si ALAN genera mejores agentes con cada iteración?

### Gap 2: Costo real de HyperAgents / DGM-H en producción
Los papers muestran mejoras de performance pero no reportan costo en $ por iteración de auto-mejora. Necesario para evaluar viabilidad económica.

### Gap 3: Interoperabilidad A2A entre Claude Managed Agents y Google ADK
El protocolo A2A de Google ADK 2.0 está en alpha. No hay documentación de integración nativa con Claude Managed Agents.

### Gap 4: Longitud óptima de la entrevista de elicitación
Los papers sobre ClarifyCoder y Ask or Assume validan que preguntar mejora resultados, pero no hay data sobre cuántas preguntas es el punto óptimo (diminishing returns).

### Gap 5: Dreaming (Anthropic) — detalles de implementación
La capacidad "Dreaming" de Claude Managed Agents está en research preview sin documentación técnica pública. No es posible implementarla aún externamente.
