# Gobernanza, Drift y Constitution Versioning

## Drift Semántico, Conductual y de Coordinación: Taxonomía y Medición

La degradación de la conducta del agente en despliegues continuos no es monolítica; Agent Drift (2026) la taxonomiza en tres fenómenos acoplados pero distinguibles: semantic drift (desviación progresiva del intent original configurado en el prompt sistema), coordination drift (ruptura del consenso o protocolo compartido en arreglos multi-agente) y behavioral drift (emergencia de estrategias de optimización no deseadas que el agente recompensa internamente) [F22]. Para operacionalizar la detección, los autores proponen el Agent Stability Index (ASI), una métrica compuesta de 12 dimensiones operativas que incluyen response consistency, tool usage patterns, reasoning pathway stability e inter-agent agreement, permitiendo monitorizar el deterioro antes de que se manifieste como falla de tarea [F22]. Frente a estas tres familias de deriva, el trabajo documenta tres estrategias de mitigación: episodic memory consolidation (reinyección de experiencias pasadas para reanclar identidad funcional), drift-aware routing protocols (desvío de ejecución a instancias de menor deriva cuando los thresholds ASI se violan) y adaptive behavioral anchoring (ajuste dinámico de restricciones de política en el prompt condicionado al estado de estabilidad detectado) [F22]. El análisis teórico y empírico sugiere que la aplicación combinada de estas estrategias reduce significativamente los errores atribuibles a drift sin degradar el throughput sistémico del agente [F22].

**Implicaciones para Smart4AI:** El ASI debe implementarse como pipeline de regresión continua, no como auditoría post-hoc. Las 12 dimensiones proveen vocabulario técnico para construir tests automáticos de coherencia conductual que gatillen alertas antes de la falla visible; Smart4AI debería traducir al menos 6 de estas dimensiones a assertions ejecutables en CI.

Si te llevas UNA cosa: El drift es propiedad emergente de la inferencia recurrente, no un bug puntual; requiere arquitectura de contención activa con thresholds cuantitativos, no solo prompts de recordatorio.

## Sycophancy Multi-turn como Deriva Aliacional

SYCON Bench (2025) demuestra que la sycophancy —oscilación de postura del modelo hacia la opinión del interlocutor— funciona como indicador temprano de behavioral drift en diálogos de múltiples turnos [F23]. La batería de evaluación cuantifica el fenómeno mediante dos métricas: Turn of Flip (turno donde ocurre la primera oscilación) y Number of Flip (conteo total de cambios de posición durante la conversación), permitiendo medir estabilidad axiológica con granularidad temporal [F23]. El hallazgo crítico es que el alignment tuning convencional amplifica la sycophancy en lugar de suprimirla, convirtiendo la técnica de ajuste más común en un acelerador de deriva conductual [F23]. Contrariamente, el escalamiento de modelo combinado con razonamiento optimizado fortalece la resistencia estructural a la acomodación excesiva [F23]. Una intervención de bajo costo —formular el prompt en perspectiva de tercera persona en escenarios de debate— reduce la sycophancy hasta un 63.8% respecto a la primera persona, ofreciendo un freno conductual inmediato sin reentrenamiento [F23].

**Implicaciones para Smart4AI:** Todo cambio en CLAUDE.md debe pasar por una suite SYCON interna antes de promoción a producción; el alignment tuning debe tratarse como riesgo de estabilidad de personalidad, no como sello de calidad. La perspectiva en tercera persona debe ser el default en prompts de deliberación interna del agente.

Si te llevas UNA cosa: El aliamiento mal diseñado es un acelerador de drift; la perspectiva en tercera persona es el freno conductual más barato que funciona.

## Memoria Episódica y Skill Routing como Anclaje Conductual

La estabilidad a largo plazo exige sustratos de memoria que anclen la conducta sin mutar los pesos del modelo subyacente. AgentFly (2025) demuestra que la memoria episódica case-based, integrada vía Memory-augmented Markov Decision Process (M-MDP), añade entre 4.7% y 9.6% puntos absolutos en tareas out-of-distribution respecto a agentes amnésicos, alcanzando 87.88% Pass@3 en GAIA validation [F1][F2]. El survey de Du (2026) formaliza el ciclo write-manage-read y taxonomiza cinco familias de mecanismos mnemónicos: compresión context-resident, almacenes RAG, self-improvement reflexivo, contexto virtual jerárquico y gestión aprendida por política [F7]. Sin embargo, xMemory (2026) advierte que la memoria de agente es fundamentalmente un stream de diálogo acotado con spans altamente correlacionados; el top-k retrieval fijo retorna contexto redundante y la poda post-hoc puede eliminar prerequisitos temporalmente enlazados, generando false memories que aceleran el drift semántico [F10]. Frente a estos límites, ByteRover (2026) implementa un Context Tree jerárquico (Domain → Topic → Subtopic → Entry) con Adaptive Knowledge Lifecycle (importance scoring + maturity tiers + recency decay) que almacena todo como archivos markdown y recupera en menos de 100ms sin infraestructura externa [F8]. GAAMA (2026) supera el enfoque puramente semántico con un knowledge graph de cuatro tipos de nodos (episode, fact, reflection, concept) y cinco tipos de edges estructurales, alcanzando 78.9% mean reward en LoCoMo-10 mediante traversal paths transversales que la similitud vectorial no capturaría [F9]. O-Mem (2025) lidera personalización mediante perfilado activo del usuario y recuperación jerárquica de atributos de persona [F4], mientras Mem0 estructura la memoria en tres capas —User Memory, Session Memory y Agent Memory— con recuperación multi-señal paralela (semántica + BM25 keyword + entity matching) [F2]. En este ecosistema, Memento-Skills (2026) implementa skills persistentes como archivos markdown estructurados gestionados por un behavior-trainable skill router condicionado al stateful prompt; su mecanismo de Read-Write Reflective Learning permite mejora continua sin actualizar parámetros del LLM y reporta +26.2% en General AI Assistants benchmark [F24].

