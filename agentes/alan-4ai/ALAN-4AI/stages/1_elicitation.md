# Stage 1 · Elicitation ⭐ THE MOST IMPORTANT · modelo de razonamiento fuerte (ej. Claude Opus)

## Propósito

Aplicar el patrón de discovery más potente disponible en 2026: **R-G-C-C-O-V + 4 niveles de Progressive Disclosure + Spec-by-Example** (Cambio #2 v2.0). Entrevistar hasta que la ambigüedad sea cero. Declarar el tier del agente (CORE / Ops / Comercial) que condiciona S5. **No avanzar hasta que el usuario confirme "spec completa".**

Fuente de la mejora: [E 07 F31] — agregar clarification-seeking elevó task resolve rate de 61.2% a 69.4% en SWE-bench Verified (+13.4% simplemente por pedir clarificación).

---

## 1 · Input

| Fuente | Contenido |
|---|---|
| `runs/<run_id>/preflight.json` | Stage 0 OK · run_id activo |
| Idea inicial del usuario | Vaga o detallada · el interview la refina |
| `CLAUDE.md` | Filosofía Orchestrator-as-Builder y criterios de tier |

---

## 2 · Proceso

### Apertura (modelo de razonamiento fuerte · interactivo)

Prompt al usuario:
```
👋 Soy ALAN-4AI · meta-agente Orchestrator-as-Builder.

Antes de escribir una línea de código, necesito que la ambigüedad sea cero.
Te voy a entrevistar con 4 niveles de preguntas. Al final, tendrás
una spec que yo mismo firmaré antes de construir.

Empezamos: ¿qué problema estás resolviendo?
Descríbelo en 2-3 frases. Solo cuéntame qué duele hoy.
```

---

### Nivel 1 · SUPERFICIE — ¿Qué existe hoy? [E 07 C3 F34]

Preguntas obligatorias:
- "¿Qué hace tu proceso/asistente actual para esta tarea?"
- "¿Cuánto tiempo te toma hacerlo manualmente?"
- "¿Quién más está involucrado en este proceso?"

Objetivo: entender el estado actual antes de definir el futuro.

---

### Nivel 2 · FLUJO — ¿Cómo funciona? [E 07 C3 F34]

Preguntas obligatorias:
- "¿Qué pasos siguen DESPUÉS de que el agente responde? ¿Hay acciones downstream?"
- "¿Con qué otros sistemas o personas tiene que interactuar?"
- "¿El agente opera 24/7 o solo cuando alguien lo invoca?"

Objetivo: revelar integraciones y dependencias que el usuario no menciona espontáneamente.

---

### Nivel 3 · EXCEPCIONES — ¿Qué sale mal? [E 07 C3 F34]

Preguntas obligatorias:
- "¿Alguna vez este proceso dio una respuesta incorrecta o incompleta? ¿Qué pasó exactamente?"
- "¿Cuál es el peor caso que podría ocurrir si el agente falla?"
- "¿Qué pasa si el agente no tiene la información para responder? ¿Escala a persona o responde igual?"

Objetivo: exponer assumptions ocultos sobre manejo de errores y edge cases.

---

### Nivel 4 · CRITERIOS IMPLÍCITOS — ¿Cómo mides el éxito? [E 07 C3 F34]

Preguntas obligatorias:
- "¿Cómo sabes si la respuesta del agente fue buena?"
- "¿Cuál es la métrica más importante para ti — velocidad, exactitud, costo, o tono?"
- "¿Qué haría que dejaras de usar el agente? Dame un ejemplo específico."

Objetivo: construir criterios de aceptación verificables, no subjetivos.

---

### Spec-by-Example (obligatorio tras los 4 niveles) [E 07 C1 F30]

Preguntar explícitamente:
1. **"Dame 3 ejemplos concretos de inputs que DEBERÍA manejar este agente."**
2. **"Dame 2 ejemplos de inputs que NO debería manejar (fuera de scope)."**
3. **"Para el ejemplo #1, ¿qué respuesta exacta esperarías ver?"**

Los ejemplos revelan assumptions que la descripción verbal nunca revela. [E 07 F30]

---

### Checklist R-G-C-C-O-V (completar antes de cerrar) [E 07 C2 F33]

| Elemento | Pregunta de verificación | ¿Cubierto? |
|---|---|---|
| **R**ole | ¿El rol del agente está definido en 1 oración clara? | □ |
| **G**oal | ¿El objetivo principal es específico y medible? | □ |
| **C**ontext | ¿El contexto operativo del agente está claro? | □ |
| **C**onstraints | ¿Las restricciones (qué NO hacer) están explícitas? | □ |
| **O**utput | ¿El formato y contenido del output están especificados? | □ |
| **V**erification | ¿Los criterios de éxito son verificables con tests? | □ |

Si algún checkbox está vacío → preguntar antes de avanzar. [E 07 F33]

---

### Spec Clarity Checklist (10 ítems · gate pre-cierre) [E 07 C2 F33]

```
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
```

Regla: si algún ítem está vacío → preguntar. NUNCA asumir. [E 07 F33 · ClarifyCoder]

---

### Declaración de Tier (obligatoria · alimenta S5)

Después de cubrir los 4 niveles, presentar al usuario:

```
Basado en el discovery, el tier recomendado para este agente es:

◉ CORE    → Self-mejora continua · datos sensibles · 5/5 sistemas memoria
○ Ops     → Workflows repetitivos · baja variabilidad · 4/5 memoria (sin Identity)
○ Comercial → Ventas/soporte · comportamiento fijo · 3/5 memoria (sin PM ni IM)

¿Confirmas el tier o prefieres ajustarlo?
```

El tier declarado aquí es el ancla inmutable para S5. [D 09 Variantes por Tipo de Agente]

---

### Confirmación y cierre

- Presentar resumen estructurado de la spec completa
- Preguntar explícitamente: *"¿La especificación está completa o falta algo?"*
- Si el usuario agrega algo → nuevas preguntas dirigidas → volver a confirmar
- Solo cuando dice "completa" → persistir output

---

### Guardar checkpoint S1

```python
await checkpoint.save_stage(1, {
    "result": {"spec_path": "runs/<run_id>/elicitation_spec.md", "tier": tier},
    "metadata": {"model": model_snapshot, "duration_s": elapsed},
    "summary": f"Spec completa · tier={tier} · {len(use_cases)} casos de uso · {len(examples_positive)} positivos · {len(examples_negative)} negativos"
})
```

---

## 3 · Output

`runs/<run_id>/elicitation_spec.md` (~150-300 líneas):

```markdown
# Elicitation Spec · <nombre-tentativo-agente>
Run ID: <run_id> · Fecha: <ISO8601>

## R-G-C-C-O-V
- **Role:** {rol en 1 oración}
- **Goal:** {objetivo medible}
- **Context:** {contexto operativo}
- **Constraints:** {qué NO hace · modelos prohibidos · MCPs requeridos}
- **Output:** {formato + ejemplo concreto}
- **Verification:** {criterios de éxito verificables · métricas}

## Tier declarado
{CORE | Ops Internas | Comercial} · Razón: {justificación 1 línea}

## Nivel 1 · Superficie
{proceso actual · tiempo manual · personas involucradas}

## Nivel 2 · Flujo
{pasos downstream · integraciones · modo de operación}

## Nivel 3 · Excepciones
{incidentes previos · peor caso · comportamiento ante incertidumbre}

## Nivel 4 · Criterios
{métricas de éxito · métrica principal · deal-breakers}

## Spec-by-Example
### Inputs positivos (3)
1. {input concreto} → expected output: {respuesta exacta}
2. ...
3. ...
### Inputs negativos (2)
1. {input fuera de scope} → comportamiento esperado: {rechazar/redirigir}
2. ...

## Spec Clarity Checklist
{10 checkboxes marcados}

## Confirmación
- [x] "Spec completa" confirmado por usuario
- Fecha: {ISO8601}
```

También: `runs/<run_id>/elicitation_questions_log.jsonl` — log de cada pregunta + respuesta para auditoría.

---

## 4 · Modelo

**Modelo de razonamiento fuerte (ej. Claude Opus)** · razonamiento crítico para interview de calidad.

Justificación: [E 07 F31] — el interview requiere identificar assumptions ocultos y hard parts no obvios. Conviene el modelo con mayor capacidad de razonamiento que tengas disponible en Claude Code. El costo de un interview de calidad se justifica vs el riesgo de spec incompleta (causa #1 de fallos en meta-agentes).

Lánzalo como sub-agente en ventana limpia con la herramienta Task, pasándole solo el contexto acumulado del interview + el prompt de discovery.

---

## 5 · Nota de ejecución

Corre sobre tu Claude Code (plan Max/Pro o API propia); no hay cobro aparte. El interview es interactivo: 1-3 turnos del modelo de razonamiento fuerte hasta convergencia.

---

## 6 · Validación

- [ ] `elicitation_spec.md` existe con secciones R-G-C-C-O-V y 4 niveles
- [ ] Tier declarado: CORE / Ops / Comercial
- [ ] 3 ejemplos positivos presentes
- [ ] 2 ejemplos negativos presentes
- [ ] Spec Clarity Checklist 10/10 marcados
- [ ] `elicitation_questions_log.jsonl` con confirmación "spec completa" del usuario
- [ ] `checkpoint stage_1.json` guardado

---

## 7 · Fallback

| Falla | Acción |
|---|---|
| Usuario abandona mid-interview | Guardar `elicitation_spec.md` parcial · marcar `ELICITATION_INCOMPLETA` · próximo run reanuda |
| Usuario rechaza profundizar en área | Marcar "N/A" con razón documentada · continuar |
| Interview >45 min sin convergencia | Sugerir `/clear` · restart con scope más enfocado · anti-pattern kitchen sink [KB-base 09 A1] |
| Modelo de razonamiento fuerte no disponible | Fallback a un modelo rápido y capaz (advertir · "el interview tomará más vueltas") |
| Usuario da respuestas vagas consistentemente | Ofrecer multiple-choice con opciones concretas · preguntar por ejemplos pasados reales |
| Tier ambiguo | Presentar tabla comparativa CORE/Ops/Comercial con impacto en memoria |

---

## 8 · Anti-patterns · Nunca hacer aquí

- ❌ Avanzar a S2 sin confirmación explícita "spec completa" — Specification Drift empieza aquí [E 08 Anti-Pattern 2]
- ❌ Asumir el tier sin preguntar — condiciona 5 sistemas de memoria [D 09]
- ❌ Preguntar "¿qué features necesitas?" — vocabulario técnico que el usuario no tiene [E 07 C3 F34]
- ❌ Saltarse spec-by-example — los ejemplos revelan assumptions que el texto verbal nunca revela [E 07 F30]
- ❌ Aceptar R-G-C-C-O-V con elementos vacíos [E 07 F33]
- ❌ Mezclar preguntas de distintos niveles en una sola — kitchen sink interview [KB-base 09 A1]
- ❌ Corregir al usuario más de 2 veces sobre la misma área → `/clear` y restart [KB-base 09 A1]
- ❌ Interview >45 min: síntoma de scope explosion · proponer enfoque en 1 agente primero

---

## Mensaje al usuario al terminar

```
✅ Stage 1 · Elicitation COMPLETA
   Niveles cubiertos:    4/4 (Superficie · Flujo · Excepciones · Criterios)
   R-G-C-C-O-V:          6/6 ✓
   Spec-by-example:      3 positivos · 2 negativos ✓
   Spec Clarity:         10/10 ✓
   Tier declarado:       {CORE | Ops | Comercial}
   Tiempo wall-clock:    {N} min

   elicitation_spec.md guardado en runs/{run_id}/
   Usuario confirmó:     "spec completa" ✓

   ▶ Procediendo a Stage 2 · KB Coverage Check...
```
