# Stage 3 · Complexity & Architecture · modelo de razonamiento fuerte (ej. Claude Opus)

## Propósito

Decidir el patrón arquitectural correcto para el agente a construir. Aplicar la Heurística #1 Anthropic (preservada de v0.1): **si un single LLM call resuelve el problema, NO construir agente**. Si se justifica un agente, elegir entre los 5 patrones canónicos más SOTA. Si el resultado es multi-agente, producir coordination diagram explícito. Esta decisión es la entrada directa a GATE 1.

---

## 1 · Input

| Fuente | Contenido |
|---|---|
| `runs/<run_id>/elicitation_spec.md` | Spec completa · tier · casos de uso · edge cases |
| `runs/<run_id>/kb_coverage.json` | Coverage score · dominios cubiertos · gaps |
| KB-base `02_fundamentos-y-arquitectura.md` | 5 patrones canónicos Anthropic + heurísticas de selección |
| KB-E `03_pipeline-robustness-lifecycle.md` | Stage Isolation · Checkpointing · recovery [E 03] |
| KB-E `07_elicitacion-especificacion.md` | R-G-C-C-O-V confirmado de S1 |

---

## 2 · Proceso

**Paso 1 — Aplicar Heurística #1: ¿Single LLM call suficiente?** [KB-base 02 F3]

Criterios que indican single LLM call (NO construir agente):
- La tarea se resuelve en una sola llamada sin persistencia de estado
- No requiere memoria cross-session
- No necesita coordinación con otros sistemas
- No hay pasos paralelos o condicionados entre sí
- El output es directamente consumible por el usuario

Si todos aplican → **output: `single_llm_call`** · fin del pipeline · no construir agente · informar al usuario.

---

**Paso 2 — Evaluar las 4 opciones de complejidad** [KB-base 02 F3]

| Opción | Cuándo usarla | Señales en la spec |
|---|---|---|
| **A. Single LLM call** | Consulta directa · sin estado · sin loops | Sin pasos condicionados · output inmediato |
| **B. Workflow** (prompt chaining) | Pasos secuenciales predecibles · sin decisiones dinámicas | Pipeline lineal A→B→C documentado |
| **C. Single Agent** | Decisiones dinámicas · uso de tools · loops condicionales | Tool calls · memoria session · razonamiento iterativo |
| **D. Multi-agent** | Tareas paralelas · especialización de roles · context overflow en single | Sub-tareas independientes · roles diferenciados · > 12 stages |

---

