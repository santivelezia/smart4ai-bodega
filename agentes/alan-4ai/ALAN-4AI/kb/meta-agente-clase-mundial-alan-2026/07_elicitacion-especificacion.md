# Categoría 7 · Elicitación y Prevención de Ambigüedad en Specs
> Sub-preguntas: C1 (técnicas SOTA), C2 (prevenir ambigüedad en el origen), C3 (entrevista de descubrimiento)

---

## C1 · Técnicas SOTA de Requirements Elicitation para Agentes IA 2026

### El problema cuantificado: Ambigüedad destruye calidad [F29]
"Orchid benchmark" (arXiv 2604.21505, abr 2026): primer benchmark diseñado con requisitos ambiguos.
- 1,304 tareas con 4 tipos de ambigüedad: lexical, sintáctica, semántica, vaguedad
- **La ambigüedad degrada consistentemente a TODOS los LLMs evaluados**
- Los modelos más avanzados muestran los efectos negativos MÁS pronunciados
- LLMs frecuentemente producen implementaciones funcionalmente divergentes para el mismo requisito ambiguo
- LLMs **no detectan ni resuelven la ambigüedad de forma autónoma** sin prompting explícito

### Spec-by-Example (la técnica más efectiva) [F30]
Antes de escribir la spec en abstracto, pedir ejemplos concretos:
- "Dame 3 ejemplos de inputs que DEBERÍA manejar este agente"
- "Dame 2 ejemplos de inputs que NO debería manejar"
- "¿Qué debería responder exactamente si recibe X?"

Los ejemplos revelan assumptions que la descripción verbal nunca revela.

### ClarifyCoder: El patrón más validado 2026 [F30]
"ClarifyCoder" (arXiv 2504.16331, abr 2025):
- Framework que enseña a los LLMs a **pedir clarificación** antes de proceder cuando hay ambigüedad
- Dos componentes: (1) síntesis de datos que aumenta datasets con escenarios que requieren clarificación, (2) fine-tuning que enseña a priorizar clarificar sobre generar
- Resultado: mejora significativa en communication capabilities manteniendo coding quality

### Ask or Assume: Validación en SWE-bench [F31]
"Ask or Assume?" (arXiv 2603.26233, mar 2026) — multi-agent scaffold para detección de underspecification:
- Sistema que **decoupla** la detección de underspecification de la ejecución del código
- **Resultado medido**: OpenHands + Claude Sonnet 4.5 alcanzó 69.40% task resolve rate vs. 61.20% del baseline single-agent (en SWE-bench Verified con instrucciones ambiguas)
- **Mejora de 13.4%** simplemente por agregar clarification-seeking
- El sistema muestra **well-calibrated uncertainty**: conserva queries en tareas simples, pide activamente en tareas complejas

> **Implicación directa**: Añadir clarification-seeking a ALAN antes de generar spec es la mejora de mayor ROI disponible. 13% más de éxito, costo mínimo.

### APA: Alinear LLMs para Manejar Ambigüedad Explícitamente [F32]
"Alignment with Perceived Ambiguity" (APA, arXiv 2404.11972):
- Alinea LLMs para detectar y manejar queries ambiguas usando su propia evaluación de la ambigüedad
- Funciona mejor que training con gold-standard labels en escenarios out-of-distribution
- Implicación: ALAN puede ser prompt-engineered para detectar ambigüedad sin fine-tuning

---

## C2 · Prevenir Ambigüedad en el ORIGEN

### El framework R-G-C-C-O-V para validar prompts/specs [F33]

Antes de implementar cualquier spec, verificar que contiene los 6 elementos:

| Elemento | Pregunta de verificación |
|---|---|
| **R**ole | ¿El rol del agente está definido en 1 oración? |
| **G**oal | ¿El objetivo principal es específico y medible? |
| **C**ontext | ¿El contexto en que opera el agente está claro? |
| **C**onstraints | ¿Las restricciones (qué NO hacer) están explícitas? |
| **O**utput | ¿El formato y contenido del output esperado están especificados? |
| **V**erification | ¿Los criterios de éxito son verificables (tests)? |

### Las 8 preguntas de desambiguación obligatorias [F33]
Hacer ANTES de escribir una línea de código o spec:

1. **¿Cuál es el caso de uso principal vs. casos secundarios?** (priorización explícita)
2. **¿Qué debe hacer el agente cuando NO está seguro?** (ej. pedir clarificación vs. aluciación)
3. **¿Cuáles son las métricas de éxito cuantificables?** (ej. "80% de respuestas citan fuentes")
4. **¿Qué información NO debe manejar el agente?** (límites de alcance)
5. **¿Cómo se comporta con usuarios no técnicos vs. expertos?** (diferenciación de perfiles)
6. **¿Qué pasa si la fuente de conocimiento está desactualizada?**
7. **¿El agente debe escalar a humano en algún punto? ¿Bajo qué condiciones?**
8. **¿Cuál es la definición de "done" verificable?** (criterios de aceptación medibles)

### Checklist de claridad de spec para ALAN [F33]

```markdown
## Spec Clarity Checklist (ALAN pre-generation gate)
□ Propósito expresable en 1 oración clara
□ Al menos 3 ejemplos de inputs válidos
□ Al menos 2 ejemplos de inputs inválidos/fuera de scope 
□ Métricas de éxito cuantificables definidas
□ Fuentes de conocimiento validadas y accesibles
□ Todas las acciones/tools del agente definidas
□ Comportamiento ante incertidumbre especificado
□ Criterios de escalación a humano definidos
□ Formato de output especificado con ejemplo
□ Manejo de errores para los 3 casos más probables

Regla: si algún checkbox está vacío → ALAN pide clarificación ANTES de generar
```

