# Stage 10 · Versioning + Receipt

## Propósito

Generar el **Version ID híbrido SemVer** del agente generado y el **receipt completo** del run. El version ID incluye prompt hash + model snapshot fechado — nunca alias dinámicos. El receipt es la evidencia de que el agente fue construido correctamente y qué evaluadores lo validaron. Este stage es el input directo de GATE 3 y S11.

---

## 1 · Input

| Fuente | Contenido |
|---|---|
| `output/{nombre}/agent.md` | Contenido del agente (para generar prompt hash) |
| `output/{nombre}/CLAUDE.md` | Versión y constitución |
| `runs/<run_id>/checkpoints/` | Todos los stage checkpoints (modelos + duración) |
| `runs/<run_id>/external_evaluation.json` | Veredicto S8 |
| `runs/<run_id>/adversarial_verification.json` | Veredicto S9 |
| `runs/<run_id>/elicitation_spec.md` | Tier · nombre · fecha |
| KB-E `03_pipeline-robustness-lifecycle.md` | Formato SemVer híbrido [E 03 A3] |

---

## 2 · Proceso

**Paso 1 — Calcular Version ID** [E 03 A3]

Formato obligatorio:
```
v{MAJOR}.{MINOR}.{PATCH}+{prompt_hash}+{model_snapshot}

MAJOR: 1 (primera versión) · incrementar si breaking change en behavior/output schema
MINOR: 0 (sin features adicionales post-spec)
PATCH: 0 (sin bug fixes post-generación)

prompt_hash: primeros 7 caracteres del hash SHA-256 de agent.md + CLAUDE.md concatenados
  PowerShell: $hash = (Get-FileHash "output/{nombre}/agent.md" -Algorithm SHA256).Hash.Substring(0,7).ToLower()

model_snapshot: el snapshot EXACTO y fechado del modelo que usaste (ej. claude-sonnet-...-{YYYYMMDD})
  NUNCA: un alias dinámico como "claude-sonnet-latest" (causa #1 regresión silenciosa) [E 03 A3 F17]
  SIEMPRE: el snapshot fechado del día del run

Ejemplo: v1.0.0+a4f2b91+<snapshot-que-usaste>
```

**Paso 2 — Registrar los modelos usados por stage**

Leer todos los checkpoints en `runs/<run_id>/checkpoints/stage_*.json` y anotar qué modelo corrió cada stage:

```powershell
$stages = Get-ChildItem "runs\{run_id}\checkpoints" -Filter "stage_*.json" | Sort-Object Name
foreach ($s in $stages) {
    $data = Get-Content $s | ConvertFrom-Json
    "$($s.Name) -> $($data.metadata.model)"
}
```

Tabla de breakout (modelo por stage · sin cobros; ALAN-4AI corre sobre tu Claude Code, plan Max/Pro o API propia, y no hay cobro aparte):

| Stage | Modelo usado |
|---|---|
| S0 pre-flight | none |
| S1 elicitation | modelo de razonamiento fuerte (ej. Claude Opus) |
| S2 kb_coverage | modelo rápido y capaz (ej. Claude Sonnet) |
| S3 complexity | modelo de razonamiento fuerte (ej. Claude Opus) |
| S4 pipeline | modelo rápido y capaz (ej. Claude Sonnet) |
| S5 memory | modelo rápido y capaz (ej. Claude Sonnet) |
| S6 code_gen | modelo rápido y capaz (ej. Claude Sonnet) |
| S7 smoke_test | modelo rápido y capaz (ej. Claude Sonnet) |
| S8 evaluation | sub-agente en ventana limpia distinta (o GPT-4o-mini si activaste cross-provider) |
| S9 adversarial | tercer sub-agente en ventana limpia (o Kimi si activaste cross-provider) |
| S10 versioning | modelo rápido y capaz (ej. Claude Sonnet) |

**Paso 3 — Calcular tiempo wall-clock total**

```python
duration_total = sum(checkpoint["metadata"]["duration_s"] for checkpoint in all_checkpoints)
# Formato: "X min Y seg"
```

**Paso 4 — Ensamblar receipt completo**

El receipt local incluye:
- Version ID completo
- Modo (A · construcción | B · upgrade)
- Tier + patrón arquitectural
- Resumen de evaluación (13 anti-patterns + 5 tests + adversarial)
- Modelos usados por stage
- Tiempo wall-clock
- Archivos generados
- Checkpoints
- Ruta local del agente (`output/{nombre}/`) y de `output/REGISTRY.md` (se registran en S11)

**Paso 5 — Escribir archivos de versión**

```typescript
// output/{nombre}/package.json (o version.json si no es npm)
{
  "name": "{nombre}",
  "version": "1.0.0",
  "description": "{propósito del agente}",
  "alan_version_id": "v1.0.0+a4f2b91+<snapshot-que-usaste>",
  "tier": "{CORE | Ops | Comercial}",
  "built_by": "ALAN-4AI",
  "built_at": "{ISO8601}",
  "model_snapshot": "<snapshot-que-usaste>"
}
```

**Paso 6 — Guardar checkpoint S10**

```python
await checkpoint.save_stage(10, {
    "result": {
        "version_id": version_id,
        "duration_total_s": duration_total,
        "receipt_path": f"runs/{run_id}/receipt.md"
    },
    "metadata": {"model": "<snapshot-que-usaste>", "duration_s": elapsed},
    "summary": f"Version {version_id} · {duration_total//60} min"
})
```

---

## 3 · Output

