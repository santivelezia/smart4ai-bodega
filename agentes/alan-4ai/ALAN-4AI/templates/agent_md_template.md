# {NOMBRE} · Prompt Principal

> **{NOMBRE_COMPLETO}** · {TIER} · {POSICION_EN_SISTEMA}
> {PROPOSITO_EN_1_ORACION}

## Invocación

```
Lee output/{NOMBRE_KEBAB}/agent.md y ejecútalo
```

Parámetros opcionales: {LISTA_PARAMETROS_CON_DEFAULTS}.

Sin parámetros, ejecuta interactivo con los 3 Plan Mode gates activos.

---

## Filosofía (no-negociable)

> *"{FRASE_GUIA}"*

**Antes de ejecutar cualquier stage, lee `output/{NOMBRE_KEBAB}/CLAUDE.md`** e interioriza:
- Los 13 anti-patterns
- Evaluador EXTERNO obligatorio (sub-agente en ventana limpia distinta a la que generó)
- Stage Isolation (cada stage delegado a un sub-agente con ventana limpia vía herramienta Task)
- 3 GATES Plan Mode hard gates

---

## Contexto de ejecución

- CLI: **Claude Code** (Windows/PowerShell, macOS o Linux)
- **Working dir:** la carpeta del agente (donde vive este `agent.md`). Abre Claude Code aquí.
- **Sub-agentes vía herramienta Task** (Claude Code nativo) · NO hay router externo ni gestión de claves.
  Claude Code ya está autenticado con tu sesión (plan Max/Pro o API key propia).
- **Checkpointing obligatorio:** después de cada stage → `runs/<run_id>/checkpoints/stage_<N>.json`

**Pre-requisitos verificados antes de S0:**
{LISTA_PREREQS_NUMERADA}

Si falta cualquiera → STOP con mensaje específico de cómo arreglar.

---

## Pipeline · {N_STAGES} stages + 3 GATES Plan Mode

```
{PIPELINE_ASCII_CON_STAGES_Y_GATES}
```

---

## Stage por stage (resumen · detalle en `stages/`)

{BLOQUES_STAGE_POR_STAGE}

### 🛑 GATE 1 · Plan Mode ({GATE1_TIPO})
{DESCRIPCION_GATE1}

### 🛑 GATE 2 · Plan Mode ({GATE2_TIPO})
{DESCRIPCION_GATE2}

### 🛑 GATE 3 · Plan Mode (ARTEFACTO FINAL pre-publicación)
{DESCRIPCION_GATE3}

---

## Checkpointing (obligatorio)

Después de cada stage, escribe un JSON de checkpoint en `runs/<run_id>/checkpoints/stage_<N>.json`
(pseudocódigo ilustrativo; helper opcional en `templates/pipeline_checkpoint.py.tpl`):
```python
await checkpoint.save_stage(N, {
    "result": stage_result,
    "metadata": {"model": model_used, "duration_s": duration},
    "summary": compressed_summary
})
```

Si run cae → `checkpoint.load_last_valid()` → reanuda desde stage N+1.

---

## Reporte final al terminar

```
✅ {OUTPUT_PRINCIPAL} generado · "<nombre>" · v{VERSION}+{HASH}+{MODEL_SNAPSHOT}
─────────────────────────────────────────────────────────────────
{CAMPOS_REPORTE_ESPECIFICOS_DEL_AGENTE}

Tiempo:          {min} min
Checkpoints:     {N} en runs/<run_id>/checkpoints/
─────────────────────────────────────────────────────────────────
Estado: {AGENTE_LISTO | NECESITA_ITERACION}
Próximo paso: {ACCION_SIGUIENTE}
```

> Corre sobre tu Claude Code (plan Max/Pro o API propia); no hay cobro aparte.

---

## Si algo falla

{TABLA_FALLBACKS_ESPECIFICOS}

Nunca silenciar errores · siempre dejar `error_log.md` en `runs/<run_id>/`.

---

*{VERSION_ID} · contrato en `SPEC.md` si aplica · derivado del meta-agente ALAN de Smart4AI*
