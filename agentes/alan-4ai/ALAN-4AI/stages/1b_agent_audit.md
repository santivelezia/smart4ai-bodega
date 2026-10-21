# Stage 1b · Agent Audit (solo MODO B) ⭐ · Modelo de razonamiento fuerte (ej. Claude Opus · rol critical-reasoning)

## Propósito

Reemplaza a S1 cuando ALAN-4AI opera en **Modo B** (upgrade de un agente existente). En vez de elicitar una spec desde cero, ALAN-4AI primero **audita el agente objetivo** con los mismos estándares que exige a los agentes nuevos, y después elicita con el usuario el **DELTA**: qué duele, qué se preserva, qué cambia. El output es un `upgrade_spec.md` que ancla todo el resto del pipeline (S2-S11), igual que `elicitation_spec.md` lo hace en Modo A.

Principio no-negociable: **auditar antes de opinar**. ALAN-4AI no propone ningún cambio hasta haber leído el agente completo y medido su estado real contra los 13 anti-patterns.

---

## 1 · Input

| Fuente | Contenido |
|---|---|
| `runs/<run_id>/preflight.json` | Stage 0 OK · run_id activo · **backup verificado** (obligatorio en Modo B) |
| `output/<nombre>/` completo | CLAUDE.md · agent.md · README.md · stages/ · templates/ · tests/ |
| `output/<nombre>/runs/` (si existe) | Error logs · receipts · evidencia de fallos reales en producción |
| Spec/versión previa del agente | SPEC, version.json o sección de versión en README (si existen) |
| Queja/objetivo inicial del usuario | Qué duele hoy · puede ser vago · el audit lo aterriza |

---

## 2 · Proceso

**Paso 1 — Inventario del agente objetivo**
- Listar todos los archivos con conteo de líneas
- Verificar caps: CLAUDE.md <80 · agent.md <300 · stages con 8 sub-elementos
- Identificar versión actual, tier declarado y patrón arquitectural (si están documentados; si no, ese ya es un hallazgo)

**Paso 2 — Baseline de 13 anti-patterns** [docs/13_antipatterns.md]
- Correr las 13 detecciones contra el agente TAL COMO ESTÁ hoy
- Cada veredicto con evidencia `archivo:línea` (regla anti-falso-positivo)
- Resultado: `baseline_score` = N/13 PASS · este número es la línea base que el upgrade debe mejorar (o al menos no empeorar)

**Paso 3 — Drift check contra su propia spec**
- Si el agente tiene spec/brief previo: comparar R-G-C-C-O-V documentado vs comportamiento descrito en agent.md/stages
- Revisar `runs/` del agente: ¿los error logs muestran fallos recurrentes? ¿qué stages fallan más?
- Documentar divergencias como candidatos a fix

**Paso 4 — Elicitación del DELTA con el usuario (interview dirigido)**
- "¿Qué te duele hoy de este agente? Dame un ejemplo concreto del último fallo."
- "De lo que hace hoy, ¿qué funciona bien y NO debo tocar?" → lista de preservación
- "¿Qué capacidad nueva esperas después del upgrade? ¿Cómo la verificarías?"
- Spec-by-example del delta: 2 ejemplos de comportamiento nuevo esperado + 1 ejemplo de comportamiento actual que debe seguir idéntico (no-regresión)

**Paso 5 — Construir `upgrade_spec.md`** (template: `templates/upgrade_spec_template.md`)
- La sección de audit se rotula "ESTADO PRE-UPGRADE" — S8 la recibirá junto al resultado y NO debe confundirlas
- Sección "Se preserva" (archivos/runners/comportamientos intocables) · Sección "Cambia" (con evidencia del audit) · Criterios de no-regresión · version bump propuesto (MAJOR/MINOR/PATCH)
- Confirmar con el usuario: *"¿El delta está completo?"* · en `auto_approve_gates=true` la spec la da el usuario por adelantado

**Paso 6 — Guardar checkpoint S1**
```python
await checkpoint.save_stage(1, {
    "result": {"mode": "B", "upgrade_spec_path": "runs/<run_id>/upgrade_spec.md",
               "baseline_antipatterns": baseline_score, "target_agent": nombre},
    "metadata": {"model": model_used, "duration_s": elapsed},
    "summary": f"Audit {nombre}: baseline {baseline_score}/13 AP · {n_hallazgos} hallazgos · delta confirmado"
})
```

