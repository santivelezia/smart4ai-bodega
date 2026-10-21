# 13 Anti-Patterns · ALAN-4AI · Detección Concreta

> Lista consolidada para la evaluación externa (S8) y la verificación adversarial (S9),
> ambas en sub-agentes con ventana limpia distinta. *(Opcional cross-provider: S8 puede usar
> GPT-4o-mini si tienes `OPENAI_API_KEY`; S9 puede usar Kimi si tienes `OPENROUTER_API_KEY`.
> Sin esas claves, corren en modo mono-proveedor con sub-agentes Claude en ventana limpia.)*
> Fuentes: [KB-base 09 A1] · [E 08 · Inv. meta-agente] · [D 06 · Inv. memoria]
> Un agente construido por ALAN-4AI debe tener 13/13 PASS antes de marcarse LISTO.

---

## GRUPO 1 · Anti-patterns Anthropic (5/5) [KB-base 09 A1]

### A1 · Kitchen Sink

**Definición:** CLAUDE.md que intenta hacer demasiado — instrucciones contradictorias, múltiples roles, reglas que se anulan entre sí.

**Señal de presencia:**
- CLAUDE.md > 80 líneas sin justificación
- Más de un rol principal declarado
- Instrucciones que se contradicen entre sí
- Más del 30% del archivo es implementación técnica (no filosofía)

**Cómo detectar:** contar líneas · buscar verbos "también puede" · buscar bloques duplicados
**Severidad:** ALTA · genera comportamiento impredecible en producción
**Stage responsable:** S8 T2 (CLAUDE.md Hygiene Test)

---

### A2 · Correcting Twice

**Definición:** el agente intenta corregir al usuario sobre la misma área más de dos veces en el mismo stage, sin avanzar.

**Señal de presencia:**
- Stage sin condición de salida cuando el usuario no converge
- Loops sin break/exit después de N intentos
- Ausencia de fallback "usuario rechaza área → marcar N/A y continuar"

**Cómo detectar:** buscar en stages el patrón "if user disagrees → retry → retry → ?" sin exit
**Severidad:** MEDIA · crea friction con usuarios no técnicos
**Stage responsable:** S8 T1

---

### A3 · Over-specified CLAUDE.md

**Definición:** CLAUDE.md lleno de instrucciones de implementación específica en lugar de principios operativos.

**Señal de presencia:**
- Fragmentos de código o pseudocódigo en CLAUDE.md
- Instrucciones del tipo "en el paso 3, hacer X antes de Y"
- Más instrucciones sobre CÓMO que sobre QUÉ y POR QUÉ

**Cómo detectar:** ratio "instrucción técnica step-by-step" vs "principio operativo"
**Severidad:** MEDIA · impide que Claude Code adapte la implementación según contexto
**Stage responsable:** S8 T2

---

### A4 · Trust-then-verify gap

**Definición:** el agente se marca como "listo" sin un smoke test ejecutable que lo valide.

**Señal de presencia:**
- `tests/` directorio ausente
- `smoke_test_plan.md` ausente o sin input concreto
- Criterio de éxito definido como "si no hay errores" (sin verificación proactiva)

**Cómo detectar:** verificar que `tests/smoke_test_plan.md` existe y tiene input copy-paste
**Severidad:** ALTA · el agente puede tener bugs silenciosos que solo aparecen en producción
**Stage responsable:** S8 T4 (Reproducibility Test)

---

### A5 · Infinite Exploration

**Definición:** stage o loop sin output verificable — el agente puede quedarse "explorando" sin avanzar.

**Señal de presencia:**
- Stage con proceso abierto y sin artefacto de output concreto
- Loop sin criterio de terminación explícito
- Stage que "puede tomar más tiempo según necesidad" sin cap

**Cómo detectar:** cada stage debe tener un Output con ruta concreta · si no tiene output = infinite exploration
**Severidad:** MEDIA · desperdicia tiempo y recursos sin entregar valor
**Stage responsable:** S8 T1

---

## GRUPO 2 · Anti-patterns Meta-agente (4/4) [E 08]

### M1 · Context Accumulation sin Curation