### Técnicas de detección de assumptions ocultas [F33]

| Técnica | Cómo aplicarla | Qué revela |
|---|---|---|
| Test-Driven Spec (TDD para agentes) | Escribir test cases ANTES de la spec | Assumptions sobre comportamiento esperado no documentado |
| Análisis de casos límite | "¿Qué pasa si el usuario no da info suficiente? ¿Si la fuente falla?" | Assumptions sobre inputs válidos y manejo de errores |
| Matriz de trazabilidad | Asignar ID y propietario a cada capability del agente | Scope mal definido, ownership ambiguo |
| Spec-by-Example | Solicitar 3 ejemplos positivos + 2 negativos antes de la spec | Assumptions implícitas sobre el dominio |

---

## C3 · Entrevista de Descubrimiento para Usuarios No Técnicos

### Los 4 Niveles de Progressive Disclosure [F34]

La estructura de entrevista más efectiva para no-técnicos revela complejidad gradualmente:

```
Nivel 1 — SUPERFICIE (¿Qué existe hoy?):
 "¿Qué hace tu asistente/proceso actualmente?"
 "¿Cuánto tiempo te toma hacer esto manualmente?"

Nivel 2 — FLUJO (¿Cómo funciona?):
 "¿Qué pasos siguen después de que el asistente responde?"
 "¿Con quién más interactúa este proceso?"

Nivel 3 — EXCEPCIONES (¿Qué sale mal?):
 "¿Alguna vez el proceso dio una respuesta incorrecta? ¿Qué pasó?"
 "¿Cuál es el peor caso que ha ocurrido?"

Nivel 4 — CRITERIOS IMPLÍCITOS (¿Cómo mides el éxito?):
 "¿Cómo sabes si la respuesta fue buena?"
 "¿Qué haría que prefieras el asistente sobre hacerlo manualmente?"
```

Beneficio: Descubres assumptions que el usuario no mencionaría ante una pregunta directa [F34].

### Patrones de UX para entrevistas de descubrimiento [F34]

**❌ NUNCA preguntar:**
- "¿Qué quieres que haga el agente?" — demasiado abstracto, el usuario no sabe
- "¿Qué features necesitas?" — vocabulario técnico que no tiene
- "¿Usarás integración con X?" — pregunta de implementación, no de necesidad

**✅ USAR EN SU LUGAR:**

| Patrón | Ejemplo de pregunta |
|---|---|
| Preguntas sobre contextos reales | "Cuéntame sobre la última vez que necesitaste ayuda con [tarea]. ¿Qué pasó exactamente?" |
| Escenarios concretos | "Imagina que un cliente pregunta X. ¿Qué esperarías que respondiera tu asistente?" |
| Ejemplificación con casos extremos | "¿Qué pasaría si alguien hace una pregunta que no sabes responder?" |
| Historias de usuario en lenguaje natural | "Como [rol], quiero [objetivo] para [beneficio]" — sin términos técnicos |
| Prototipado con papel/pantalla | Mostrar un flujo dibujado: "¿Esto resolvería tu problema? ¿Qué faltaría?" |

### Template de Entrevista ALAN v2.0 (Duración: 20-30 min) [F33, F34]

```
FASE 1: Contexto (5 min)
1. "¿Qué problema estás resolviendo hoy sin el agente?"
2. "¿Cuánto tiempo te toma actualmente?"
3. "¿Quién más está involucrado en este proceso?"

FASE 2: Ejemplos Concretos (8 min)
4. "Dame 3 ejemplos de tareas reales que debería manejar este agente"
5. "¿Hay tareas similares que NO debería hacer? Dame 2 ejemplos"
6. "Para el ejemplo #1, ¿qué respuesta exacta esperarías ver?"

FASE 3: Excepciones y Límites (7 min)
7. "¿Qué pasa si el agente no tiene la información para responder?"
8. "¿Hay casos donde preferirías que el agente escale a una persona?"
9. "¿Qué sería una respuesta inaceptable del agente?"

FASE 4: Criterios de Éxito (5 min)
10. "¿Cómo sabes si el agente funcionó bien?"
11. "¿Cuál es la métrica más importante para ti?"
12. "¿Qué haría que dejaras de usar el agente?"

OUTPUT esperado de la entrevista:
├── 3 user stories validadas
├── 5+ ejemplos positivos
├── 2+ ejemplos negativos/fuera de scope
├── Definición de "done" cuantificable
└── 3 criterios de aceptación verificables
```

### La regla de oro de la elicitación [F33]

> "Los agentes de IA amplifican tanto las buenas como las malas prácticas de ingeniería. Las especificaciones, criterios de aceptación, esquemas, pruebas y puntos de control humanos no son sobrecarga de proceso — son sistemas de control."

**Implementar human checkpoints en cada fase**: requisitos → spec → tests → lanzamiento.

**Implicación ALAN v2.0**: ALAN debe tener un Stage 0 de elicitación interactiva con el template de los 4 niveles y las 12 preguntas. Antes de generar spec, ALAN debe poder mostrar el checklist R-G-C-C-O-V completado. Si falta cualquier elemento → preguntar, no asumir.

**Si te llevas UNA cosa**: Los usuarios no técnicos no saben qué quieren en abstracto — solo saben qué les duele en concreto. Preguntar por ejemplos reales de su pasado es 10x más efectivo que preguntar por features del futuro.
