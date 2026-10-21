# Stage 0 · Pre-flight [GATE INICIAL · sin LLM]

## Propósito

Verificar que el ambiente está listo antes de arrancar el pipeline. Inicializar el checkpointing (`PipelineCheckpoint`) y crear la carpeta de run + el directorio de checkpoints. Si cualquier pre-requisito obligatorio falla → **STOP** con mensaje específico de cómo arreglarlo. Este stage no llama a ningún LLM: es pura operación de filesystem + verificación de KBs.

---

## 1 · Input

| Fuente | Qué verificar |
|---|---|
| Sesión de Claude Code | Claude Code ya está autenticado con tu sesión (plan Max/Pro o tu propia API key). ALAN-4AI no administra claves. |
| `kb/INDEX.md` | Existe · lista al menos 3 KBs con `INVESTIGACION_LISTA` |
| `kb/como-construir-agentes-claude-2026/.meta.json` | `estado: INVESTIGACION_LISTA` · `fecha_creacion < 90 días` |
| `kb/agentes-con-memoria-viva-self-improving-systems-2026/.meta.json` | `estado: INVESTIGACION_LISTA` (KB-D · memoria) |
| `kb/meta-agente-clase-mundial-alan-2026/.meta.json` | `estado: INVESTIGACION_LISTA` (KB-E · ALAN) |
| MCPs | *(Opcional)* `notion` responde (S11 lo usa solo si activás el registro en Notion) |
| Claves cross-provider en `.env.local` | *(Opcional)* `OPENAI_API_KEY` (S8) · `OPENROUTER_API_KEY` (S9 · Kimi) — solo si activás modo cross-provider · no vacías · sin placeholder |
| Parámetros opcionales | `auto_approve_gates`, `budget_note`, `modo=B target=output/<nombre>` |

---

## 2 · Proceso

**Paso 1 — Verificar sesión de Claude Code**
- Asegurate de tener Claude Code con sesión iniciada (plan Max/Pro o tu propia API key). ALAN-4AI no administra claves ni env de auth.
- Si Claude Code no está autenticado → inicia sesión antes de continuar.

**Paso 2 — Verificar KBs críticos**
- Leer `kb/INDEX.md` · contar entradas con `INVESTIGACION_LISTA`
- Leer `.meta.json` de los 3 KBs requeridos (base · D · E) · validar `estado`
- Si fecha > 90 días → **WARNING** (no bloquea) · "KB tiene {N} días · considera refrescarlo investigando el tema (WebSearch / tus fuentes) y actualizando `kb/`"
- Si cualquier KB falta → **STOP** · "KB requerido ausente: {nombre} · agrégalo a `kb/` antes de construir"

**Paso 3 — Verificar el modo de evaluación (mono / cross-provider)**
- DEFAULT: **modo mono-proveedor** → S8 y S9 corren como sub-agentes Claude en ventanas limpias distintas (evaluador ≠ generador). No requiere ninguna clave.
- *(Opcional)* modo cross-provider → leer `.env.local` y validar: `OPENAI_API_KEY` (S8 · GPT-4o-mini) y `OPENROUTER_API_KEY` (S9 · Kimi) presentes · no vacías · sin placeholder `PEGA_TU_KEY`
- Si alguna clave cross-provider falta/tiene placeholder → **WARNING** (NUNCA STOP) · "corriendo en modo mono-proveedor · S8/S9 usarán sub-agentes Claude en ventana limpia"
- *(Opcional)* Ping `notion` MCP · si no responde → **WARNING** · S11 marcará el registro en Notion como `SKIPPED` (la publicación local sigue funcionando)

**Paso 3.5 — Solo MODO B: backup obligatorio del agente objetivo**
- Copiar `output/<nombre>/` completo (excepto `runs/`) a `output/<nombre>/_backup_v<version_actual>/`
- Verificar que el backup existe y tiene los mismos archivos clave (CLAUDE.md · agent.md · stages/)
- Sin backup verificado → **STOP** · "Modo B requiere backup antes de tocar el agente" [agent.md §MODO B]

**Paso 4 — Generar run_id y crear estructura**
- Formato: `alan_<YYYY-MM-DD-HHmm>` · ej. `alan_2026-05-30-1430`
- Crear en la carpeta de ALAN-4AI. Windows/PowerShell (una sola línea cada comando):
  ```powershell
  New-Item -ItemType Directory -Path "runs\$runId\checkpoints" -Force
  ```
  ```powershell
  New-Item -ItemType File -Path "runs\$runId\error_log.md" -Force
  ```
  Equivalente mac/linux:
  ```bash
  mkdir -p "runs/$runId/checkpoints" && touch "runs/$runId/error_log.md"
  ```

**Paso 5 — Inicializar PipelineCheckpoint** [KB-E 03 Estrategia 1]
- `new PipelineCheckpoint(runId, 'runs/')` (filesystem-backed)
- TTL de checkpoints: 7 días (`ttl_seconds=86400*7`)
- Helper opcional (solo stdlib de Python) en `templates/pipeline_checkpoint.py.tpl`

