# Stage 8 · External Evaluation ⭐ · sub-agente en ventana limpia distinta

## Propósito

Ejecutar evaluación externa con un evaluador **distinto** al generador. Por defecto, el evaluador es un **sub-agente Claude en ventana limpia DISTINTA** a la que generó, con rol adversarial. *(Opcional)* si tienes `OPENAI_API_KEY`, ese sub-agente puede correr con **GPT-4o-mini** (cross-provider). Esto mata el **Evaluation Blindness**: la causa #1 de fallos en meta-agentes 2026 es el sycophancy bias cuando el mismo contexto que genera también evalúa. [E 08 Anti-Pattern 4]

El evaluador corre los **13 anti-patterns** (5 Anthropic + 4 meta-agente + 4 memoria) más los **5 tests originales** de calidad. Solo pasa con PASS en todas las categorías.

> **Principio invariante:** el evaluador NUNCA es la ventana que generó el código. En modo mono-proveedor el evaluador sigue siendo Claude, pero en una **ventana limpia distinta** con instrucción adversarial. El modo cross-provider (otro proveedor de modelo) es un refuerzo opcional, no un requisito.

---

## 1 · Input

| Fuente | Contenido |
|---|---|
| `output/{nombre}/CLAUDE.md` | Archivo generado por S6 |
| `output/{nombre}/agent.md` | Archivo generado por S6 |
| `output/{nombre}/stages/` | Todos los stages generados |
| `runs/<run_id>/elicitation_spec.md` | Spec original para comparar contra output |
| `CLAUDE.md §13 ANTI-PATTERNS` | Lista completa de los 13 anti-patterns |
| KB-base `09_antipatrones-y-sota.md` | Definiciones y señales de detección |
| KB-E `08_antipatterns-failure-modes.md` | Anti-patterns de meta-agente |
| KB-D `06_anti-patterns-criticos.md` | Anti-patterns de memoria |

---

## 2 · Proceso

**Paso 1 — Preparar paquete de evaluación para el sub-agente evaluador**

```
PAQUETE EVALUACIÓN EXTERNA:
────────────────────────────────────────
AGENTE A EVALUAR: {nombre}
TIER: {CORE | Ops | Comercial}

CLAUDE.md:
[contenido completo]

AGENT.MD:
[contenido completo]

STAGES (primeros N relevantes):
[contenido]

SPEC ORIGINAL (referencia):
[R-G-C-C-O-V + casos de uso]
────────────────────────────────────────
INSTRUCCIONES PARA EL EVALUADOR:
Eres un evaluador externo de agentes Claude. Tu trabajo es encontrar problemas,
NO aprobar por defecto. Para cada anti-pattern: busca activamente señales de
presencia. Si no encuentras evidencia clara de ausencia → marcar como FAIL.
```

**Paso 1.2 — Solo MODO B: formato PRE/POST obligatorio en el paquete** ⭐ [lección de runs de upgrade]

> En upgrades, el evaluador confunde el audit (defectos que se CORRIGIERON) con el resultado. En un run de upgrade real, el evaluador rechazó 45/100 con 6 hallazgos — los 6 con premisa falsa por esta confusión. Con el formato corregido (bloques PRE/POST rotulados), otro run aprobó 85/100 con 0 premisas falsas.

El paquete de evaluación en Modo B DEBE tener dos bloques rotulados:
```
=== ESTADO PRE-UPGRADE (defectos detectados en el audit · esto es lo que se CORRIGIÓ, no el resultado) ===
{hallazgos de S1b}
=== RESULTADO POST-UPGRADE (esto es lo que evalúas) ===
{extractos REALES de los archivos ya escritos + lista de archivos modificados + lista NO-tocados (no-regresión)}
```
Y el system prompt del evaluador debe decir explícitamente que evalúe SOLO el resultado.

**Paso 1.5 — Garantizar carga de `.env.local` en el sub-agente (solo si activas cross-provider)** ⭐

> **Causa raíz documentada:** un sub-agente evaluador falló con `401: auth header format should be Bearer sk-...`. Diagnóstico posterior confirmó que la key estaba correcta — el sub-agente Task no heredó `process.env` y mandó key vacía. La misma falla puede pasar con `OPENAI_API_KEY` u `OPENROUTER_API_KEY`.