**Paso 3 — Si Multi-agent: evaluar Stage Isolation** [E 03 Estrategia 3 · Cambio #1 v2.0]

Indicadores que requieren Stage Isolation (sub-agentes con ventana limpia):
- Pipeline proyectado > 8 stages
- Algún stage genera un sub-output que "contamina" el razonamiento del siguiente
- Stages de generación y evaluación en el mismo modelo → Evaluation Blindness [E 08 Anti-Pattern 4]
- Context window excedería 80% durante ejecución completa

Si Stage Isolation aplica → documentar qué stages corren en ventana limpia y por qué.

---

**Paso 4 — Seleccionar patrón arquitectural** [KB-base 02 F3]

| Patrón | Estructura | Cuándo es el correcto |
|---|---|---|
| **Prompt chaining** | A→B→C secuencial | Transformaciones predecibles sin branching |
| **Routing** | Input → clasificador → handler específico | Múltiples dominios/casos con lógica diferenciada |
| **Parallelization** | Input → N agentes simultáneos → agregador | Sub-tareas independientes que ganan en velocidad |
| **Orchestrator-Workers** | Orchestrator asigna dinámicamente a workers | Tareas impredecibles · orquestación adaptativa |
| **Evaluator-Optimizer** | Generator → Evaluator → loop iterativo | Calidad iterativa · self-correction con external judge |
| **SOTA** | Orchestrator-as-Builder con Stage Isolation | Meta-agentes · pipelines >8 stages · evaluación multi-modelo [E 03] |

---

**Paso 5 — Si Multi-agent: producir Coordination Diagram**

```
Coordination Diagram (ASCII obligatorio para multi-agente):

Input
  ↓
[Orchestrator] ←────────────────────────────────────────────┐
  ├─→ [Sub-agente A · modelo rápido y capaz · ventana limpia] ──→ checkpoint_A
  ├─→ [Sub-agente B · eval · ventana limpia distinta]          ──→ checkpoint_B
  └─→ [Sub-agente C · adversarial · ventana limpia distinta]   ──→ checkpoint_C
  ↓
Output consolidado
```

El diagrama debe especificar para cada sub-agente: modelo (o "ventana limpia" si es mono-proveedor), ventana (limpia o no), output que pasa al siguiente. Cada sub-agente se lanza con la herramienta **Task** de Claude Code. En modo cross-provider opcional, el sub-agente B puede usar **GPT-4o-mini** (si tienes `OPENAI_API_KEY`) y el C **Kimi** (si tienes `OPENROUTER_API_KEY`); sin esas claves, ambos corren como sub-agentes Claude en ventanas limpias distintas.

---

**Paso 6 — Proyectar N stages del pipeline**

Basado en la spec y el patrón elegido, estimar:
- Número de stages en el agente a construir (N)
- Qué stages requieren sub-agente separado
- Perfil de uso típico del agente (cuántos stages y sub-agentes se activan en un run normal)

---

**Paso 7 — Guardar checkpoint S3**

```python
await checkpoint.save_stage(3, {
    "result": {
        "option": "multi-agent|single-agent|workflow|single-llm",
        "pattern": "orchestrator-workers|evaluator-optimizer|...",
        "stage_isolation": True/False,
        "projected_stages": N,
        "coordination_diagram": diagram_ascii
    },
    "metadata": {"model": "<snapshot que uses>", "duration_s": elapsed},
    "summary": f"Arquitectura: {pattern} · {N} stages · isolation={stage_isolation}"
})
```

---

## 3 · Output

`runs/<run_id>/complexity_architecture.md`:

```markdown
# Complexity & Architecture Decision
Run ID: <run_id> · Tier: {CORE|Ops|Comercial}

## Opción seleccionada
**{A|B|C|D}** — {nombre de la opción}

## Justificación
{2-3 párrafos citando evidencia de KB y spec}

## Patrón arquitectural
**{patrón}** — Fuente: [KB-base 02 F3]

## Stage Isolation
**{SÍ|NO}** — {razón}
{Si SÍ: lista de stages que corren en ventana limpia}

## Pipeline proyectado
- Stages estimados: {N}
- Agentes requeridos: {M}
- Perfil de uso típico: {stages/sub-agentes activos en un run normal}

## Coordination Diagram
{diagrama ASCII si multi-agente}
```

---

## 4 · Modelo

**Modelo de razonamiento fuerte (ej. Claude Opus)** · decisión arquitectural crítica que afecta todo el pipeline posterior.

Justificación: elegir el patrón equivocado es el anti-pattern de mayor costo (construir un agente cuando single LLM basta desperdicia semanas). Un modelo de razonamiento fuerte tiene la capacidad suficiente para evaluar los trade-offs con citas específicas del KB. [SPEC.md §4]

Lánzalo como sub-agente con la herramienta **Task** (ventana limpia), pasándole la spec + los extractos de patrones del KB + el prompt de arquitectura.

---

## 5 · Nota de ejecución

Corre sobre tu Claude Code (plan Max/Pro o API propia); no hay cobro aparte. Este stage suele resolverse en 1-2 pasos de razonamiento sobre la spec + extractos del KB.

---

## 6 · Validación

- [ ] `complexity_architecture.md` existe con opción A/B/C/D declarada
- [ ] Heurística #1 documentada (¿se evaluó single LLM call primero?)
- [ ] Patrón arquitectural elegido con justificación que cita KB
- [ ] Si multi-agente: coordination diagram presente
- [ ] Si Stage Isolation activo: stages en ventana limpia listados
- [ ] Perfil de uso típico del agente proyectado
- [ ] `checkpoint stage_3.json` guardado
- [ ] **Listo para GATE 1**

---

## 7 · Fallback

| Falla | Acción |
|---|---|
| Spec insuficiente para decidir patrón | Volver a S1 con preguntas dirigidas sobre flujo y excepciones |
| Heurística #1 borderline (dudoso si single LLM o agente) | Presentar ambas opciones al usuario con costo/beneficio · usuario decide |
| Multi-agent proyectado >20 stages | Warning: "pipeline muy largo · considera dividir en 2 agentes independientes" |
| Modelo de razonamiento fuerte no disponible | Fallback a un modelo rápido y capaz (advertir: "decisión arquitectural puede ser menos precisa") |
| KB-base no cubrió patrones | Usar fallback a 5 patrones canónicos documentados en CLAUDE.md |

---

## 8 · Anti-patterns · Nunca hacer aquí

- ❌ Saltar la Heurística #1 — construir agente cuando single LLM basta es el anti-pattern más costoso [KB-base 02 F3]
- ❌ Elegir multi-agent sin coordination diagram → Recursive Context Leakage en S6 [E 08 Anti-Pattern 3]
- ❌ Combinar generación y evaluación en el mismo sub-agente → Evaluation Blindness [E 08 Anti-Pattern 4]
- ❌ Subestimar N stages — si se subestima mucho, GATE 2 tendrá sorpresas
- ❌ Usar frameworks externos (LangChain/CrewAI/AutoGen) — la arquitectura corre nativa sobre Claude Code con la herramienta Task [CLAUDE.md]
- ❌ No documentar Stage Isolation — S6 necesita saber qué stages corren en ventana limpia

---

## GATE 1 · ALCANCE (post-S3 · Plan Mode)

Presentar al usuario para aprobación:

```
🛑 GATE 1 · ALCANCE

Agente propuesto: {nombre}
Tier:             {CORE | Ops | Comercial}
Opción:           {A|B|C|D} — {nombre opción}
Patrón:           {patrón}
Stage Isolation:  {SÍ|NO}
Stages estimados: {N}
Perfil de uso:    {stages/sub-agentes activos en un run típico}
KB coverage:      {score:.2f} · gaps: {lista}

Opciones:
  ✅ Aprobar · continuar a S4
  ✏️  Ajustar scope · volver a S1
  ❌ Cancelar run
```

Si `auto_approve_gates=true` → GATE se salta automáticamente · registrar en receipt.

---

## Mensaje al usuario al terminar

```
✅ Stage 3 · Complexity & Architecture OK
   Heurística #1:       evaluada ({single-LLM descartado | aplicada})
   Opción elegida:      {A|B|C|D} — {nombre}
   Patrón:              {patrón}
   Stage Isolation:     {SÍ|NO}
   Stages proyectados:  {N}

   ⏸ GATE 1 en espera · revisa la decisión arquitectural arriba...
```
