# Stage 11 · Publication · local-first (output/ + RECEIPT.md + REGISTRY.md)

## Propósito

Publicar el agente generado de forma **local-first** en la carpeta de ALAN-4AI: dejar el agente completo en `output/<nombre>/`, escribir su `output/<nombre>/RECEIPT.md`, y registrar/actualizar su fila en `output/REGISTRY.md`. Este stage convierte el artefacto en un activo registrado y recuperable dentro del propio proyecto. Sin publicación, el agente existe solo como archivos sueltos sin receipt ni entrada en el registro. El receipt final se cierra aquí.

*(Opcional)* si tienes el MCP de Notion conectado, puedes registrar el agente también ahí — es un extra, no un requisito.

Este es el último stage del pipeline. Al terminar, ALAN-4AI reporta el resumen completo del run.

---

## 1 · Input

| Fuente | Contenido |
|---|---|
| `runs/<run_id>/receipt.md` | Receipt completo pre-publicación (generado en S10) |
| `output/{nombre}/` | Todos los archivos del agente generado |
| `output/{nombre}/version.json` | Version ID completo |
| `runs/<run_id>/external_evaluation.json` | Veredicto S8 |
| `runs/<run_id>/adversarial_verification.json` | Veredicto S9 |
| `output/REGISTRY.md` | Registro local de agentes generados (a actualizar) |

---

## 2 · Proceso

### Sub-tarea A · Consolidar el agente en `output/<nombre>/` + RECEIPT.md

> **MODO B:** el agente ya existe en `output/<nombre>/` y su fila ya está en `output/REGISTRY.md`. En este stage se **ACTUALIZA** (no se duplica): el `RECEIPT.md` se reescribe con la nueva versión y se añade una línea al "Historial de versiones". La fila del REGISTRY se actualiza en su lugar.

**A1 — Verificar que el agente está completo en `output/<nombre>/`**

Todos los archivos generados en S6 (y ajustados hasta S10) deben estar ya en `output/<nombre>/` con la estructura canónica (CLAUDE.md · agent.md · README.md · stages/ · templates/ · tests/ · runs/). Si falta algún archivo core → STOP y regenera antes de publicar.

```powershell
# PowerShell: listar lo que hay en output/<nombre>/
Get-ChildItem "output\{nombre}" -Recurse | Select-Object FullName
```
```bash
# mac/linux equivalente:
find "output/{nombre}" -type f
```

**A2 — Escribir `output/<nombre>/RECEIPT.md`**

El receipt local reúne las 8 secciones de registro del agente. NO lleva costos en dólares: lleva modo, tier, patrón, version id, modelos usados por stage, veredictos S8/S9, archivos generados y checkpoints.

```markdown
# RECEIPT · {nombre}

## 1. Identidad
{nombre} · {tier} · {patrón} · built by ALAN-4AI · {fecha}

## 2. Propósito
{R-G del R-G-C-C-O-V}

## 3. Invocación
Lee output/{nombre}/agent.md y ejecútalo
[Parámetros opcionales si aplica]

## 4. Evaluación
- Evaluador externo (S8): {veredicto} · {N}/13 anti-patterns · {M}/5 tests
  (modo mono-proveedor con ventana limpia · o GPT-4o-mini si activaste cross-provider)
- Adversarial (S9): {veredicto} · {discordancias} críticas
  (tercer sub-agente en ventana limpia · o Kimi si activaste cross-provider)
- Version ID: v1.0.0+{hash}+{model_snapshot}

## 5. Modo · tier
- Modo: {A · construcción | B · upgrade}
- Tier: {CORE | Ops | Comercial}
- Corre sobre tu Claude Code (plan Max/Pro o API propia); no hay cobro aparte.

## 6. Memoria inyectada
- Working Memory: ✅
- Episodic Memory: {✅|❌}
- Semantic Memory: {✅|❌}
- Procedural Memory: {✅|❌}
- Identity Memory: {✅|❌}

## 7. Stack
{KBs base de kb/ + modelos usados por stage (snapshot exacto) + herramientas/MCPs requeridos}

## 8. Historial de versiones
- v1.0.0 · {fecha} · versión inicial generada por ALAN-4AI
```

En **Modo B**, no reescribas desde cero: conserva las secciones que no cambiaron y **appendea** la nueva versión al bloque "8. Historial de versiones".

---

### Sub-tarea B · Registrar/actualizar la fila en `output/REGISTRY.md`