Este paso SOLO aplica si activaste el modo cross-provider (usar un modelo de otro proveedor como evaluador). En modo mono-proveedor (sub-agente Claude) no hay keys que cargar y puedes saltarlo.

Antes de spawnear el sub-agente cross-provider, el orquestador debe garantizar que las keys necesarias estén en `process.env` o pasarlas explícitamente en el paquete de evaluación. Patrón canónico:

```js
import { readFileSync, existsSync } from 'node:fs';
import { resolve } from 'node:path';
const envPath = resolve(process.cwd(), '.env.local');
if (existsSync(envPath)) {
  for (const line of readFileSync(envPath, 'utf-8').split('\n')) {
    const t = line.trim();
    if (!t || t.startsWith('#')) continue;
    const i = t.indexOf('=');
    if (i === -1) continue;
    const k = t.slice(0, i).trim();
    const v = t.slice(i+1).trim().replace(/^['"]|['"]$/g, '');
    if (!process.env[k]) process.env[k] = v;
  }
}
// Validar: OPENAI_API_KEY presente, no vacía, no en placeholder "PEGA_..."
if (!process.env.OPENAI_API_KEY || process.env.OPENAI_API_KEY.includes('PEGA_TU_KEY')) {
  throw new Error('OPENAI_API_KEY no cargada · revisar .env.local antes de spawn S8 cross-provider');
}
```

Si el sub-agente cross-provider reporta 401/403, el orquestador debe verificar PRIMERO que la key existe y no está en placeholder ANTES de cualquier retry o fallback. El 401 con key vacía y el 401 con key inválida son indistinguibles desde el lado del API — pero la causa raíz y el fix son distintos. (En modo mono-proveedor este error no aplica: no hay key externa.)

**Paso 2 — Spawn del sub-agente evaluador (ventana limpia distinta)**

Por defecto, lánzalo como sub-agente con la **herramienta Task** en una ventana limpia DISTINTA a la que generó el código, con rol adversarial:

```python
result = await Task(
    description="External Evaluator · 13 anti-patterns + 5 tests",
    prompt=evaluation_package,   # incluye la instrucción adversarial
    # DEFAULT: sub-agente Claude en ventana limpia distinta a la que generó.
    # OPCIONAL cross-provider: si tienes OPENAI_API_KEY, model="gpt-4o-mini".
)
```

- **DEFAULT (mono-proveedor):** sub-agente Claude, ventana limpia distinta, prompt adversarial ("busca fallos, NO apruebes por defecto").
- **OPCIONAL (cross-provider):** si tienes `OPENAI_API_KEY`, usa **GPT-4o-mini** como evaluador para una segunda opinión de otro proveedor. Sin la key → corre en mono-proveedor con un WARNING "corriendo en modo mono-proveedor", nunca un STOP.

**Paso 3 — El sub-agente evalúa los 13 anti-patterns**

### Anti-patterns Anthropic (5/5) [KB-base 09 A1]

| # | Anti-pattern | Señal de presencia | Cómo detectar |
|---|---|---|---|
| A1 | Kitchen Sink | CLAUDE.md >80 líneas sin justificación · instrucciones contradictorias | Contar líneas · buscar redundancias |
| A2 | Correcting Twice | Bucles que repiten la misma verificación >2 veces sin avance | Buscar loops sin exit condition |
| A3 | Over-specified CLAUDE.md | Instrucciones de implementación en vez de filosofía | Ratio "instrucción técnica" vs "principio" |
| A4 | Trust-then-verify gap | Smoke test ausente o no ejecutable antes de marcar done | Verificar tests/smoke_test_plan.md existe y es concreto |
| A5 | Infinite exploration | Stage sin output verificable · loop sin gate de salida | Cada stage tiene output concreto |

### Anti-patterns Meta-agente (4/4) [E 08]

| # | Anti-pattern | Señal de presencia | Cómo detectar |
|---|---|---|---|
| M1 | Context Accumulation sin curation | Stages acumulan historial sin comprimir ni aislar | Buscar Stage Isolation en stages críticos |
| M2 | Specification Drift | Output de stages posteriores contradice spec original | Comparar R-G-C-C-O-V vs agent.md output |
| M3 | Recursive Context Leakage | Sub-agentes reciben más contexto del necesario | Verificar que sub-agents reciben solo paquete específico |
| M4 | Capability Inheritance Bugs | El agente hereda herramientas que no necesita | Tools definidas en agent.md vs tools en spec |

