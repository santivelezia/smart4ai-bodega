# Stage 6 · Code Generation ⭐ · sub-agente en ventana limpia

## Propósito

Generar TODOS los archivos del agente nuevo delegando a un sub-agente con ventana limpia (Stage Isolation). El orchestrator NO escribe código directamente. Pasa el paquete de input al sub-agente vía la herramienta Task, recibe solo el resultado, lo registra en checkpoint. Esto elimina la saturación de contexto del orchestrator y garantiza que el código se genera sin ruido de los stages anteriores. [E 03 Estrategia 3 · F16]

---

## 1 · Input

| Fuente | Contenido |
|---|---|
| `runs/<run_id>/elicitation_spec.md` | Spec completa · tier · R-G-C-C-O-V · casos de uso · ejemplos |
| `runs/<run_id>/complexity_architecture.md` | Patrón · N stages · Stage Isolation · coordination diagram |
| `runs/<run_id>/pipeline_design.md` | Blueprint completo · 8 sub-elementos por stage · routing |
| `runs/<run_id>/memory_spec.md` | Patrón 5 · sistemas activos · schemas · paths |
| KB-base `03_claude-code-completo.md` | Estructura canónica de archivos de agente |
| KB-base `04_prompt-y-system-design.md` | Reglas CLAUDE.md <80 líneas · agent.md <300 líneas |

---

## 2 · Proceso

**Paso 1 — Preparar el paquete de input para el sub-agente**

Construir un string autocontenido con todo lo necesario:

```
PAQUETE PARA SUB-AGENTE CODE GENERATOR:
────────────────────────────────────────
SPEC COMPLETA: [contenido de elicitation_spec.md]
PIPELINE: [contenido de pipeline_design.md]
MEMORIA: [contenido de memory_spec.md]
TIER: {CORE | Ops | Comercial}
NOMBRE AGENTE: {nombre-kebab-case}
────────────────────────────────────────
INSTRUCCIONES:
Genera la estructura completa del agente en output/{nombre}/.
Estructura canónica obligatoria:
  CLAUDE.md        (<80 líneas · filosofía + restricciones + anti-patterns)
  agent.md         (<300 líneas · pipeline completo + invocación)
  README.md        (propósito + invocación + tier)
  stages/          (N archivos · uno por stage del pipeline diseñado)
  templates/       (plantillas que el agente genera)
  tests/           (smoke test plan + casos verificables)
  runs/            (directorio vacío · checkpoints en runtime)

Reglas de construcción:
- CLAUDE.md: prune ruthless · <80 líneas · cada línea pasa "would removing this cause Claude to make mistakes?"
- agent.md: pipeline completo con todos los stages del blueprint
- Stages: 8 sub-elementos por stage (igual estructura que stages/ de este proyecto)
- Memory: incluir archivos de memoria según tier (memory_spec.md como referencia)
- Sub-agentes: lánzalos con la herramienta Task (ventana limpia) · NUNCA gestión de claves ni router externo
- Comandos de shell: una sola línea · Windows → PowerShell · macOS/Linux → bash

No usar frameworks externos (LangChain/CrewAI/AutoGen).
No escribir código de memoria que no esté en la spec.
```

**Paso 2 — Spawn sub-agente vía herramienta Task (ventana LIMPIA)** [E 03 Estrategia 3]

Lánzalo como sub-agente con la herramienta Task, con ventana FRESCA:

```python
result = await Task(
    description="Code Generator · genera estructura completa del agente",
    prompt=paquete_input,
    # Modelo sugerido: uno rápido y capaz (ej. Claude Sonnet) para generación en volumen,
    # distinto/independiente del contexto que usó el orchestrator para S1-S5.
    # La ventana de este sub-agente empieza limpia — no ve el historial del orchestrator
)
# Solo el resultado (lista de archivos generados) vuelve al orchestrator
```