`runs/<run_id>/receipt.md` — receipt completo pre-GATE3:

```markdown
# Receipt · {nombre-agente}
Run ID: {run_id}
Fecha: {ISO8601}
Built by: ALAN-4AI

## Agente
- Nombre: {nombre}
- Version ID: v1.0.0+{prompt_hash}+<snapshot-que-usaste>
- Modo: {A · construcción | B · upgrade}
- Tier: {CORE | Ops | Comercial}
- Patrón: {patrón arquitectural}
- Archivos: {N} archivos en output/{nombre}/

## Evaluación
- Sub-agente Evaluador (ventana limpia distinta · o GPT-4o-mini si activaste cross-provider): {AGENTE_LISTO | NECESITA_ITERACION}
  - Anti-patterns Anthropic: {5}/5
  - Anti-patterns Meta-agente: {4}/4
  - Anti-patterns Memoria: {4}/4
  - Tests: {5}/5
- Sub-agente Adversarial (tercer sub-agente · o Kimi si activaste cross-provider): {CONFIRMA | DISCREPA}
  - Concordancias: {N}/13
  - Discordancias críticas: {C}

## Modelos usados por stage
| Stage | Modelo usado |
...

## Tiempo
{N} min {S} seg (wall-clock completo)

## Registro (se completa en S11)
- Carpeta local del agente: output/{nombre}/
- RECEIPT.md: PENDING
- REGISTRY.md: PENDING
- (Opcional) Notion, si tienes ese MCP conectado: PENDING
```

`output/{nombre}/version.json` — version ID persistido junto al agente.

---

## 4 · Modelo

**Modelo rápido y capaz (ej. Claude Sonnet)** · agregación de checkpoints y cálculo de hashes.

Justificación: S10 es mayormente formateo de receipt y cálculo de hashes. No requiere el razonamiento de un modelo Opus; basta un modelo rápido y capaz con los checkpoints ya en contexto. [SPEC.md §4]

Lánzalo como sub-agente con la herramienta Task (ventana limpia), pasándole el contenido de los checkpoints + resultados de evaluación.

---

## 5 · Costo estimado

Corre sobre tu Claude Code (plan Max/Pro o API propia); no hay cobro aparte. Es una llamada ligera con los checkpoints ya en contexto.

---

## 6 · Validación

- [ ] `version_id` tiene formato `v{M}.{N}.{P}+{hash7}+<snapshot-fechado>`
- [ ] Prompt hash calculado desde archivo real (no inventado)
- [ ] Model snapshot incluye fecha (NUNCA alias dinámico) [E 03 A3]
- [ ] Modelos usados por stage registrados desde los checkpoints reales
- [ ] `receipt.md` existe con todos los campos
- [ ] `output/{nombre}/version.json` existe
- [ ] `checkpoint stage_10.json` guardado
- [ ] **Listo para GATE 3**

---

## 7 · Fallback

| Falla | Acción |
|---|---|
| `git hash` no disponible (no es repo git) | Usar SHA-256 de los archivos del agente · documentar como `file_hash` en lugar de `git_hash` |
| Checkpoints de stages anteriores corruptos | Leer directamente los archivos generados para reconstruir qué modelo corrió · marcar `models: APPROXIMATE` |
| Fecha del modelo no conocida exactamente | Usar fecha del run como aproximación · marcar `model_snapshot: APPROXIMATE` |
| Receipt parcial (algún stage sin checkpoint) | Generar receipt marcando stages faltantes como `model: UNKNOWN` · no bloquear GATE 3 |

---

## 8 · Anti-patterns · Nunca hacer aquí

- ❌ Version ID sin model snapshot fechado → silent model upgrade inevitable [E 03 A3 F17]
- ❌ Version ID con alias dinámico (snapshot sin fecha) → mismo problema [E 03 A3]
- ❌ Receipt sin breakout de modelos por stage → no hay trazabilidad de qué corrió cada stage
- ❌ Receipt sin resultado de evaluación externa → no hay evidencia de calidad

---

## GATE 3 · ARTEFACTO FINAL (post-S10 · Plan Mode)

Presentar al usuario para aprobación final:

```
🛑 GATE 3 · ARTEFACTO FINAL

Agente generado:     {nombre}
Version ID:          v1.0.0+{hash}+{model_snapshot}
Tier:                {CORE | Ops | Comercial}

Archivos:            {N} archivos en output/{nombre}/
CLAUDE.md:           {K} líneas (<80 ✓)
agent.md:            {L} líneas (<300 ✓)

13 Anti-Patterns:
  Anthropic (5/5):   ✅ / ❌
  Meta-agente (4/4): ✅ / ❌
  Memoria (4/4):     ✅ / ❌

Evaluación externa:
  Evaluador:         {AGENTE_LISTO | NECESITA_ITERACION}
  Adversarial:       {CONFIRMA | DISCREPA} ({N} discordancias críticas)

Tiempo wall-clock:   {N} min

Opciones:
  ✅ Aprobar · proceder a S11 (publicación)
  ✏️  Iterar · volver a stage específico
  ❌ Descartar run
```

Si `auto_approve_gates=true` → GATE se salta automáticamente · registrar en receipt.

---

## Mensaje al usuario al terminar

```
✅ Stage 10 · Versioning + Receipt OK
   Version ID:          v1.0.0+{hash}+<snapshot-que-usaste>
   Tiempo wall-clock:   {N} min {S} seg

   ⏸ GATE 3 en espera · revisa el artefacto final arriba...
```