### Anti-patterns Memoria (4/4) [D 06]

| # | Anti-pattern | Señal de presencia | Cómo detectar |
|---|---|---|---|
| D1 | Catastrophic forgetting | Fine-tuning de pesos LLM para memoria → sí hay referencia a fine-tuning | Buscar `fine-tune`, `finetune`, `RLHF` en archivos |
| D2 | Sycophancy drift | Identity Memory ausente en agente CORE → sin gate de aprobación | Para CORE: verificar IM con pipeline de aprobación |
| D3 | Memory bloat | Episodic Memory sin lifecycle de compresión | Verificar `compressSession()` o equivalente |
| D4 | False memories | Top-k retrieval fijo sin multi-señal · poda post-hoc | Verificar recuperación híbrida en EM |

**Paso 4 — El sub-agente ejecuta los 5 tests originales** [KB-base 09 · SPEC §6]

| Test | Qué verifica | Criterio de PASS |
|---|---|---|
| T1 Anti-Pattern | 0 de los 13 presentes | 13/13 PASS |
| T2 CLAUDE.md Hygiene | <80 líneas · cada línea justificada | Lines count + qualitative review |
| T3 Resource Profile | Perfil de modelos/esfuerzo por stage comunicado (sin dólares) | Perfil aparece en README.md o receipt |
| T4 Reproducibility | Smoke test ejecutable en <30 min | smoke_test_plan.md tiene input concreto + comando |
| T5 Model Coverage | Modelo (tipo) asignado para cada stage | Todos los stages con modelo asignado |

**Paso 5 — Calcular score y veredicto**

```
VEREDICTO:
  Si 13/13 anti-patterns PASS y 5/5 tests PASS → "AGENTE_LISTO"
  Si cualquier anti-pattern FAIL o test FAIL → "NECESITA_ITERACION"

Para cada FAIL: especificar
  - Qué stage re-ejecutar (S6 para código · S5 para memoria · etc.)
  - Qué cambiar exactamente
  - Por qué es un problema (citar fuente: KB-base/E/D)
```

**Paso 6 — Guardar checkpoint S8**

```python
await checkpoint.save_stage(8, {
    "result": {
        "evaluator_mode": "mono-proveedor | cross-provider",
        "evaluator_model": evaluator_model,   # "claude-<snapshot>" o "gpt-4o-mini" si cross-provider
        "anthropic_5": score_anthropic,
        "meta_agent_4": score_meta,
        "memoria_4": score_memoria,
        "tests_5": score_tests,
        "verdict": verdict,
        "fails": fail_list
    },
    "metadata": {"model": evaluator_model, "duration_s": elapsed},
    "summary": f"Evaluación externa: {verdict} · {sum([score_anthropic,score_meta,score_memoria])}/13 AP · {score_tests}/5 tests"
})
```

---

## 3 · Output

`runs/<run_id>/external_evaluation.json`:

```json
{
  "evaluator_mode": "mono-proveedor | cross-provider",
  "evaluator_model": "claude-<snapshot> | gpt-4o-mini",
  "verdict": "AGENTE_LISTO | NECESITA_ITERACION",
  "anti_patterns": {
    "anthropic": {
      "A1_kitchen_sink": "PASS",
      "A2_correcting_twice": "PASS",
      "A3_over_specified": "PASS",
      "A4_trust_then_verify": "PASS",
      "A5_infinite_exploration": "PASS"
    },
    "meta_agent": {
      "M1_context_accumulation": "PASS",
      "M2_specification_drift": "PASS",
      "M3_recursive_leakage": "PASS",
      "M4_capability_inheritance": "PASS"
    },
    "memoria": {
      "D1_catastrophic_forgetting": "PASS",
      "D2_sycophancy_drift": "PASS",
      "D3_memory_bloat": "PASS",
      "D4_false_memories": "PASS"
    }
  },
  "tests": {
    "T1_anti_pattern": "PASS",
    "T2_claude_md_hygiene": "PASS",
    "T3_resource_profile": "PASS",
    "T4_reproducibility": "PASS",
    "T5_model_coverage": "PASS"
  },
  "fails": [],
  "re_execute_stages": []
}
```

---

## 4 · Modelo

**DEFAULT (mono-proveedor):** sub-agente **Claude en ventana limpia DISTINTA** a la que generó, con rol adversarial. Es el modo obligatorio y suficiente.