`output/REGISTRY.md` es el índice local de todos los agentes que ha generado ALAN-4AI. Es la fuente de verdad para saber qué existe sin abrir cada carpeta.

**B1 — Si `output/REGISTRY.md` no existe, créalo con encabezado de tabla**

```markdown
# REGISTRY · Agentes generados por ALAN-4AI

| Agente | Tier | Patrón | Version ID | Fecha | Receipt |
|---|---|---|---|---|---|
```

**B2 — Añadir (Modo A) o actualizar (Modo B) la fila del agente**

```markdown
| {nombre} | {tier} | {patrón} | v1.0.0+{hash}+{model_snapshot} | {fecha} | output/{nombre}/RECEIPT.md |
```

- **Modo A:** añade una fila nueva al final de la tabla.
- **Modo B:** localiza la fila existente por `{nombre}` y **reemplázala** (nueva version id + fecha). NUNCA dupliques la fila.

Si el REGISTRY supera un tamaño incómodo de leer (muchas filas), **WARNING** informativo y continúa — no es bloqueante.

---

### Sub-tarea C · (Opcional) Registro en Notion

Solo si tienes el **MCP de Notion** conectado y quieres un registro adicional fuera del filesystem. Es un extra: nada del pipeline depende de esto.

- Crea (Modo A) o actualiza (Modo B) una página del agente con las mismas 8 secciones del `RECEIPT.md`.
- Si el MCP de Notion no está conectado o falla → **no es error**: marca `notion: SKIPPED` en el receipt y continúa. La publicación local ya es completa y auditable por sí sola.

---

### Sub-tarea D · Lecciones del run + Receipt final + Reporte

**D1 — Registrar lecciones del run**

Si el run descubrió algo nuevo (fallo inesperado · fix reutilizable · patrón que funcionó), appendea una entrada a `docs/LECCIONES.md` con formato: fecha · run · lección · dónde quedó aplicada. Si no hubo lecciones nuevas → no escribir nada (no inflar el archivo).

**D2 — Cerrar el receipt final en `runs/<run_id>/receipt_final.md`**

Copia consolidada del `RECEIPT.md` + los paths locales publicados:

```markdown
## Paths publicados
- Agente: output/{nombre}/
- Receipt: output/{nombre}/RECEIPT.md
- Registro: output/REGISTRY.md (fila {añadida | actualizada})
- Notion: {URL | SKIPPED}
```

**D3 — Guardar checkpoint S11 (final)**

```python
await checkpoint.save_stage(11, {
    "result": {
        "agent_dir": f"output/{nombre}/",
        "receipt_path": f"output/{nombre}/RECEIPT.md",
        "registry_path": "output/REGISTRY.md",
        "receipt_final": f"runs/{run_id}/receipt_final.md",
        "notion": notion_url_or_skipped,
        "status": "AGENTE_LISTO"
    },
    "metadata": {"model": model_snapshot, "duration_s": elapsed},
    "summary": f"Publicado local · output/{nombre}/ ✓ · RECEIPT ✓ · REGISTRY {'actualizado' if modo_b else 'añadido'}"
})
```

---

## 3 · Output

Publicación local completa:
1. Agente completo en `output/<nombre>/`
2. `output/<nombre>/RECEIPT.md` (8 secciones, sin dólares)
3. Fila del agente en `output/REGISTRY.md` (añadida en Modo A · actualizada en Modo B)
4. *(Opcional)* página en Notion si tienes ese MCP conectado

`runs/<run_id>/receipt_final.md` — receipt cerrado con todos los paths.

### Reporte final ALAN-4AI al terminar S11

```
✅ Agente generado · "{nombre}" · v1.0.0+{hash}+{model_snapshot}
─────────────────────────────────────────────────────────────────
Modo:                {A · construcción | B · upgrade}
Tipo:                {single-agent | multi-agent · N agentes}
Tier:                {CORE | Ops | Comercial}
Stages ejecutados:   12
Discovery R-G-C-C-O-V: ✅ 6/6
Spec-by-example:     ✅ 3 positivos · 2 negativos
KB cobertura:        {score}
Patrón arquitectural: {patrón}

Archivos generados:  {N} archivos en output/{nombre}/
CLAUDE.md:           {K} líneas (<80 ✓)
agent.md:            {L} líneas (<300 ✓)
Memoria inyectada:   {5/4/3}/5 sistemas

13 Anti-Patterns:
  Anthropic (5/5):   ✅
  Meta-agente (4/4): ✅
  Memoria (4/4):     ✅

Evaluación externa:
  Evaluador (S8):    {veredicto}
  Adversarial (S9):  {CONFIRMA | REFUTA} · {N} concordancias

Version ID:          v1.0.0+{hash}+{model_snapshot}
Agente:              output/{nombre}/
Receipt:             output/{nombre}/RECEIPT.md
Registro:            output/REGISTRY.md ✓
Notion:              {URL | SKIPPED}

Tiempo wall-clock:   {min} min
Checkpoints:         12 en runs/{run_id}/checkpoints/
─────────────────────────────────────────────────────────────────
Estado: AGENTE_LISTO
Próximo paso: ejecutar smoke test · Lee output/{nombre}/tests/smoke_test_plan.md
```