**Paso 6 — Guardar checkpoint S0**
```python
await checkpoint.save_stage(0, {
    "result": preflight_result,
    "metadata": {"model": "none", "duration_s": elapsed},
    "summary": "Preflight OK · run_id={runId} · KBs={N} · modo={mono|cross}"
})
```

---

## 3 · Output

`runs/<run_id>/preflight.json`:

```json
{
  "run_id": "alan_2026-05-30-1430",
  "kbs": {
    "base": {"status": "INVESTIGACION_LISTA", "age_days": 12},
    "D_memoria": {"status": "INVESTIGACION_LISTA", "age_days": 1},
    "E_alan": {"status": "INVESTIGACION_LISTA", "age_days": 1}
  },
  "eval_mode": "mono",
  "eval_keys": {
    "openai_s8": "absent",
    "openrouter_s9": "absent"
  },
  "mcps": {
    "notion": "skipped"
  },
  "mode": "A",
  "backup_target": null,
  "auto_approve_gates": false,
  "checkpoints_dir": "runs/alan_2026-05-30-1430/checkpoints/",
  "warnings": ["cross-provider no configurado · modo mono-proveedor"],
  "ready_to_proceed": true,
  "created_at": "2026-05-30T14:30:00Z"
}
```

`runs/<run_id>/checkpoints/stage_0.json` (comprimido)

---

## 4 · Modelo

**Ninguno.** Operación pura de filesystem + verificación de KBs (y ping opcional de MCP).

---

## 5 · Nota de ejecución

Corre sobre tu Claude Code (plan Max/Pro o API propia); no hay cobro aparte. Este stage no llama a ningún LLM.

---

## 6 · Validación

- [ ] `preflight.json` existe con `ready_to_proceed: true`
- [ ] Los 3 KBs requeridos tienen `INVESTIGACION_LISTA`
- [ ] Modo de evaluación detectado (`mono` por defecto · `cross` si hay claves válidas)
- [ ] `checkpoints/` directorio existe y es writable
- [ ] `checkpoint stage_0.json` serializado
- [ ] `error_log.md` creado (vacío si sin errores)

---

## 7 · Fallback

| Falla | Acción |
|---|---|
| Claude Code sin sesión iniciada | **STOP** · "Asegúrate de tener Claude Code con sesión iniciada (plan Max/Pro o API propia)" |
| KB base ausente o corrupto | **STOP** · "KB base requerido · agrégalo a `kb/como-construir-agentes-claude-2026/`" |
| KB-D o KB-E ausentes | **STOP** · "Faltan KBs {D/E} · agrégalos a `kb/` (o investiga el tema y crea las notas)" |
| `kb/INDEX.md` ausente | Crear skeleton con entries de los 3 KBs detectados · **WARNING** · continuar |
| `OPENAI_API_KEY` ausente/placeholder | **WARNING** · S8 corre como sub-agente Claude en ventana limpia (modo mono-proveedor) |
| `OPENROUTER_API_KEY` ausente/placeholder | **WARNING** · S9 corre como tercer sub-agente Claude en ventana limpia (modo mono-proveedor) |
| Notion MCP no responde | **WARNING** · S11 marcará el registro en Notion como `SKIPPED` · la publicación local en `output/` sigue funcionando |
| MODO B sin backup verificable | **STOP** · "Backup obligatorio antes de tocar el agente objetivo" |
| Directorio `runs/` no writable | **STOP** · "Verifica permisos de escritura sobre `runs/` (Windows: `icacls runs`)" |

---

## 8 · Anti-patterns · Nunca hacer aquí

- ❌ Avanzar a S1 sin `preflight.json` persistido y `ready_to_proceed: true`
- ❌ Hacer STOP por falta de claves cross-provider → como mucho es un WARNING; el modo mono-proveedor es válido
- ❌ No inicializar `PipelineCheckpoint` → si el run cae, no hay recovery [KB-E 03 Estrategia 1]
- ❌ No crear `error_log.md` → fallos futuros quedan sin trazabilidad [agent.md si-falla]
- ❌ `run_id` sin timestamp → colisión con runs previos del mismo día
- ❌ Silenciar WARNING de KB >90 días → alimenta Specification Drift [KB-E 08 Anti-Pattern 2]
- ❌ Asumir MCPs disponibles sin verificar → S11 fallaría silenciosamente

---

## Mensaje al usuario al terminar

```
✅ Stage 0 · Pre-flight OK
   Sesión Claude Code: ACTIVA
   KB base:         LISTA (12 días · fresco)
   KB-D memoria:    LISTA (1 día)
   KB-E ALAN:       LISTA (1 día)
   Modo evaluación: MONO-PROVEEDOR (ventanas limpias)  {o CROSS-PROVIDER si hay claves}
   Notion MCP:      SKIPPED (opcional)
   Modo:            {A construcción | B upgrade · backup ✓}
   Run ID:          alan_2026-05-30-1430
   Checkpoints dir: runs/alan_2026-05-30-1430/checkpoints/

   ▶ Procediendo a Stage 1 · Elicitation...
```