**OPCIONAL (cross-provider):** si tienes `OPENAI_API_KEY`, el evaluador puede correr con **GPT-4o-mini** para sumar la opinión de otro proveedor.

Justificación: [E 08 Anti-Pattern 4] — Evaluation Blindness es la causa #1 de fallos en meta-agentes 2026. Si el mismo contexto que generó el código en S6 también evalúa en S8, hay sycophancy bias garantizado. Por eso el evaluador corre en una **ventana limpia distinta** (Task con contexto fresco). Un modelo de otro proveedor (GPT-4o-mini) refuerza aún más la independencia, pero incluso sin él, la separación de ventanas ya rompe el sesgo de "soy el autor".

Lánzalo como sub-agente con la herramienta Task (ventana limpia distinta), pasándole el paquete de evaluación adversarial.

---

## 5 · Costo

Corre sobre tu Claude Code (plan Max/Pro o API propia); no hay cobro aparte. Si activas el modo cross-provider opcional (GPT-4o-mini vía `OPENAI_API_KEY`), aplica el costo de esa API según tu proveedor.

---

## 6 · Validación

- [ ] `external_evaluation.json` existe con `evaluator_mode` y `evaluator_model`
- [ ] 13 anti-patterns evaluados (5+4+4) con PASS/FAIL para cada uno
- [ ] 5 tests evaluados con PASS/FAIL
- [ ] Veredicto declarado: AGENTE_LISTO o NECESITA_ITERACION
- [ ] Si NECESITA_ITERACION: lista de stages a re-ejecutar con razón específica
- [ ] El evaluador corrió en ventana limpia DISTINTA a la que generó
- [ ] `checkpoint stage_8.json` guardado
- [ ] **Listo para S9 Adversarial Verification**

---

## 7 · Fallback

| Falla | Acción |
|---|---|
| Cross-provider (GPT-4o-mini) down / 429 | Fallback al modo mono-proveedor: sub-agente Claude en ventana limpia distinta con prompt adversarial + nota en receipt "evaluator fallback · mono-proveedor" |
| Sin `OPENAI_API_KEY` | Corre en modo mono-proveedor (default) · WARNING "corriendo en modo mono-proveedor" · NUNCA STOP |
| NECESITA_ITERACION en S6 (código) | Re-spawn sub-agente Code Generator con nota específica de qué cambiar |
| NECESITA_ITERACION en S5 (memoria) | Volver a S5 con tier ajustado o sistemas de memoria específicos |
| NECESITA_ITERACION en S1 (spec drift) | Alerta: "Specification Drift detectado · volver a S1 para alinear spec" |
| Evaluador aprueba todo sin evidencia | Inspeccionar manualmente: si da todo PASS sin justificación → forzar nueva evaluación con prompt más adversarial |

---

## 8 · Anti-patterns · Nunca hacer aquí

- ❌ Usar la MISMA ventana/contexto que generó el código como evaluador — rompe el principio de evaluador externo [E 08 Anti-Pattern 4]
- ❌ Auto-evaluación del orchestrator — el mismo sesgo que queremos eliminar [CLAUDE.md §EVALUADOR EXTERNO]
- ❌ Hacer STOP por falta de `OPENAI_API_KEY` — el modo mono-proveedor es el default válido, no un error
- ❌ Ignorar NECESITA_ITERACION y avanzar a S9 — S9 evaluará un agente roto
- ❌ Scoring sin justificación por anti-pattern — "PASS porque se ve bien" no es evaluación
- ❌ Evaluar solo CLAUDE.md e ignorar stages/ — los anti-patterns de meta-agente están en los stages
- ❌ No incluir anti-patterns de memoria para agentes CORE — son los más difíciles de detectar [D 06]

---

## Mensaje al usuario al terminar

```
✅ Stage 8 · External Evaluation OK
   Evaluador:           Ventana limpia distinta ✓ ({mono-proveedor | cross-provider · GPT-4o-mini})
   Anti-patterns (13):  {A}/5 Anthropic · {M}/4 meta-agente · {D}/4 memoria
   Tests (5):           {T}/5
   Veredicto:           {AGENTE_LISTO | NECESITA_ITERACION}

   {si NECESITA_ITERACION}
   ⚠️ Fallos detectados:
   {lista de fails con stage a re-ejecutar}

   ▶ Procediendo a Stage 9 · Adversarial Verification...
```
