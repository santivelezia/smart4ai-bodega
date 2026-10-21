 # Anti-patterns Críticos y Cómo Prevenirlos

## Catastrophic Forgetting en Fine-Tuning Continuo

Experience replay es la estrategia de mitigación más efectiva contra catastrophic forgetting en modelos de lenguaje sometidos a fine-tuning continuo [F25]. Phi-3.5-mini exhibe mínimo forgetting durante este régimen de entrenamiento [F25]. LoRA-based fine-tuning con regularización adicional reduce la severidad del problema [F25]. La combinación de experience replay con métodos complementarios produce las mayores ganancias en retención de conocimiento previo [F25].

Si te llevas UNA cosa: implemente experience replay combinado con LoRA regularizado para minimizar forgetting en actualizaciones continuas del modelo.

## Sycophancy Drift como Falla de Razonamiento

SMART (2025) reencuadra el sycophancy drift no como un defecto de alignment sino como un problema de optimización de razonamiento [F26]. La arquitectura UA-MCTS combinada con RL basado en progreso en dos etapas reduce sycophancy de forma significativa mientras preserva performance out-of-distribution [F26]. Para prevención a nivel de selección de modelo, prefiera reasoning models sobre instruction-tuned models usados aisladamente [F26].

Si te llevas UNA cosa: trate el sycophancy como error de razonamiento y aplique UA-MCTS con RL de progreso en dos etapas, evitando depender solo de instruction-tuned models.

## Memory Bloat y Violaciones de Asunciones GRPO

Memory-R2 (2026) documenta que distintos rollouts generan escrituras de memoria divergentes, lo que genera comparaciones injustas entre trayectorias y viola la asunción fundamental de GRPO [F12]. LoGo-GRPO resuelve esto mediante optimización local, comparando outcomes de operaciones de memoria desde el mismo estado intermedio, y optimización global que preserva el aprendizaje end-to-end [F12].

Si te llevas UNA cosa: use LoGo-GRPO para comparar operaciones de memoria desde estados intermedios idénticos y evitar bloat por divergencia de rollouts.

## False Memories por Retrieval Rígido

xMemory (2026) demuestra que el esquema top-k retrieval fijo retorna contexto redundante en sistemas de memoria de agentes [F10]. La poda post-hoc aplicada sobre ese contexto puede eliminar prerequisitos temporalmente enlazados que son necesarios para el razonamiento correcto [F10]. La solución consiste en retrieval top-down con selección compacta y diversa de temas antes de expandir hacia episodios específicos [F10].

Si te llevas UNA cosa: reemplace el top-k fijo por retrieval top-down con selección temática compacta y diversa antes de expandir a episodios.

## Límites de Performance en Memoria Multi-Plataforma

MEMTRACK benchmark (2025) reporta que GPT-5 alcanza únicamente 60% de correctness en tareas de memoria de largo plazo distribuidas en múltiples plataformas (Slack, Linear, Git) [F27]. Los desafíos estructurales documentados incluyen información noisy y conflictiva, dependencias cross-platform no triviales y resolución de contradicciones entre fuentes [F27]. Cualquier framework en producción enfrentará performance muy por debajo del 100% ante esta complejidad operativa [F27].

Si te llevas UNA cosa: asuma que en memoria multi-plataforma real ni los modelos más capaces superan el 60% de correctness, diseñe su sistema para tolerancia a noise y contradicciones cross-platform.

## Si te llevas UNA cosa

El ecosistema de agentes con memoria y razonamiento está limitado por catastrophic forgetting, sycophancy drift, memory bloat, false memories y ceilings de benchmark multi-plataforma; mitigue cada anti-pattern con experience replay + LoRA regularizado, UA-MCTS con RL de progreso, LoGo-GRPO, retrieval top-down temático, y diseño para noisy cross-platform correctness sub-100%.