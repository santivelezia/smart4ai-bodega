# Stage 9 · Adversarial Verification ⭐ · tercer sub-agente en ventana limpia

## Propósito

Tercera opinión obligatoria que **refuta** lo que S8 aprobó (multi-judge panel). El tercer sub-agente adversarial recibe el output de S8 y tiene una sola misión: encontrar razones para contradecirlo. Si contradice al evaluador (S8) en algún punto → flag para Plan Mode antes de avanzar. Si concuerda → el agente pasó doble validación independiente.

Multi-judge panel con tres ventanas limpias independientes: **un sub-agente genera (S6) · un sub-agente distinto evalúa (S8) · un tercer sub-agente refuta (S9)**. La clave no es qué proveedor use cada juez, sino que **ninguno es la ventana que generó el código**. [KB-E 01 §4 — el multi-judge panel elimina el 70%+ de false positives de la evaluación single-model]

> **Modo DEFAULT (mono-proveedor):** S9 es un **tercer sub-agente Claude en ventana limpia distinta**, con rol adversarial explícito.
> **Modo OPCIONAL (cross-provider):** si defines `OPENROUTER_API_KEY` en `.env.local`, el tercer juez puede correr con **Kimi** (Moonshot vía OpenRouter) para una tercera opinión de otro proveedor. Es opcional: sin esa key, ALAN-4AI corre en modo mono-proveedor sin STOP — como mucho un WARNING "corriendo en modo mono-proveedor".

---

## 1 · Input

| Fuente | Contenido |
|---|---|
| `runs/<run_id>/external_evaluation.json` | Veredicto del evaluador (S8) + 13 resultados de anti-patterns |
| `output/{nombre}/CLAUDE.md` | Para verificación independiente |
| `output/{nombre}/agent.md` | Para verificación independiente |
| `runs/<run_id>/elicitation_spec.md` | Spec original como referencia de verdad |

---

## 2 · Proceso

**Paso 1 — Preparar paquete adversarial para el tercer juez**

```
PAQUETE VERIFICACIÓN ADVERSARIAL:
────────────────────────────────────────
CONTEXTO: Eres el verificador adversarial de un sistema de evaluación multi-juez.
El evaluador (S8) acaba de aprobar el siguiente agente. Tu misión NO es
confirmar — es REFUTAR. Busca activamente errores que el evaluador pudo haber
pasado por alto. El sesgo humano es aprobar; tu sesgo debe ser cuestionar.

RESULTADO DEL EVALUADOR (S8):
{external_evaluation.json completo}

CLAUDE.md DEL AGENTE:
{contenido}

AGENT.MD DEL AGENTE:
{contenido}

SPEC ORIGINAL (R-G-C-C-O-V):
{contenido}
────────────────────────────────────────
INSTRUCCIONES DE REFUTACIÓN:
Para cada ítem que el evaluador marcó PASS, responde:
  - ¿Hay evidencia suficiente para PASS o simplemente no hay evidencia de FAIL?
  - ¿El anti-pattern podría existir de forma sutil que el evaluador no detectó?
  - ¿El criterio de PASS usado por el evaluador es el correcto para este caso específico?

REGLA ANTI-FALSO-POSITIVO: antes de marcar un FAIL, verifica la premisa contra
el archivo real. Si vas a afirmar "CLAUDE.md >80 líneas", cuenta las líneas
primero. No apliques anti-patterns de multi-agente (context accumulation,
recursive leakage) a un single-agent que no usa sub-agentes. Un FAIL con premisa
falsa es peor que un PASS — contamina el arbitraje.

Sé específico. "Concuerdo" sin evidencia no es refutación.
"Podría haber un problema en X porque Y" sí es refutación.
```

**Paso 1.5 — Garantizar carga de `.env.local` en el sub-agente** *(solo si activas cross-provider)*

> Este paso SOLO aplica al modo cross-provider opcional. En modo mono-proveedor (default) no hay keys que cargar: el tercer juez es un sub-agente Claude en ventana limpia y no requiere `.env.local`.