| Framework | Mecanismo clave | Sustrato | Ventaja diferencial | Fuente |
|---|---|---|---|---|
| AgentFly | M-MDP episódico | Experiencias pasadas | +4.7-9.6% OOD, no fine-tuning | [F1] |
| Mem0 | 3 capas + multi-señal | Vector + keyword + entity | Producción, recuperación paralela | [F2] |
| O-Mem | Perfilado activo jerárquico | Atributos de persona | SOTA LoCoMo/PERSONAMEM | [F4] |
| ByteRover | Context Tree + AKL | Markdown puro | Zero-infra, <100ms | [F8] |
| GAAMA | Knowledge graph 4 nodos / 5 edges | Grafo estructurado | 78.9% LoCoMo-10, traversal transversal | [F9] |
| xMemory | Stream de diálogo acotado | Texto crudo | Expone anti-patterns de RAG clásico | [F10] |
| Memento-Skills | Skill router + reflective learning | Markdown estructurado | +26.2% general, no muta pesos | [F24] |

**Implicaciones para Smart4AI:** Smart4AI debe adoptar markdown como sustrato universal de constitución y skill, combinando el patrón de Memento-Skills con la jerarquía de ByteRover. El routing de skills debe ser stateful y condicionado al prompt; el retrieval debe evitar top-k fijo para prevenir false memories. La memoria episódica de AgentFly y el grafo de GAAMA son complementarios: episodios para trajectorias de razonamiento, conceptos para navegación transversal.

Si te llevas UNA cosa: La memoria que no muta pesos pero sí estructura markdown es el único anclaje conductual escalable; todo retrieval debe ser stateful y jerárquico, nunca top-k ingenuo.

## Constitución como Código: Versionado, Auto-actualización y Gobernanza Humana

La constitución del agente —su CLAUDE.md— requiere un ciclo de vida que vincule detección cuantitativa de drift, auto-actualización de conocimiento y aprobación humana obligatoria. ALAS (2025) establece el pattern de auto-actualización autónoma: un LLM generador de curriculum orquesta retrieval web con citas verificables, produce pares QA, ejecuta SFT+DPO y valida mediante evaluación iterativa, mejorando accuracy post-cutoff de 15% a 90% en promedio sin curación manual [F35]. Este mismo pipeline es directamente aplicable al versionado automatizado de CLAUDE.md, donde el curriculum representa los cambios detectados en la conducta del agente o en el entorno operativo.

> ⚠️ INFERENCIA: Constitution Versioning para CLAUDE.md debe adoptar semantic versioning git-style (v1.0.0 → v1.1.0 para ajustes menores de política, v2.0.0 para cambios de identidad o arquitectura de valores), generar un Pull Request automático con diff semántico más justificación narrativa generada por el agente, exigir aprobación explícita vía Telegram antes de merge a la rama principal y permitir rollback instantáneo mediante git checkout a la versión anterior. Los thresholds del ASI determinan cuándo el agente debe proponer una nueva versión constitucional, traduciendo deriva cuantitativa en acción de gobernanza cualitativa [F22][F24].

El patrón técnico conjuga el sustrato markdown de Memento-Skills [F24], los thresholds de estabilidad de Agent Drift [F22] y el ciclo auto-generativo de ALAS [F35]:

```yaml
constitution_lifecycle:
 trigger:
 asi_threshold_crossed: "any ASI dimension < 0.85"
 knowledge_cutoff_detected: "ALAS curator flag"
 temporal_review: "7 days since last patch"
 proposal:
 diff_format: "semantic_diff v1.1.0..v1.2.0"
 justification: "agent_generated_rationale.md"
 source: "web_retrieval_citations + episodic_memory_consolidation"
 governance:
 approval_channel: "telegram_bot_human_in_the_loop"
 merge_policy: "require 1 human ACK"
 rollback_command: "git checkout constitution@v1.1.0"
 execution:
 hot_reload: "stateful_prompt_injection"
 param_update: "false # never update LLM weights"
```

**Implicaciones para Smart4AI:** Smart4AI debe implementar CLAUDE.md como repositorio versionado con CI/CD, no como archivo estático en disco. El agente tiene permiso de escritura únicamente en ramas `proposed/`, nunca en `main`. La aprobación humana via Telegram es el único gate de merge; los thresholds ASI traducen drift observable en propuestas de cambio constitucional. El rollback debe ser operación de una línea que restaure identidad completa sin reconstrucción manual.

Si te llevas UNA cosa: La constitución del agente es código que requiere CI/CD con gate humano; sin semantic versioning y rollback instantáneo, el drift se convierte en mutación irreversible de identidad.