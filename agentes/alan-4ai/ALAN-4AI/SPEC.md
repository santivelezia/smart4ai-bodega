# SPEC · ALAN-4AI

> **ALAN-4AI** — Constructor de agentes Claude · versión para alumnos.
> Este documento es el **contrato de construcción**: toda decisión arquitectural del pipeline deriva de aquí.
> Derivado del meta-agente ALAN (Smart4AI), sanitizado y hecho autocontenido para que cualquier alumno lo
> despliegue en su propio computador y lo use desde Claude Code.

## Trazabilidad de fuentes

Cada decisión cita el archivo de KB específico (todo incluido en `kb/`):
- **base** = `kb/como-construir-agentes-claude-2026/` — arquitectura Claude · anti-patterns · Claude Code · Agent SDK.
- **D** = `kb/agentes-con-memoria-viva-self-improving-systems-2026/` — memoria jerárquica · Patrón 5.
- **E** = `kb/meta-agente-clase-mundial-alan-2026/` — meta-agente · elicitation · pipeline robustness · eval.

---

## 1. Visión

ALAN-4AI es un **Orchestrator-as-Builder**: delega cada fase a sub-agentes con ventana limpia
(herramienta Task de Claude Code). Su filosofía: *"preguntemos hasta que la ambigüedad esté en cero ·
deleguemos cada fase a un sub-agente fresco · y nunca dejemos que la misma ventana que generó el output
lo juzgue"*.

**Frase guía:**
> *"NO genero código hasta que la ambigüedad esté en cero. NUNCA juzgo lo que yo mismo genero.
> CADA stage corre en ventana limpia. La spec es el ancla invariante."*

---

## 2. Los 7 pilares de diseño

| # | Pilar | Origen evidencia | Beneficio |
|---|---|---|---|
| **1** | **Stage Isolation**: Orchestrator + sub-agentes con ventana limpia | E `03_pipeline-robustness-lifecycle.md` | Elimina la saturación de contexto (riesgo #1) |
| **2** | **Discovery R-G-C-C-O-V + 4 niveles + spec-by-example** (clarification-seeking obligatorio) | E `07_elicitacion-especificacion.md` | **+13.4% task success** (SWE-bench Verified) |
| **3** | **Evaluador EXTERNO obligatorio**: la ventana que evalúa nunca es la que generó (cross-provider opcional) | E `08_antipatterns-failure-modes.md` (Evaluation Blindness) | Mata el sycophancy bias · causa #1 de fallos |
| **4** | **Checkpointing entre stages** (JSON en filesystem) | E `03_pipeline-robustness-lifecycle.md` | Recovery en segundos vs re-ejecución completa |
| **5** | **Memory templates Patrón 5 por tier** (CORE 5/5 · Ops 4/5 · Comercial 3/5) | D `09_template-hefesto.md` | Cada agente nace con la memoria correcta para su rol |
| **6** | **Version ID híbrido SemVer** con pin exacto de modelo | E `03_pipeline-robustness-lifecycle.md` | Previene silent model upgrades (causa #1 de regresión) |
| **7** | **13 anti-patterns en Quality Audit**: 5 Anthropic + 4 meta-agente + 4 memoria | E `08` + D `06_anti-patterns-criticos.md` | Detecta fallos invisibles a un test superficial |

---

## 3. Pipeline · 12 stages

```
S0  · Pre-flight (KBs · dirs · checkpoints · modo mono/cross-provider)
S1  · ELICITATION (Discovery R-G-C-C-O-V + 4 niveles + spec-by-example) ⭐
S2  · KB Coverage Check (INDEX + 3 KBs + gap analysis)
S3  · Complexity & Architecture (single-LLM? workflow? single? multi?)

      🛑 GATE 1 · ALCANCE (Plan Mode)

S4  · Pipeline Design
S5  · Memory Strategy (Patrón 5 según tier)

      🛑 GATE 2 · ARQUITECTURA (Plan Mode)

S6  · Code Generation (sub-agente en ventana limpia) ⭐
S7  · Smoke Test Design
S8  · External Evaluation (ventana limpia distinta · 13 anti-patterns + 5 tests) ⭐
S9  · Adversarial Verification (tercer sub-agente · refuta lo aprobado) ⭐
S10 · Version ID + Receipt (SemVer + prompt hash + model snapshot)

      🛑 GATE 3 · ARTEFACTO FINAL (Plan Mode)

S11 · Publication (output/ local + RECEIPT.md + REGISTRY.md · Notion opcional)
```

Cada stage genera un checkpoint en `runs/<run_id>/checkpoints/stage_<N>.json` que permite resume.

---

## 4. Stack de ejecución

ALAN-4AI corre **enteramente sobre Claude Code**: los sub-agentes se lanzan con la herramienta **Task**
nativa. No requiere ningún router, backend ni servicio externo.

| Stage | Ventana / modelo | Por qué |
|---|---|---|
| S1, S3 | Sub-agente · modelo de razonamiento fuerte | Interview y arquitectura de calidad |
| S2, S4-S7, S10-S11 | Sub-agente · modelo rápido y capaz | Volumen · generación · escritura |
| **S8 Evaluation** | **Ventana limpia distinta** (o GPT-4o-mini con `OPENAI_API_KEY`) | Evaluador ≠ generador |
| **S9 Adversarial** | **Tercer sub-agente** (o Kimi con `OPENROUTER_API_KEY`) | Tercera opinión adversarial |

**Modo mono-proveedor (default):** sin claves extra, S8 y S9 corren en ventanas limpias con rol adversarial
explícito. **Modo cross-provider (opcional):** con claves en `.env.local`, S8/S9 usan otro proveedor.

---

## 5. Criterios de éxito de la construcción

Un agente generado por ALAN-4AI está LISTO cuando:
- [ ] Los 3 archivos núcleo existen (CLAUDE.md <80 líneas · agent.md <300 líneas · README.md).
- [ ] Los stages existen con sus 8 sub-elementos cada uno.
- [ ] Los templates aplicables existen (claude_md, agent_md, smoke_test, memoria según tier).
- [ ] La convención de checkpoints está aplicada.
- [ ] Los 13 anti-patterns están verificados (evaluador + adversarial).
- [ ] El smoke test plan existe con caso concreto ejecutable.

---

## 6. Lo que NO cambia (principios preservados)

- ✅ *"Si basta una sola llamada LLM, NO construyas un agente"* (heurística #1 Anthropic).
- ✅ 3 Plan Mode gates (alcance · arquitectura · artefacto final).
- ✅ Evaluador externo obligatorio (ventana ≠ generador) · NUNCA self-eval como gate.
- ✅ Output canónico (`output/<nombre>/` con CLAUDE.md, agent.md, stages/, tests/, runs/).
- ✅ Receipt local + registro · Parámetro `auto_approve_gates=true` para runs autónomos.

---

## 7. Lecciones destiladas

Ver `docs/LECCIONES.md` — aprendizajes transferibles de construir agentes reales con este pipeline
(protocolo de canal explícito · verificar la premisa antes de aceptar un FAIL · el consenso entre modelos
es señal, no prueba · el valor del panel adversarial es la lista de fixes, no el veredicto).

---

*Esta SPEC es el contrato. Cualquier cambio se documenta aquí con justificación.*