Un sub-agente lanzado con la herramienta Task **no hereda automáticamente `process.env`** del proceso padre. Si vas a usar el proveedor externo opcional (Kimi vía OpenRouter), el orquestador debe garantizar que la key esté cargada antes de spawnear. Patrón canónico para leer `.env.local`:

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
// Cross-provider opcional: el tercer juez usa Kimi (OpenRouter) si la key existe.
// Si no está o es placeholder → NO hay STOP: se cae a modo mono-proveedor (sub-agente Claude adversarial).
const crossProviderKey = 'OPENROUTER_API_KEY';
const isPlaceholder = (v) => !v || v.includes('PEGA_TU_KEY') || v.trim() === '';
if (isPlaceholder(process.env[crossProviderKey])) {
  console.warn(`${crossProviderKey} no disponible · corriendo en modo mono-proveedor (tercer sub-agente Claude adversarial)`);
}
```

**Regla anti-falso-negativo (solo cross-provider):** antes de aceptar un 401/403 como "key inválida" y degradar, el orquestador debe leer `.env.local` directamente y confirmar que el valor NO está en placeholder y NO está vacío. Si la key es válida en el archivo pero el sub-agente reporta 401 → es problema de carga de env, no de key. Documentar en el receipt con la distinción.

**Paso 2 — Spawn del tercer sub-agente (ventana limpia)**

Modo DEFAULT (mono-proveedor):

```python
result = await Task(
    description="Adversarial Verifier · refuta la evaluación de S8",
    prompt=adversarial_package,
    # Tercer sub-agente Claude en ventana limpia distinta a la de S6 y S8.
)
```

Modo OPCIONAL (cross-provider, solo si hay `OPENROUTER_API_KEY`):

```python
result = await Task(
    description="Adversarial Verifier · refuta la evaluación de S8",
    prompt=adversarial_package,
    model="kimi-k2",  # tercer proveedor distinto · Moonshot vía OpenRouter
)
```

**Paso 3 — El tercer juez genera su veredicto adversarial**

Debe responder con estructura:

```
CONCORDANCIAS CON EL EVALUADOR (ítems donde PASS es correcto):
  - {item}: CONFIRMO PASS · evidencia: {razón específica}

DISCORDANCIAS (ítems donde el evaluador pudo haberse equivocado):
  - {item}: CUESTIONO PASS · razón: {argumento específico}
  - Severidad: {CRÍTICA | MODERADA | LEVE}

ÍTEMS ADICIONALES NO EVALUADOS POR S8:
  - {si encontró algo que el evaluador no chequeó}

VEREDICTO ADVERSARIAL:
  {CONFIRMA_AGENTE_LISTO | DISCREPA_REVISIÓN_REQUERIDA}
```

**Paso 4 — Analizar discordancias**

```
Para cada discordancia del tercer juez:

  Si severidad = CRÍTICA:
    → Verificar PRIMERO que la premisa es real (premisas falsas son verificables)
    → Si la premisa es real → Flag obligatorio para Plan Mode · no avanzar a S10 sin que el usuario decida
    → Si la premisa es falsa (ej. afirma >80 líneas y son 54) → registrar como FALSO POSITIVO · avanzar

  Si severidad = MODERADA:
    → Documentar en el receipt como "ADVERTENCIA" · avanzar a S10 con nota

  Si severidad = LEVE:
    → Documentar en el receipt como "OBSERVACIÓN" · avanzar a S10

Si 0 discordancias críticas con premisa real:
    → "DOBLE VALIDACIÓN PASS · evaluador (S8) + verificador adversarial (S9) concordaron"
```

**Paso 5 — Construir veredicto consolidado (S8 + S9)**

```
VEREDICTO FINAL PRE-GATE3:
  Evaluación (S8):                  {PASS/FAIL summary}
  Adversarial (S9):                 {CONFIRMA/DISCREPA summary}
  Discordancias críticas reales:    {N}
  Falsos positivos descartados:     {N}
  Concordancia entre evaluadores:   {N}/13 anti-patterns

  Resultado consolidado: {AGENTE_LISTO | NECESITA_REVISIÓN_GATE3}
