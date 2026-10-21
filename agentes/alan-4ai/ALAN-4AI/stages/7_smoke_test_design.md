# Stage 7 · Smoke Test Design · modelo rápido y capaz

## Propósito

Diseñar un **plan de smoke test ejecutable** para el agente generado en S6. El plan debe tener un caso concreto (no hipotético), métricas verificables, y los 3 escenarios estándar (✅ salió / ⚠️ parcial / 🚨 falló). El plan es lo que el usuario ejecuta para confirmar que el agente funciona antes de marcarlo `LISTO`.

Este stage NO ejecuta el test — lo diseña. La ejecución es responsabilidad del usuario o de un runner externo.

---

## 1 · Input

| Fuente | Contenido |
|---|---|
| `runs/<run_id>/elicitation_spec.md` | Casos de uso · ejemplos positivos + negativos · criterios de éxito |
| `runs/<run_id>/pipeline_design.md` | N stages · herramientas · outputs esperados por stage |
| `output/{nombre}/agent.md` | Invocación exacta del agente generado |
| KB-base `08_calidad-costos-ops.md` | Patrón de smoke test con 3 escenarios |

---

## 2 · Proceso

**Paso 1 — Seleccionar caso concreto de smoke test**

El caso de smoke test debe cumplir:
- Cubre el happy path principal (caso de uso #1 de elicitation_spec.md)
- Input es pequeño (no usar video largo o documento extenso · objetivo: velocidad)
- Output es verificable manualmente en <5 minutos
- Input ligero (humo, no producción): un solo caso mínimo, sin cargas pesadas

Extraer de `elicitation_spec.md`:
- Input: ejemplo positivo #1
- Output esperado: descripción de la respuesta ideal
- Criterio de éxito: cómo medir si el output fue correcto

**Paso 2 — Diseñar los 3 escenarios**

```
ESCENARIO ✅ · Salió bien
  Condición: pipeline completo ejecutado · output generado · archivos persistidos
  Señales: {lista de qué verificar visualmente}
  Acción: marcar smoke test como PASS

ESCENARIO ⚠️ · Salió parcial
  Condición: pipeline ejecutado parcialmente · algún stage con warning
  Señales: {qué indica éxito parcial: checkpoint existe pero output incompleto}
  Acción: revisar logs · identificar stage fallido · re-ejecutar desde checkpoint

ESCENARIO 🚨 · Falló
  Condición: STOP antes de completar · error crítico
  Señales: {error message esperado · qué indica fallo total}
  Acción: revisar error_log.md · reportar exactamente qué dice el error
```

**Paso 3 — Escribir el comando de invocación exacto**

```
# Comando copy-paste para el usuario:
# Working directory: la carpeta de ALAN-4AI (donde descomprimiste esto)

# Opción A · invocación mínima:
# En Claude Code, escribir en el chat:
Lee output/{nombre}/agent.md y ejecútalo

# Opción B · con parámetros específicos:
Lee output/{nombre}/agent.md y ejecútalo con {param1}={valor} {param2}={valor}
```

**Paso 4 — Definir métricas del smoke test**

| Métrica | Valor esperado | Cómo verificar |
|---|---|---|
| Tiempo wall-clock | < {N} min | Reloj desde invocación hasta "✅ AGENTE LISTO" |
| Archivos generados | {N} archivos | PowerShell: `(Get-ChildItem output/{nombre}/ -Recurse).Count` · mac/linux: `find output/{nombre} -type f \| wc -l` |
| Checkpoints | {M} checkpoints | PowerShell: `(Get-ChildItem runs/ -Recurse -Filter "*.json").Count` · mac/linux: `find runs -name "*.json" \| wc -l` |
| Sin errores críticos | 0 STOPs inesperados | error_log.md vacío |

**Paso 5 — Definir criterios de PASS/FAIL**

```
PASS = todos estos:
  ✓ Pipeline completó sin STOP no controlado
  ✓ Output principal existe en {ruta esperada}
  ✓ Tiempo < {N} min

FAIL = cualquiera de estos:
  ✗ STOP en stage crítico (S1/S3/S6)
  ✗ Output principal ausente
  ✗ Error en error_log.md sin recovery
```

**Paso 6 — Escribir plan en `output/{nombre}/tests/smoke_test_plan.md`**

**Paso 7 — Guardar checkpoint S7**

```python
await checkpoint.save_stage(7, {
    "result": {
        "smoke_test_path": f"output/{nombre}/tests/smoke_test_plan.md",
        "test_case": case_summary,
        "pass_criteria": pass_criteria
    },
    "metadata": {"model": model_snapshot, "duration_s": elapsed},
    "summary": f"Smoke test diseñado · caso: {case_summary}"
})
```

---

## 3 · Output

`output/{nombre}/tests/smoke_test_plan.md`:

```markdown
# Smoke Test Plan · {nombre-agente}
Generado por: ALAN-4AI · Run ID: {run_id}

## Caso de smoke test
- **Input:** {input concreto · copy-paste listo}
- **Output esperado:** {descripción del resultado ideal}
- **Criterio de éxito:** {qué verificar · cómo saber que salió bien}
- **Tiempo estimado:** {N} min

## Invocación exacta
\`\`\`
[comando copy-paste para el usuario]
\`\`\`

## Métricas a verificar
| Métrica | Valor esperado | Cómo verificar |
...

## Escenario ✅ · Salió bien
...

## Escenario ⚠️ · Salió parcial
...

## Escenario 🚨 · Falló
...

## Criterios PASS / FAIL
...
```

---

## 4 · Modelo

**Modelo rápido y capaz** (ej. Claude Sonnet, el snapshot que tengas configurado) · diseño de smoke test usando spec + pipeline ya en contexto.

Justificación: el smoke test es un documento de instrucciones claras, no requiere razonamiento de un modelo de razonamiento fuerte. Un modelo rápido aplica el patrón de los 3 escenarios correctamente. [SPEC.md §4]

Lánzalo como sub-agente con la herramienta **Task** (ventana limpia), pasándole `specContent + pipelineContent + agentMd`.

---

## 5 · Nota de ejecución

Corre sobre tu Claude Code (plan Max/Pro o API propia); no hay cobro aparte. El smoke test debe ser deliberadamente ligero (un solo caso mínimo) para validar rápido, no para simular carga de producción.

---

## 6 · Validación

- [ ] `output/{nombre}/tests/smoke_test_plan.md` existe
- [ ] Input es concreto (no hipotético ni genérico)
- [ ] Los 3 escenarios (✅ ⚠️ 🚨) están presentes con señales específicas
- [ ] Comando de invocación es copy-paste (Windows/PowerShell o mac/linux)
- [ ] Métricas tienen valores numéricos (no "rápido" sino "<5 min")
- [ ] Criterios PASS/FAIL son binarios y verificables
- [ ] Input del smoke test es mínimo (ligero, no carga de producción)
- [ ] `checkpoint stage_7.json` guardado

---

## 7 · Fallback

| Falla | Acción |
|---|---|
| Spec sin ejemplos concretos de S1 | Usar el primer caso de uso del pipeline como input del smoke test |
| Output esperado ambiguo | Definir criterio mínimo: "archivo {nombre} existe en {ruta}" |
| Input del smoke test demasiado pesado | Reducir input: usar versión resumida del caso de uso principal |
| Pipeline muy complejo para smoke test rápido | Smoke test solo stages S0-S3 (pipeline parcial) · nota explícita en plan |

---

## 8 · Anti-patterns · Nunca hacer aquí

- ❌ Smoke test con input hipotético ("imagina que hay un PDF") → no sirve para validar
- ❌ Criterios de éxito subjetivos ("respuesta coherente") → debe ser verificable en <30 seg
- ❌ Smoke test con input pesado (video largo, documento extenso) → no es smoke test, es producción
- ❌ Sin escenario 🚨 → el usuario no sabe qué hacer si falla [trust-then-verify anti-pattern · KB-base 09 A1]
- ❌ Comando de invocación con rutas relativas rotas → debe ser ejecutable desde el working dir definido

---

## Mensaje al usuario al terminar

```
✅ Stage 7 · Smoke Test Design OK
   Caso de test:        {resumen del input}
   Tiempo estimado:     {N} min
   Escenarios:          3 (✅ ⚠️ 🚨)

   Plan guardado en:    output/{nombre}/tests/smoke_test_plan.md

   ▶ Procediendo a Stage 8 · External Evaluation...
```
