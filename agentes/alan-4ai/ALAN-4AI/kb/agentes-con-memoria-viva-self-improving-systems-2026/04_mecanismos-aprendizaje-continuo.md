 # 04_mecanismos-aprendizaje-continuo.md

## Reflexión Verbal y Auto-Mejora sin Actualización de Pesos

Reflexion (Shinn 2023) constituye el paper seminal en verbal reinforcement learning: refuerza agentes mediante feedback lingüístico sin actualizar pesos del modelo base, almacenando la reflexión verbal sobre señales de tarea en un episodic memory buffer que condiciona acciones futuras. [F13] Alcanza 91% pass@1 en HumanEval, superando a GPT-4 (80%), con aplicabilidad directa en sequential decision-making, coding y language reasoning. [F13] Re-ReST (2024) demuestra que el self-training mejora agentes +7.6% en HotpotQA y +28.4% en AlfWorld; un reflector adicional sobre muestras de baja calidad aporta +2.0% y +14.1% respectivamente, habilitando reflexión durante inferencia sin depender de ground-truth feedback. [F16] ACT (2026) emplea RL para entrenar agentes en la identificación de la mejor acción entre alternativas, generando self-reflection genuina en contraste con la imitación de reflexión pre-construida. [F17] Reporta mejoras de +5.07 puntos sobre imitation learning, +4.62 sobre RL estándar y +2.42 sobre knowledge distillation, generalizando out-of-distribution sin datos específicos de razonamiento. [F17]

Si te llevas UNA cosa: la auto-mejora efectiva no requiere fine-tuning de pesos; el feedback lingüístico episódico y la reflexión genuina generada por RL superan a la imitación y al RL estándar en tareas complejas.

## Reflexión Oportunista y Metacognición Estructurada

MARS (2026) logra self-evolution eficiente en un solo ciclo de recurrencia, eliminando la necesidad de loops multi-turno costosos. [F14] Distingue principled reflection (reglas normativas para evitar errores sistémicos) de procedural reflection (estrategias paso-a-paso para replicar el éxito), superando SOTA en self-evolving con menor overhead computacional. [F14] Agent-R (2025) resuelve el challenge temporal de la reflexión: esta debe ocurrir oportunamente durante el rollout, no al final. [F15] Utiliza MCTS para construir datos de entrenamiento recuperando trayectorias correctas desde erróneas e identificando el primer paso de error, logrando +5.59% vs baseline en tres entornos interactivos. [F15]

Si te llevas UNA cosa: la reflexión debe ser oportuna (no post-hoc) y estructurada en principios y procedimientos; un solo ciclo metacognitivo bien diseñado vence a múltiples turnos reactivos.

## Memoria Autónoma y Evolución Online de Experiencia

U-Mem (2026) introduce agentes con memoria autónoma que adquieren y validan conocimiento activamente mediante una cascada costo-eficiente: señales propias baratas → investigación verificada por herramientas → feedback de expertos (solo si necesario), mejorando HotpotQA en 14.6 puntos con Qwen2.5-7B. [F3] Live-Evo (2026) implementa memory evolution online mediante un Experience Bank y un Meta-Guideline Bank: las experiences útiles se refuerzan con peso alto para recuperación frecuente, mientras las experiences misleading o stale se reducen gradualmente. [F18] En Prophet Arena sobre 10 semanas, reporta +20.8% en Brier score y +12.9% en retornos de mercado. [F18]

Si te llevas UNA cosa: la memoria debe evolucionar online con mecanismos de refuerzo y degradación automáticos, validando conocimiento nuevo en cascada antes de escalar a supervisión humana.

## Aprendizaje de Preferencias Implícito desde Interacción

Mem0 implementa aprendizaje de preferencias implícito vía conversación continua: tras cada interacción genera la respuesta del asistente y crea nuevas memorias de la conversación, sin requerir thumbs up/down explícito del usuario — el aprendizaje es automático por diseño. [F2] [INFERENCIA] Las señales implícitas de satisfacción del usuario incluyen: tiempo de respuesta al mensaje siguiente (respuesta rápida indica satisfacción), preguntas de seguimiento (engagement), reformulaciones repetidas (confusión o insatisfacción), y longitud/detalle de la respuesta del usuario (mayor inversión correlaciona con mayor interés); estas señales pueden extraerse sin declaración explícita. [F4]

Si te llevas UNA cosa: el aprendizaje de preferencias no necesita feedback explícito; las señales conductuales del usuario durante la conversación son suficientes para construir perfiles implícitos.

## Detección de Knowledge Gaps y Señalización Activa de Incertidumbre

ARIA (2025) es el primer sistema documentado en producción para knowledge gap detection: evalúa incertidumbre vía autodiálogo estructurado, identifica gaps proactivamente y solicita explicaciones de expertos humanos. [F19] Deployado en TikTok Pay (150M MAU), actualiza el repositorio de conocimiento con timestamp para detectar y resolver conflictos temporales. [F19] MetaAgent (2025) detecta gaps de conocimiento y genera requests en lenguaje natural que se rutean al tool más adecuado, construyendo una knowledge base persistente organizando el historial de tool-use; toda la adaptación ocurre vía evolución de habilidades externalizadas sin actualizar parámetros del modelo. [F20] La incertidumbre en agentes evoluciona de métrica pasiva a señal de control activa (survey 2026): gobierna decisiones metacognitivas sobre uso de herramientas y búsqueda de información, permitiendo que el agente decida cuándo escalar a fuentes externas versus responder desde memoria existente. [F21]

Si te llevas UNA cosa: la incertidumbre debe usarse como señal de control activa para disparar autodiálogo, detección de gaps y escalamiento a tools o expertos, manteniendo la adaptación fuera de los pesos del modelo.

## Si te llevas UNA cosa

El aprendizaje continuo efectivo combina reflexión verbal sin actualización de pesos, evolución autónoma de memoria con refuerzo/degradación online, aprendizaje implícito de preferencias desde señales conductuales, y detección proactiva de knowledge gaps gobernada por incertidumbre como señal de control activa — todo externalizado en memoria, tools y habilidades, no en los parámetros del modelo base.