**Definición:** el orchestrator acumula el historial completo de conversación de todos los stages anteriores sin comprimir ni aislar.

**Señal de presencia:**
- Pipeline > 5 stages sin Stage Isolation documentado
- Sub-agentes que reciben el historial completo del orchestrator
- No hay checkpointing que comprima el estado entre stages
- El contexto del orchestrator crece linealmente con cada stage

**Cómo detectar:** verificar que stages críticos (generación, evaluación) usan sub-agent con ventana limpia
**Severidad:** CRÍTICA · causa fallo por saturación en pipelines largos (riesgo #1 documentado)
**Stage responsable:** S8 M1

---

### M2 · Specification Drift

**Definición:** el output de stages posteriores contradice o diverge de la spec original capturada en S1.

**Señal de presencia:**
- agent.md describe un propósito diferente al R-G de la spec
- Stages generados en S6 tienen lógica que no aparece en ningún caso de uso de S1
- Tools o MCPs en el agente generado que no estaban en las restricciones de S1

**Cómo detectar:** comparar R-G-C-C-O-V de elicitation_spec.md contra el agente generado
**Severidad:** CRÍTICA · el agente construido no es el agente que el usuario pidió
**Stage responsable:** S8 M2

---

### M3 · Recursive Context Leakage

**Definición:** sub-agentes reciben más contexto del que necesitan — información de otros sub-agentes, estado interno del orchestrator, o historial que no les corresponde.

**Señal de presencia:**
- Paquete de input del sub-agent incluye conversaciones previas del orchestrator
- El sub-agent de evaluación (S8) recibe el código de generación (S6) en el mismo stream de contexto que el orchestrator usó
- Sub-agentes encadenados donde el output de uno se pasa al siguiente sin filtrar

**Cómo detectar:** verificar que cada sub-agent recibe solo el paquete específico para su tarea
**Severidad:** ALTA · degrada calidad de outputs · puede llevar a saturación recursiva [E 08]
**Hard limit:** máximo N=3 niveles de recursión en sub-agentes [E 08 Anti-Pattern 3]
**Stage responsable:** S8 M3

---

### M4 · Capability Inheritance Bugs

**Definición:** el agente generado hereda herramientas, permisos o capacidades que no necesita — ya sea porque el template las incluye por defecto o porque el generador asumió que serían útiles.

**Señal de presencia:**
- agent.md lista MCPs o tools que no aparecen en la spec original
- El agente tiene acceso a herramientas destructivas que no necesita (delete, write, exec)
- Tools declaradas en CLAUDE.md que no se usan en ningún stage

**Cómo detectar:** cruzar tools en agent.md/CLAUDE.md vs tools en elicitation_spec.md
**Severidad:** MEDIA · viola principio de least privilege · riesgo de uso accidental
**Stage responsable:** S8 M4

---

## GRUPO 3 · Anti-patterns Memoria (4/4) [D 06]

### D1 · Catastrophic Forgetting

**Definición:** el agente usa fine-tuning de pesos LLM para actualizar su memoria, lo que sobreescribe conocimiento previo.

**Señal de presencia:**
- Referencia a `fine-tune`, `finetune`, `RLHF`, `LoRA`, `training` en archivos de memoria
- Instrucción de "actualizar el modelo base" en lugar de "actualizar archivos de memoria"
- Ausencia de mecanismo de experience replay para preservar episodios previos

**Cómo detectar:** `grep -r "fine-tune\|finetune\|RLHF\|training" output/<nombre>/`
**Severidad:** CRÍTICA · destruye conocimiento previo · imposible en producción sin re-training
**Correcto:** toda la plasticidad ocurre en sustratos externos (PostgreSQL, markdown files) [D 09]
**Stage responsable:** S8 D1

---

### D2 · Sycophancy Drift

**Definición:** para agentes CORE, ausencia de Identity Memory con pipeline de aprobación → el agente modifica su comportamiento para complacer al usuario sin control constitucional.

**Señal de presencia:**
- Agente CORE sin `CLAUDE.md` versionado en git
- Sin pipeline de aprobación para cambios constitucionales
- Sin anti-drift guardrails en el sistema prompt
- Instrucción de "adaptar el comportamiento según las preferencias del usuario" sin límites

**Cómo detectar:** para tier CORE → verificar que `CLAUDE.md` del agente tiene sección `Anti-Drift Guardrails` + pipeline de aprobación para cambios constitucionales
**Severidad:** ALTA · en producción el agente pierde su rol original [D 09 F22]
**Stage responsable:** S8 D2

---

### D3 · Memory Bloat

**Definición:** Episodic Memory crece sin límite sin lifecycle de compresión, degradando performance de retrieval y violando asunciones de credit assignment.

**Señal de presencia:**
- Implementación de Episodic Memory sin `compressSession()` o equivalente
- Sin TTL en episodios antiguos
- Sin lifecycle nocturno que archive episodios de baja señal
- Buffer episódico que crece linealmente con el tiempo sin poda

**Cómo detectar:** buscar `compressSession` o lifecycle equivalent en implementación de EM
**Severidad:** MEDIA · performance degrada gradualmente · invisible hasta que el agente lentifica
**Correcto:** implementar compresión de sesión preservando estados intermedios [D 09 F12]
**Stage responsable:** S8 D3

---

### D4 · False Memories

**Definición:** Episodic Memory usa top-k retrieval fijo sin multi-señal, o hace poda post-hoc del resultado de la query, eliminando prerequisitos temporales necesarios para coherencia.

**Señal de presencia:**
- `retrieve_episodic()` usa solo cosine similarity sin recency decay ni signal_score
- Poda del resultado final de la query (eliminar episodios "menos relevantes" después de recuperar)
- Top-k hardcoded sin considerar relevancia temporal

**Cómo detectar:** verificar que la función de retrieval usa fórmula multi-señal:
  `score = 0.6 × semantic + 0.3 × recency_decay + 0.1 × signal_score`
  Y que el resultado se retorna completo (no podado post-query) [D 09 F10]
**Severidad:** ALTA · el agente "recuerda" cosas incorrectas · difícil de debuggear
**Stage responsable:** S8 D4

---

## Tabla resumen de evaluación (S8)

| # | Anti-pattern | Grupo | Severidad | Señal principal | PASS si... |
|---|---|---|---|---|---|
| A1 | Kitchen Sink | Anthropic | ALTA | CLAUDE.md >80L | ≤80 líneas · sin contradicciones |
| A2 | Correcting Twice | Anthropic | MEDIA | Loop sin exit | Fallback N/A documentado |
| A3 | Over-specified | Anthropic | MEDIA | Código en CLAUDE.md | Solo principios operativos |
| A4 | Trust-then-verify | Anthropic | ALTA | Sin smoke test | smoke_test_plan.md con input concreto |
| A5 | Infinite Exploration | Anthropic | MEDIA | Stage sin output | Cada stage tiene output verificable |
| M1 | Context Accumulation | Meta-agente | CRÍTICA | Sin Stage Isolation | Sub-agents con ventana limpia en stages clave |
| M2 | Specification Drift | Meta-agente | CRÍTICA | agent.md ≠ spec | R-G-C-C-O-V alineado con output |
| M3 | Recursive Leakage | Meta-agente | ALTA | Sub-agent recibe más contexto del necesario | Paquetes de input específicos por sub-agent |
| M4 | Capability Inheritance | Meta-agente | MEDIA | Tools extra no en spec | Tools = Tools(spec) |
| D1 | Catastrophic Forgetting | Memoria | CRÍTICA | Fine-tuning referenciado | Sin referencias a entrenamiento de pesos |
| D2 | Sycophancy Drift | Memoria | ALTA | CORE sin IM/aprobación | IM + pipeline de aprobación presentes en CORE |
| D3 | Memory Bloat | Memoria | MEDIA | Sin compresión EM | compressSession() implementado |
| D4 | False Memories | Memoria | ALTA | Top-k fijo sin multi-señal | Retrieval con fórmula 0.6+0.3+0.1 |

---

*ALAN-4AI · derivado del meta-agente ALAN de Smart4AI · Fuentes: [KB-base 09 A1] · [E 08 Inv. meta-agente] · [D 06 Inv. memoria]*
