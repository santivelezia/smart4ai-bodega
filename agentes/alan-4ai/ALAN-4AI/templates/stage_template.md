# Stage {N} · {NOMBRE_STAGE} {ESTRELLA_SI_CAMBIA_SUSTANCIALMENTE} · {MODELO}

## Propósito

{DESCRIPCION_1_PARRAFO · qué hace · por qué importa · fuente de evidencia si aplica}

---

## 1 · Input

| Fuente | Contenido |
|---|---|
| `runs/<run_id>/{OUTPUT_STAGE_ANTERIOR}` | {descripción} |
| `{ARCHIVO_KB_O_CONFIG}` | {descripción} |

---

## 2 · Proceso

**Paso 1 — {NOMBRE_PASO}**
{descripción del paso · qué hace · cómo · herramienta usada}

**Paso 2 — {NOMBRE_PASO}**
{descripción}

**Paso N — Guardar checkpoint S{N}**

```python
await checkpoint.save_stage({N}, {
    "result": {resultado_especifico},
    "metadata": {"model": "{modelo_exacto}", "duration_s": elapsed},
    "summary": f"{resumen_comprimido_para_recovery}"
})
```

---

## 3 · Output

`runs/<run_id>/{NOMBRE_ARCHIVO_OUTPUT}`:

```{formato_json_o_md}
{ejemplo_concreto_del_output}
```

---

## 4 · Modelo

**{MODELO_COMPLETO}** · {justificación en 1-2 líneas · por qué este tipo de modelo y no otro}

Lánzalo como sub-agente con la herramienta **Task** (ventana limpia). El sub-agente recibe solo el
input de este stage; solo el RESULTADO vuelve al orchestrator.

---

## 5 · Costo

Corre sobre tu Claude Code (plan Max/Pro o API propia); no hay cobro aparte.

---

## 6 · Validación

- [ ] `{output_principal}` existe con {condición verificable}
- [ ] {otro criterio binario}
- [ ] `checkpoint stage_{N}.json` guardado

---

## 7 · Fallback

| Falla | Acción |
|---|---|
| {escenario de falla} | {acción concreta} |
| {otro escenario} | {acción} |

---

## 8 · Anti-patterns · Nunca hacer aquí

- ❌ {anti-pattern específico a este stage} — {razón con fuente}
- ❌ {otro anti-pattern}

---

## Mensaje al usuario al terminar

```
✅ Stage {N} · {NOMBRE_STAGE} OK
   {campo clave}:    {valor}

   ▶ Procediendo a Stage {N+1} · {NOMBRE_SIGUIENTE}...
```