Regla crítica: el sub-agente recibe SOLO el paquete de input. No ve los stages previos del orchestrator. Esto previene Context Accumulation sin curation. [E 08 Anti-Pattern 1]

**Paso 3 — El sub-agente genera y escribe los archivos**

El sub-agente ejecuta internamente:
1. Crear directorio `output/{nombre}/` con estructura canónica
2. Escribir CLAUDE.md con prune ruthless (verifica línea por línea)
3. Escribir agent.md (<300 líneas · pipeline del blueprint)
4. Escribir stages/ (N archivos del pipeline diseñado · 8 sub-elementos cada uno)
5. Escribir templates/ (plantillas del agente)
6. Escribir tests/ (smoke test plan inicial)
7. Escribir README.md
8. Crear `runs/` vacío

**Paso 4 — Verificar que el sub-agente retornó resultado completo**

El orchestrator verifica en el resultado:
```
✓ output/{nombre}/CLAUDE.md existe
✓ output/{nombre}/agent.md existe
✓ output/{nombre}/stages/ tiene N archivos
✓ output/{nombre}/tests/ tiene smoke test
✓ output/{nombre}/README.md existe
✓ Total archivos: {N}
✓ Líneas CLAUDE.md: {K} (<80 ✓)
✓ Líneas agent.md: {L} (<300 ✓)
```

Si el sub-agente reporta error o los archivos no existen → fallback.

**Paso 5 — Verificación de caps en CLAUDE.md y agent.md**

Leer los archivos generados y verificar:
- CLAUDE.md: PowerShell `(Get-Content CLAUDE.md).Count` (o `wc -l CLAUDE.md` en mac/linux) < 80
- agent.md: < 300
- Si excede caps → pedir al sub-agente que pode (nueva llamada con ventana limpia)

**Paso 6 — Guardar checkpoint S6**

```python
await checkpoint.save_stage(6, {
    "result": {
        "agent_path": f"output/{nombre}/",
        "files_generated": file_list,
        "claude_md_lines": claude_lines,
        "agent_md_lines": agent_lines,
        "stages_count": n_stages
    },
    "metadata": {"model": "<snapshot que usaste>", "duration_s": elapsed},
    "summary": f"Generado {len(file_list)} archivos · CLAUDE.md={claude_lines}L · agent.md={agent_lines}L"
})
```

---

## 3 · Output

Estructura `output/{nombre}/` completa:

```
output/{nombre}/
├── CLAUDE.md          (<80 líneas · filosofía + restricciones + anti-patterns)
├── agent.md           (<300 líneas · pipeline + invocación + contexto)
├── README.md          (propósito + invocación + tier)
├── stages/
│   ├── 0_{nombre}.md  (8 sub-elementos)
│   ├── 1_{nombre}.md
│   └── ...            (N stages según pipeline_design.md)
├── templates/
│   └── {plantillas que el agente usa o genera}
├── tests/
│   ├── smoke_test_plan.md   (plan ejecutable · caso concreto)
│   └── test_cases.md        (inputs/outputs esperados)
└── runs/              (vacío · checkpoints en runtime)
```

`runs/<run_id>/code_generation_manifest.json`:
```json
{
  "agent_name": "{nombre}",
  "agent_path": "output/{nombre}/",
  "files_generated": ["{lista}"],
  "claude_md_lines": 67,
  "agent_md_lines": 248,
  "stages_count": 8,
  "sub_agent_model": "<snapshot que usaste>",
  "stage_isolation": true
}
```

---

## 4 · Modelo

**Modelo rápido y capaz (ej. Claude Sonnet) en un sub-agente con ventana limpia** · generación bulk de múltiples archivos.

Justificación: Stage Isolation requiere que el trabajo pesado ocurra en un sub-agente separado (ventana limpia) · un modelo rápido y capaz genera código de alta calidad para trabajo en volumen · la spec y el pipeline están condensados en el paquete de input, así que el sub-agente arranca con todo lo necesario sin arrastrar el historial del orchestrator. [SPEC.md §4]