```

**Paso 6 — Guardar checkpoint S9**

```python
await checkpoint.save_stage(9, {
    "result": {
        "adversarial_mode": "mono-proveedor | cross-provider",
        "concordances": concordance_count,
        "discordances_critical_real": critical_real_count,
        "false_positives_discarded": false_positive_count,
        "discordances_moderate": moderate_count,
        "adversarial_verdict": adversarial_verdict,
        "consolidated_verdict": final_verdict
    },
    "metadata": {"model": model_snapshot, "duration_s": elapsed},
    "summary": f"Adversarial: {adversarial_verdict} · {concordance_count}/13 concordancias · {critical_real_count} críticas reales · {false_positive_count} falsos positivos"
})
```

---

## 3 · Output

`runs/<run_id>/adversarial_verification.json`:

```json
{
  "adversarial_mode": "mono-proveedor",
  "adversarial_verdict": "CONFIRMA_AGENTE_LISTO",
  "concordances": 13,
  "discordances": [],
  "discordances_critical_real": 0,
  "false_positives_discarded": 0,
  "discordances_moderate": 0,
  "discordances_leve": 0,
  "additional_findings": [],
  "consolidated_verdict": "AGENTE_LISTO",
  "notes": "Evaluador (S8) y verificador adversarial (S9) concordaron en los 13 anti-patterns"
}
```

Si hay discordancias (ejemplo con falso positivo descartado):
```json
{
  "discordances": [
    {
      "item": "A1_kitchen_sink",
      "s8_verdict": "FAIL",
      "adversarial_verdict": "REFUTA_EL_FAIL",
      "adversarial_reason": "S8 afirmó CLAUDE.md >80 líneas pero el archivo real tiene 54. Premisa falsa verificable.",
      "severity": "FALSO_POSITIVO",
      "action": "Descartar el FAIL · el anti-pattern NO está presente"
    }
  ]
}
```

---

## 4 · Modelo

**Tercer sub-agente en ventana limpia distinta** a la que generó (S6) y a la que evaluó (S8).

- **DEFAULT (mono-proveedor):** un sub-agente **Claude en ventana limpia**, con rol adversarial explícito ("refuta, no confirmes"). El aislamiento de ventana ya rompe el sesgo de auto-juicio.
- **OPCIONAL (cross-provider):** si tienes `OPENROUTER_API_KEY`, el tercer juez puede correr con **Kimi** (Moonshot vía OpenRouter). Un panel con tres proveedores distintos (generación → evaluación → refutación) elimina también el sesgo de proveedor. [KB-E 01 §4]

Preséntalo SIEMPRE como opcional, con fallback limpio al modo mono-proveedor.

**Principio de versionado:** cuando registres el resultado, anota el **snapshot exacto** del modelo que usó el tercer juez (nunca un alias dinámico).

---

## 5 · Costo

Corre sobre tu Claude Code (plan Max/Pro o API propia); no hay cobro aparte por este stage. Si activas el modo cross-provider opcional (Kimi vía OpenRouter), aplican los precios de ese proveedor sobre los 3-5 archivos del agente — es la única parte que puede tener costo externo, y es opcional.

---

## 6 · Validación

- [ ] `adversarial_verification.json` existe con `adversarial_mode` declarado (mono-proveedor o cross-provider)
- [ ] El tercer juez revisó todos los ítems que el evaluador (S8) evaluó (no solo un subset)
- [ ] Discordancias clasificadas por severidad (CRÍTICA/MODERADA/LEVE) Y verificadas contra el archivo real (falso positivo vs real)
- [ ] Veredicto consolidado declarado
- [ ] Si discordancia CRÍTICA con premisa real: no avanzar a S10 sin GATE
- [ ] `checkpoint stage_9.json` guardado
- [ ] **Listo para S10 Versioning + Receipt**

---

## 7 · Fallback

| Falla | Acción |
|---|---|
| Cross-provider (Kimi/OpenRouter) 429 o down | Fallback al modo mono-proveedor: sub-agente Claude en ventana limpia con rol adversarial · marcar receipt `adversarial: MONO_PROVEEDOR` |
| Cross-provider sin key o key en placeholder | NO es error: corre en modo mono-proveedor · WARNING en el receipt, sin STOP |
| Tercer juez responde sin justificaciones específicas | Retry con prompt: "Sé más específico. Para cada ítem, cita el texto exacto del CLAUDE.md o agent.md que justifica tu posición" |
| Discordancia CRÍTICA con premisa REAL en anti-pattern de memoria | Volver a S5 para ajustar memory_spec + re-ejecutar S6 solo para archivos de memoria |
| Discordancia CRÍTICA con premisa REAL en Specification Drift | Volver a S1 · re-interview · spec drift es señal de discovery incompleto |
| Discordancia CRÍTICA con premisa FALSA (no verificable) | Descartar como falso positivo · documentar · avanzar |
| Evaluador (S8) y tercer juez coinciden en todo · cero críticas | Resultado válido · avanzar a S10 con nota "doble validación concordante" |

---

## 8 · Anti-patterns · Nunca hacer aquí

- ❌ Usar la misma ventana/contexto que evaluó en S8 para la "segunda opinión" — no es segunda opinión, es el mismo sesgo
- ❌ Usar la misma ventana que generó en S6 como tercer juez — el evaluador debe ser SIEMPRE una ventana limpia distinta
- ❌ Ignorar discordancias del tercer juez aunque parezcan menores — el punto del adversarial es encontrar lo que el evaluador pasó
- ❌ Aceptar una discordancia CRÍTICA sin verificar su premisa contra el archivo real (falsos positivos)
- ❌ Pedir al tercer juez que "confirme" en vez de "refute" — el prompt adversarial es obligatorio [CLAUDE.md §EVALUADOR EXTERNO]
- ❌ Avanzar a S10 con discordancia CRÍTICA real sin flag para el usuario en Plan Mode
- ❌ Hacer STOP por falta de key cross-provider — el modo mono-proveedor es el default válido, no una degradación

---

## Mensaje al usuario al terminar

```
✅ Stage 9 · Adversarial Verification OK
   Modo:                {mono-proveedor | cross-provider}
   Tercer juez:         {sub-agente Claude en ventana limpia | Kimi vía OpenRouter}
   Concordancias:       {N}/13 con el evaluador (S8)
   Discordancias:       {C} críticas reales · {F} falsos positivos descartados · {M} moderadas
   Veredicto 3er juez:  {CONFIRMA_AGENTE_LISTO | DISCREPA}
   Veredicto final:     {AGENTE_LISTO | NECESITA_REVISIÓN_GATE3}

   {si DISCREPA con severidad CRÍTICA real}
   ⚠️ Revisión requerida antes de GATE 3:
   {discordancias críticas con detalle}

   ▶ Procediendo a Stage 10 · Versioning + Receipt...
```
