# Stage 4 · Pipeline Design

## Propósito

Diseñar el pipeline completo del agente a construir: N stages con sus 8 sub-elementos cada uno, más el modelo sugerido por stage. Este archivo es el **blueprint de construcción** que S6 usa para generar código. Un pipeline sub-especificado aquí produce código ambiguo en S6 y fallos detectados recién en S8.

---

## 1 · Input

| Fuente | Contenido |
|---|---|
| `runs/<run_id>/elicitation_spec.md` | Spec completa · tier · R-G-C-C-O-V · casos de uso |
| `runs/<run_id>/complexity_architecture.md` | Patrón elegido · N stages proyectados · coordination diagram |
| `runs/<run_id>/kb_coverage.json` | KBs disponibles para citar en cada stage |
| KB-base `02_fundamentos-y-arquitectura.md` | Formato de 8 sub-elementos por stage |
| KB-E `03_pipeline-robustness-lifecycle.md` | Checkpointing y robustez del pipeline [E 03] |
| `SPEC.md` | Guía de modelo sugerido por stage |

---

## 2 · Proceso

**Paso 1 — Definir el número exacto de stages**
- Basado en `complexity_architecture.md`, confirmar N stages
- Cada stage debe tener un único output verificable
- Regla: un stage que hace dos cosas distintas → dividir en dos stages

**Paso 2 — Para cada stage, completar los 8 sub-elementos**

Estructura obligatoria por stage:

```markdown
### Stage N · <nombre>

| Sub-elemento | Contenido |
|---|---|
| **Input** | Archivos/datos que consume |
| **Proceso** | Qué hace · algoritmo/patrón · KBs usados |
| **Output** | Artefacto producido · ruta canónica |
| **Modelo** | Qué tipo de modelo sugerido · justificación |
| **Costo** | Nota de uso · sin dólares (corre sobre tu Claude Code) |
| **Validación** | Checklist verificable de que el stage salió bien |
| **Fallback** | Qué hacer si el stage falla |
| **Anti-patterns** | Qué evitar específicamente en este stage |
```

**Paso 3 — Asignar el modelo sugerido por stage** [SPEC.md]

Guía de modelo sugerido (advisory · usa el snapshot que tengas configurado en Claude Code):

| Tipo de stage | Modelo sugerido | Justificación |
|---|---|---|
| Discovery · razonamiento crítico | Modelo de **razonamiento fuerte** (ej. Claude Opus) | Máxima capacidad · decisiones no reversibles |
| Bulk reading · análisis KB | Modelo **rápido y capaz** (ej. Claude Sonnet) | Alto volumen · lecturas repetidas |
| Generación de código | Modelo **rápido y capaz** (ej. Claude Sonnet) | Bulk generation en ventana limpia |
| Evaluación externa | Sub-agente en ventana limpia distinta (o **GPT-4o-mini** si tienes `OPENAI_API_KEY`) | Evaluador ≠ generador · evita sycophancy [E 08] |
| Verificación adversarial | Tercer sub-agente en ventana limpia (o **Kimi** vía OpenRouter si tienes `OPENROUTER_API_KEY`) | Tercera opinión · multi-judge panel [E 01 §4 via KB-E] |
| Publicación | Modelo **rápido y capaz** (ej. Claude Sonnet) | Escritura local (Notion opcional si tienes ese MCP) |

Cómo se lanza cada stage: como sub-agente con la **herramienta Task** de Claude Code (ventana limpia). No hay router externo ni gestión de claves.