---

## 3 · Output

`runs/<run_id>/upgrade_spec.md` — contiene: inventario + baseline 13 AP con evidencia + drift check + lista "Se preserva" / "Cambia" + criterios de no-regresión + version bump propuesto + confirmación del usuario.

`runs/<run_id>/agent_audit.json` — scores machine-readable (baseline por anti-pattern · caps · hallazgos por severidad).

---

## 4 · Modelo

**Rol `critical-reasoning`** (modelo de razonamiento fuerte, ej. Claude Opus · ver agent.md §Modelos por stage) · el audit requiere leer el agente completo y razonar sobre divergencias sutiles — mismo nivel de exigencia que la elicitación de Modo A.

---

## 5 · Costo estimado

Corre sobre tu Claude Code (plan Max/Pro o API propia); no hay cobro aparte. El audit es la lectura completa del agente objetivo + el interview del delta, así que en agentes grandes (>3.000 líneas) toma más tokens de contexto que en agentes pequeños.

---

## 6 · Validación

- [ ] Backup del agente objetivo verificado en S0 (pre-requisito duro)
- [ ] `agent_audit.json` con 13 veredictos baseline + evidencia archivo:línea
- [ ] `upgrade_spec.md` con secciones "Se preserva" y "Cambia" no vacías
- [ ] Criterios de no-regresión definidos (mínimo 1 caso verificable)
- [ ] Version bump propuesto con justificación MAJOR/MINOR/PATCH
- [ ] Usuario confirmó el delta (o spec dada por completa en modo desatendido)
- [ ] `checkpoint stage_1.json` guardado con `mode: "B"`

---

## 7 · Fallback

| Falla | Acción |
|---|---|
| Agente objetivo sin spec/versión documentada | El audit reconstruye la spec implícita desde agent.md · documentar como hallazgo · el upgrade DEBE dejarla explícita |
| Agente objetivo tan roto que no pasa >6/13 baseline | Proponer al usuario reconstrucción (Modo A con spec heredada) en vez de upgrade quirúrgico · usuario decide en GATE 1 |
| Usuario no sabe qué preservar | Default conservador: preservar TODO lo que tiene evidencia de funcionar en `runs/` · cambiar solo lo que tiene evidencia de fallo |
| `runs/` del agente vacío (nunca ejecutado) | Baseline solo estático (13 AP + caps) · marcar "sin evidencia de producción" en upgrade_spec |
| Delta crece hasta parecer agente nuevo (>60% del agente cambia) | Warning: "esto es reconstrucción, no upgrade" · re-plantear como Modo A · GATE 1 lo decide |

---

## 8 · Anti-patterns · Nunca hacer aquí

- ❌ Proponer cambios sin haber leído el agente completo — opinar sin auditar
- ❌ Regenerar desde cero lo que funciona — el objetivo de Modo B es quirúrgico, no demolición
- ❌ Saltarse el baseline de 13 AP — sin línea base no se puede probar que el upgrade mejoró algo
- ❌ Marcar FAIL sin evidencia archivo:línea — falsos positivos contaminan el arbitraje
- ❌ Aceptar "mejóralo todo" como delta — sin criterios de no-regresión el upgrade no es verificable
- ❌ Tocar el agente objetivo durante el audit — S1b es 100% read-only · la escritura empieza en S6

---

## Mensaje al usuario al terminar

```
✅ Stage 1b · Agent Audit COMPLETO (Modo B)
   Agente objetivo:     output/{nombre}/ · v{X.Y.Z} actual
   Baseline 13 AP:      {N}/13 PASS ({hallazgos} hallazgos con evidencia)
   Caps:                CLAUDE.md {K}L · agent.md {L}L
   Se preserva:         {n} elementos · Cambia: {m} elementos
   No-regresión:        {c} casos definidos
   Version bump:        {MAJOR|MINOR|PATCH} propuesto

   upgrade_spec.md guardado en runs/{run_id}/

   ▶ Procediendo a Stage 2 · KB Coverage Check...
```