---

## 4 · Modelo

**Modelo rápido y capaz** (ej. Claude Sonnet, el snapshot que tengas configurado) · escritura de documentos (RECEIPT.md · REGISTRY.md · receipt_final.md) y actualización del registro local.

Justificación: S11 es escritura de plantillas y actualización de archivos locales · no requiere razonamiento crítico. [SPEC.md §4]

Lánzalo como sub-agente con la herramienta **Task** (ventana limpia) si quieres aislarlo, o ejecútalo en el orchestrator: es escritura simple sin decisiones arquitecturales.

**Principio de versionado:** anota en el receipt el **snapshot exacto** del modelo que usaste por stage (ej. `claude-sonnet-...-<fecha>`), nunca un alias dinámico.

---

## 5 · Nota de ejecución

Corre sobre tu Claude Code (plan Max/Pro o API propia); no hay cobro aparte. La publicación es 100% local (escritura de archivos): no depende de servicios externos. Notion es un extra opcional que solo se activa si tienes ese MCP conectado.

---

## 6 · Validación

- [ ] Agente completo presente en `output/{nombre}/` (estructura canónica)
- [ ] `output/{nombre}/RECEIPT.md` creado con las 8 secciones (sin dólares)
- [ ] Version ID registrado en el receipt
- [ ] `output/REGISTRY.md` con la fila del agente (añadida en Modo A · actualizada en Modo B, sin duplicar)
- [ ] `runs/{run_id}/receipt_final.md` completo con todos los paths
- [ ] Lecciones registradas en `docs/LECCIONES.md` (solo si hubo algo nuevo)
- [ ] Reporte final ALAN-4AI impreso al usuario
- [ ] `checkpoint stage_11.json` guardado (checkpoint final)

---

## 7 · Fallback

| Falla | Acción |
|---|---|
| Falta un archivo core en `output/{nombre}/` | STOP · regenerar el archivo faltante (S6) antes de publicar |
| `output/REGISTRY.md` no existe | Crearlo con el encabezado de tabla y añadir la fila |
| REGISTRY con muchas filas (difícil de leer) | **WARNING** · "REGISTRY grande · considera archivar filas antiguas" · añadir igual |
| Receipt anterior corrupto (Modo B) | Reconstruir desde checkpoints · marcar `receipt: RECONSTRUCTED` |
| MCP de Notion no conectado o falla | Marcar `notion: SKIPPED` · la publicación local ya es completa · no bloquea |

---

## 8 · Anti-patterns · Nunca hacer aquí

- ❌ Marcar `AGENTE_LISTO` antes de escribir el RECEIPT.md y actualizar el REGISTRY — no hay publicación sin registro local
- ❌ Duplicar la fila en REGISTRY en Modo B — se actualiza la existente, nunca se crea otra
- ❌ Receipt sin version id ni paths — el receipt sin trazabilidad no es auditable
- ❌ RECEIPT.md con costos en dólares — ALAN-4AI corre sobre tu propio Claude Code, no hay cobro por stage
- ❌ Tratar Notion como obligatorio — es un extra opcional; la fuente de verdad es `output/`

---

## Mensaje al usuario al terminar

```
✅ Stage 11 · Publication OK · PIPELINE COMPLETO

   Agente:              output/{nombre}/ ✓
   Receipt:             output/{nombre}/RECEIPT.md ✓
   Registro:            output/REGISTRY.md ✓ ({añadido | actualizado})
   Notion:              {URL | SKIPPED}

   ════════════════════════════════════════════════
   AGENTE LISTO: {nombre} · v1.0.0+{hash}+{model}
   ════════════════════════════════════════════════

   Próximo paso:
   Lee output/{nombre}/tests/smoke_test_plan.md y ejecuta el smoke test.
```