**Paso 4 — Marcar stages con Stage Isolation** [E 03 Estrategia 3 · Cambio #1 v2.0]

Para cada stage marcado con Stage Isolation en `complexity_architecture.md`:
- Especificar: "sub-agente en ventana limpia · recibe solo: {input específico}"
- Especificar: "solo el RESULTADO vuelve al orchestrator"
- Esto elimina saturación de contexto (riesgo #1) [E 03 F16]

**Paso 5 — Definir checkpointing por stage** [E 03 Estrategia 1 · Cambio #4 v2.0]

Para cada stage, documentar el formato del checkpoint:
```python
checkpoint.save_stage(N, {
    "result": {<output específico>},
    "metadata": {"model": model_used, "duration_s": int},
    "summary": "<resumen comprimido para recovery>"
})
```

**Paso 6 — Nota de uso (sin USD)**

ALAN-4AI corre sobre tu Claude Code (plan Max/Pro o tu propia API key); no hay cobro aparte por stage. Documenta, si acaso, una nota cualitativa de uso típico (qué stages hacen más trabajo), pero **sin cifras en dólares**.

**Paso 7 — Guardar checkpoint S4**
```python
await checkpoint.save_stage(4, {
    "result": {"pipeline_path": "runs/<run_id>/pipeline_design.md", "n_stages": N},
    "metadata": {"model": "<snapshot que uses>", "duration_s": elapsed},
    "summary": f"Pipeline {N} stages diseñado"
})
```

---

## 3 · Output

`runs/<run_id>/pipeline_design.md` — blueprint completo del agente:

```markdown
# Pipeline Design · <nombre-agente>
Run ID: <run_id> · Tier: {tier} · Patrón: {patrón}

## Resumen
- N stages · M sub-agentes · Stage Isolation: {SÍ/NO en N stages}

## Stage 0 · <nombre>
| Sub-elemento | Contenido |
|---|---|
| Input | ... |
| Proceso | ... |
| Output | ... |
| Modelo | ... |
| Costo | nota de uso (sin USD) |
| Validación | ... |
| Fallback | ... |
| Anti-patterns | ... |

[... stages N-1 adicionales ...]

## Modelo sugerido por stage
| Stage | Modelo sugerido | Razón |
|---|---|---|
| S0 | none | preflight |
| S1 | razonamiento fuerte (ej. Claude Opus) | discovery |
| ... | ... | ... |

## Checkpointing Summary
| Stage | Output guardado |
|---|---|
| S0 | preflight.json |
| S1 | elicitation_spec.md |
| ... | ... |
```

---

## 4 · Modelo

**Modelo rápido y capaz (ej. Claude Sonnet)** · diseño de pipeline con lecturas repetidas de KB y spec.

Justificación: la spec y los KBs ya están en contexto desde stages anteriores. El pipeline design no requiere razonamiento nivel Opus; requiere aplicación precisa de la estructura de 8 sub-elementos.

Cómo se lanza: como sub-agente con la herramienta Task (ventana limpia), recibiendo la spec + patrones KB + la decisión de arquitectura.

---

## 5 · Costo estimado

Corre sobre tu Claude Code (plan Max/Pro o API propia); no hay cobro aparte.

---

## 6 · Validación

- [ ] `pipeline_design.md` existe con N stages documentados
- [ ] Cada stage tiene los 8 sub-elementos completos (sin "N/A" sin justificación)
- [ ] Modelo sugerido asignado a cada stage
- [ ] Stages con Stage Isolation marcados explícitamente
- [ ] Formato de checkpoint documentado por stage
- [ ] `checkpoint stage_4.json` guardado
- [ ] **Listo para S5 Memory Strategy**

---

## 7 · Fallback

| Falla | Acción |
|---|---|
| Spec demasiado vaga para diseñar stages | Volver a S1 con preguntas específicas sobre flujo paso-a-paso |
| N stages >15 | Warning: "pipeline excesivamente largo · divide en 2 agentes" · GATE 2 debe aprobar |
| Modelo sugerido no disponible | Usar el modelo con el que tengas configurado Claude Code · documentar en pipeline |
| Stage isolation no claro para un stage | Asumir: toda llamada LLM en pipeline >5 stages usa sub-agente con ventana limpia [E 03] |

---

## 8 · Anti-patterns · Nunca hacer aquí

- ❌ Stage sin output verificable → el agente nunca sabe si el stage terminó bien
- ❌ Asignar el mismo modelo/ventana al generador Y al evaluador → Evaluation Blindness [E 08 Anti-Pattern 4]
- ❌ Diseñar stages sin checkpointing → si el run cae, pérdida total [E 03 Estrategia 1]
- ❌ Ignorar Stage Isolation en pipeline >8 stages → Context Accumulation sin curation [E 08 Anti-Pattern 1]
- ❌ Pipeline "kitchen sink" con un solo stage que hace todo → anti-pattern #1 [KB-base 09 A1]

---

## Mensaje al usuario al terminar

```
✅ Stage 4 · Pipeline Design OK
   Stages diseñados:    {N}
   Sub-agentes:         {M}
   Stage Isolation:     {K} stages en ventana limpia
   Modelo sugerido:     {N}/N stages con modelo asignado
   Checkpointing:       {N}/N stages con formato de checkpoint

   ▶ Procediendo a Stage 5 · Memory Strategy...
```
