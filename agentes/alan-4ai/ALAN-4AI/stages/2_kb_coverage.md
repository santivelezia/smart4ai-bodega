# Stage 2 · KB Coverage Check · modelo rápido y capaz (ej. Claude Sonnet)

## Propósito

Medir qué porcentaje de las necesidades del agente a construir está cubierto por las bases de conocimiento existentes en `kb/`. Si la cobertura es baja (`coverage_score < 0.5`), ALAN-4AI recomienda investigar el gap tú mismo (WebSearch / tus fuentes) antes de construir. Construir sobre KBs insuficientes es la causa directa de Specification Drift en stages posteriores. [E 08 Anti-Pattern 2]

---

## 1 · Input

| Fuente | Contenido |
|---|---|
| `runs/<run_id>/elicitation_spec.md` | Spec completa con tier + dominio + casos de uso |
| `kb/INDEX.md` | Índice global de todas las KBs disponibles |
| `kb/como-construir-agentes-claude-2026/` | KB-base · arquitectura Claude · anti-patterns |
| `kb/agentes-con-memoria-viva-self-improving-systems-2026/` | KB-D · memoria · Patrón 5 |
| `kb/meta-agente-clase-mundial-alan-2026/` | KB-E · ALAN · elicitation · pipeline robustness |
| KBs adicionales listadas en INDEX.md | extensiones temáticas si existen |

---

## 2 · Proceso

**Paso 1 — Leer INDEX.md global**
- Parsear todas las entradas con `estado: INVESTIGACION_LISTA`
- Construir lista de KBs disponibles con su `dominio` y `fecha_creacion`

**Paso 2 — Leer KB-base (siempre obligatorio)**
- Leer archivos clave: `02_fundamentos-y-arquitectura.md` · `09_antipatrones-y-sota.md` · índice de claims
- Este KB cubre: arquitectura agentes · anti-patterns Anthropic · sub-agentes (herramienta Task) · testing

**Paso 3 — Leer KB-D y KB-E (críticos para ALAN-4AI)**
- KB-D (`agentes-con-memoria-viva-self-improving-systems-2026/`): cubre Patrón 5 de memoria · los 5 sistemas
- KB-E (`meta-agente-clase-mundial-alan-2026/`): cubre elicitation · pipeline robustness · anti-patterns meta-agente
- Ambos son requeridos para cualquier agente con tier CORE

**Paso 4 — Identificar dominios del agente a construir**
- Extraer de `elicitation_spec.md`: dominio principal + dominios secundarios
- Ejemplo: "agente de ventas WhatsApp" → dominios: {mensajería, ventas, compliance LATAM}

**Paso 5 — Comparar dominios vs KBs disponibles**
- Para cada dominio del agente, verificar si algún KB lo cubre parcial o totalmente
- Asignar peso por dominio (dominio principal = 0.6 · secundarios = 0.4 total)

**Paso 6 — Calcular `coverage_score`**
```
coverage_score = Σ(peso_dominio × cobertura_kb) / Σ(pesos_totales)
Escala: 0.0 (sin cobertura) → 1.0 (cobertura completa)
```

Umbrales:
- `>= 0.8` → Cobertura excelente · continuar a S3
- `0.5-0.8` → Cobertura parcial · warning · continuar con gaps documentados
- `< 0.5` → Cobertura insuficiente → recomendar investigar el gap manualmente antes de S3

**Paso 7 — Documentar gaps**
- Para cada dominio sin cobertura → listar en `kb_gaps.md` con sugerencia de tema a investigar
- Si el agente es tier CORE y KB-D o KB-E tienen age > 90 días → WARNING específico

**Paso 8 — Guardar checkpoint S2**
```python
await checkpoint.save_stage(2, {
    "result": {"coverage_score": score, "kbs_read": kb_list, "gaps": gaps},
    "metadata": {"model": model_snapshot, "duration_s": elapsed},
    "summary": f"coverage={score:.2f} · {len(kbs_read)} KBs · {len(gaps)} gaps"
})
```

---

## 3 · Output

`runs/<run_id>/kb_coverage.json`:

```json
{
  "coverage_score": 0.82,
  "kbs_read": [
    {"id": "base", "path": "kb/como-construir-agentes-claude-2026", "domains_covered": ["arquitectura", "anti-patterns"]},
    {"id": "D", "path": "kb/agentes-con-memoria-viva-self-improving-systems-2026", "domains_covered": ["memoria"]},
    {"id": "E", "path": "kb/meta-agente-clase-mundial-alan-2026", "domains_covered": ["meta-agente", "elicitation"]}
  ],
  "agent_domains": {
    "primary": "agente-ventas-whatsapp",
    "secondary": ["mensajería", "compliance-latam"]
  },
  "gaps": [
    {"domain": "compliance-latam", "coverage": 0.0, "recommendation": "investigar manualmente (WebSearch/tus fuentes) · tema: 'WhatsApp Business API compliance LATAM 2026'"}
  ],
  "investigate_gap": false,
  "warnings": ["KB-E tiene 12 días · fresco"]
}
```

`runs/<run_id>/kb_gaps.md` — si hay gaps:
```markdown
# KB Gaps Detectados

## Gap 1 · compliance-latam
- Cobertura actual: 0.0
- KBs buscados: base, D, E
- Recomendación: investigar el gap manualmente (WebSearch / tus fuentes) con tema
  `"WhatsApp Business API compliance LATAM 2026"` y agregar notas a `kb/`
- Impacto: dominio secundario (peso 0.20) · no bloquea construcción
```

---

## 4 · Modelo

**Modelo rápido y capaz (ej. Claude Sonnet)** · lectura bulk de archivos + análisis de cobertura.

Justificación: las KBs son archivos extensos (hasta 400 líneas cada uno) · un modelo rápido con caché ofrece descuento en tokens de input para lecturas repetidas del mismo KB. [SPEC.md §4]

Lánzalo como sub-agente con la herramienta Task (ventana limpia) que reciba el contenido de las KBs + la spec y devuelva el análisis de cobertura.

---

## 5 · Costo

Corre sobre tu Claude Code (plan Max/Pro o API propia); no hay cobro aparte. 1-2 lecturas de análisis sobre 3-5 KBs.

---

## 6 · Validación

- [ ] `kb_coverage.json` existe con `coverage_score` calculado
- [ ] Los 3 KBs requeridos (base · D · E) aparecen en `kbs_read`
- [ ] Si `coverage_score < 0.5` → `investigate_gap: true` documentado
- [ ] `kb_gaps.md` existe (puede estar vacío si coverage = 1.0)
- [ ] `checkpoint stage_2.json` guardado

---

## 7 · Fallback

| Falla | Acción |
|---|---|
| `INDEX.md` desactualizado o ausente | Crear skeleton con los 3 KBs conocidos · **WARNING** · continuar |
| KB-base no readable | **STOP** · "KB base corrupto · revisa `kb/como-construir-agentes-claude-2026`" |
| KB-D o KB-E ausentes | **STOP** · "KBs críticos para ALAN-4AI ausentes · verifica que `kb/` tenga las 3 carpetas con `.meta.json`" |
| `coverage_score < 0.5` | Reportar gaps · recomendar investigar el gap manualmente · usuario decide si continuar |
| Timeout en lectura de KB grande | Dividir KB en chunks · varias lecturas · consolidar coverage_score |
| KBs adicionales no accesibles | **WARNING** (no bloquea si base+D+E OK) · documentar en gaps |

---

## 8 · Anti-patterns · Nunca hacer aquí

- ❌ Calcular coverage_score sin leer efectivamente los KBs — número inventado = Specification Drift [E 08 Anti-Pattern 2]
- ❌ Ignorar `coverage_score < 0.5` y avanzar a S3 sin mencionar al usuario
- ❌ Leer solo el KB-base e ignorar KB-D y KB-E para agentes CORE — omite Patrón 5 completo [D 09]
- ❌ Dejar `kb_gaps.md` sin generar — S3/S4 no sabrán qué dominios construir con incertidumbre
- ❌ Usar KBs con age > 90 días sin warning explícito — claims pueden haber cambiado [E 03 A3]

---

## Mensaje al usuario al terminar

```
✅ Stage 2 · KB Coverage Check OK
   KBs leídos:          {N} ({lista})
   Coverage score:      {score:.2f} ({EXCELENTE | PARCIAL | INSUFICIENTE})
   Dominios cubiertos:  {lista}
   Gaps detectados:     {M}

   {si coverage <0.5}
   ⚠️ Coverage insuficiente en: {dominios}
   Recomendación: investigar el gap tú mismo (WebSearch / tus fuentes)
   con tema: "{tema sugerido}" y agregar notas a kb/
   ¿Quieres investigar ahora o continuar con los KBs actuales?

   ▶ Procediendo a Stage 3 · Complexity & Architecture...
```