El orchestrator usa su propio contexto solo para verificar el resultado. El sub-agente hace el trabajo pesado con ventana limpia.

**Principio de versionado:** cuando registres el agente, anota el **snapshot exacto** del modelo que usaste (nunca un alias dinámico).

---

## 5 · Costo

Corre sobre tu Claude Code (plan Max/Pro o API propia); no hay cobro aparte. El trabajo pesado ocurre en un sub-agente con ventana limpia (típico: 10-20 archivos · 200-400 líneas totales).

---

## 6 · Validación

- [ ] `output/{nombre}/` directorio existe
- [ ] `CLAUDE.md` ≤ 80 líneas
- [ ] `agent.md` ≤ 300 líneas
- [ ] `stages/` tiene exactamente N archivos (N = stages del pipeline_design.md)
- [ ] `tests/` tiene smoke test plan
- [ ] `README.md` existe
- [ ] `runs/` directorio existe (vacío)
- [ ] `code_generation_manifest.json` guardado
- [ ] Sub-agente usó ventana limpia (no tiene historial de S0-S5)
- [ ] `checkpoint stage_6.json` guardado

---

## 7 · Fallback

| Falla | Acción |
|---|---|
| Sub-agente context overflow durante generación | Checkpoint inmediato · spawn nuevo sub-agente con ventana fresca · pasar solo spec + pipeline relevante [E 03] |
| CLAUDE.md excede 80 líneas | Nueva llamada al sub-agente: "Poda CLAUDE.md a <80 líneas · prune ruthless · mantén solo líneas que causarían error si se eliminan" |
| agent.md excede 300 líneas | Nueva llamada al sub-agente: "Comprime agent.md a <300 líneas · elimina redundancias · mantén pipeline completo" |
| Archivos faltantes en estructura canónica | Nueva llamada al sub-agente con lista específica de archivos faltantes |
| El snapshot de modelo previsto no está disponible | Fallback a otro snapshot equivalente (advertir: "generación puede variar") |
| Sub-agente excede hard limit recursión N=3 | STOP · reportar en error_log · usuario decide split de la tarea [E 08 Anti-Pattern 3] |
| Código generado con router externo o gestión de claves | Post-processing: elimínalo · los sub-agentes se lanzan con la herramienta Task · Claude Code ya está autenticado con tu sesión |

---

## 8 · Anti-patterns · Nunca hacer aquí

- ❌ Orchestrator escribe código directamente → mata Stage Isolation [E 03 Estrategia 3]
- ❌ Sub-agente recibe historial de conversación del orchestrator → Context Accumulation sin curation [E 08 Anti-Pattern 1]
- ❌ Generar CLAUDE.md >80 líneas sin prune → kitchen sink anti-pattern [KB-base 09 A1.3]
- ❌ Usar frameworks externos (LangChain/CrewAI/AutoGen) en el código generado [CLAUDE.md]
- ❌ Incluir gestión de claves o un router externo en el código generado → los sub-agentes se lanzan con la herramienta Task; Claude Code usa tu sesión [CLAUDE.md]
- ❌ Generar código sin memoria según tier → Capability Inheritance Bugs [E 08 Anti-Pattern 4]
- ❌ No verificar caps después de generación → S8 detectará el exceso como anti-pattern

---

## Mensaje al usuario al terminar

```
✅ Stage 6 · Code Generation OK
   Sub-agente:          modelo rápido y capaz · ventana limpia ✓
   Stage Isolation:     ACTIVO ✓
   Archivos generados:  {N}
   CLAUDE.md:           {K} líneas (<80 ✓)
   agent.md:            {L} líneas (<300 ✓)
   Stages generados:    {M}

   output/{nombre}/ creado y listo para evaluación.

   ▶ Procediendo a Stage 7 · Smoke Test Design...
```
