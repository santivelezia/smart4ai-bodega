# 13 Anti-Patterns · Checklist de Quality Audit

> Usado por el sub-agente **Evaluador** (Stage 8, ventana limpia distinta) y el sub-agente **Adversarial** (Stage 9, tercer sub-agente en ventana limpia).
> En modo cross-provider opcional, el Evaluador puede correr sobre GPT-4o-mini (si tienes `OPENAI_API_KEY`) y el Adversarial sobre Kimi (si tienes `OPENROUTER_API_KEY`); si no, ambos corren como sub-agentes Claude en ventanas limpias distintas.
> Todo agente generado por ALAN-4AI debe PASAR las 13 verificaciones antes de marcarse `AGENTE_LISTO`.
> Regla: **13/13 PASS** para AGENTE_LISTO. Cualquier FAIL → `NECESITA_ITERACION` con el stage a re-ejecutar.
> Cada veredicto requiere **evidencia archivo:línea** · NO se acepta PASS sin evidencia.

---

## Categoría A · 5 Anti-Patterns canónicos de Anthropic [KB-base 09 A1]

### 1. Kitchen sink CLAUDE.md
- **Qué es:** CLAUDE.md inflado con reglas innecesarias (>80 líneas sin prune ruthless).
- **Cómo se detecta:** contar líneas del `CLAUDE.md` generado · aplicar test "¿quitar esta línea causaría un error del modelo?" a cada una.
- **PASS si:** ≤80 líneas Y cada línea pasa el remove-test.

### 2. Correcting twice
- **Qué es:** el mismo error aparece 2+ veces sin fix estructural (se parchea en vez de arreglar la raíz).
- **Cómo se detecta:** buscar reglas duplicadas o que corrigen el mismo síntoma en distintos lugares.
- **PASS si:** 0 correcciones duplicadas · cada problema resuelto en su raíz.

### 3. Over-specified CLAUDE.md
- **Qué es:** instrucciones que el modelo ya sabe por defecto (ej. "sé útil", "responde en español" cuando ya es obvio).
- **Cómo se detecta:** revisar cada regla · ¿aporta algo que el modelo no haría solo?
- **PASS si:** 0 reglas redundantes con el comportamiento base del modelo.

### 4. Trust-then-verify gap
- **Qué es:** publicar el agente sin un smoke test ejecutable que lo valide.
- **Cómo se detecta:** verificar que existe `tests/smoke_test.md` con caso concreto + métricas + 3 escenarios.
- **PASS si:** smoke test existe Y es simulable sin obstáculos.

### 5. Infinite exploration
- **Qué es:** el agente puede entrar en bucles sin criterio de halt (loops de búsqueda/verificación sin fin).
- **Cómo se detecta:** buscar condiciones de terminación explícitas en cada loop/stage del agente generado.
- **PASS si:** todo loop tiene criterio de halt + hard limit documentado.

---

## Categoría B · 4 Anti-Patterns de Meta-Agentes [E 08]

### 6. Context Accumulation sin curation
- **Qué es:** el agente pasa TODO el historial al siguiente paso (degenera vs baseline).
- **Cómo se detecta:** revisar si el agente filtra/resume contexto o lo acumula crudo.
- **PASS si:** el agente cura el contexto (top-N, resumen, o reset) entre pasos.

### 7. Specification Drift
- **Qué es:** el agente deriva de la spec original tras muchos turns (hace cosas distintas al turn 1 vs turn 30).
- **Cómo se detecta:** verificar que la spec está anclada como invariante y se re-ancla en cada gate.
- **PASS si:** la spec es referencia invariante · no se parchea implementación, se regenera desde spec.

### 8. Recursive Context Leakage
- **Qué es:** bucles de auto-planificación que inflan el contexto recursivamente (recursive black hole).
- **Cómo se detecta:** si el agente puede spawnar sub-agentes, buscar hard limit de profundidad.
- **PASS si:** hard limit de recursión declarado (max N=3) + timer/token monitor.

### 9. Capability Inheritance Bugs
- **Qué es:** sub-agentes heredan capabilities incompletas o implícitas (identity fragmentation).
- **Cómo se detecta:** verificar que el agente declara `capabilities[]` EXPLÍCITAMENTE, no por herencia implícita.
- **PASS si:** capabilities declaradas explícitamente en la spec del agente.

---

## Categoría C · 4 Anti-Patterns de Memoria [D 06]

### 10. Catastrophic forgetting
- **Qué es:** el agente pierde conocimiento previo al incorporar nuevo (sobrescritura destructiva).
- **Cómo se detecta:** revisar la estrategia de memoria · ¿usa External Knowledge (append) o sobrescribe?
- **PASS si:** External Knowledge pattern · memoria aditiva · sin sobrescritura destructiva.

### 11. Sycophancy drift
- **Qué es:** el agente deriva a "siempre darle la razón al usuario" en vez de ser correcto.
- **Cómo se detecta:** verificar que el agente usa reasoning, no solo instruction-following complaciente.
- **PASS si:** el agente tiene criterio propio documentado · no optimiza por complacer.

### 12. Memory bloat
- **Qué es:** la memoria crece sin curation (>50% mes a mes · poor garbage collection).
- **Cómo se detecta:** verificar retention policy + garbage collection en la config de memoria.
- **PASS si:** retention policy + límites de crecimiento definidos.

### 13. False memories
- **Qué es:** retrieval top-k devuelve contexto redundante o falso · poda elimina prerequisitos.
- **Cómo se detecta:** verificar que el retrieval es jerárquico (temas → episodios → raw), no top-k plano.
- **PASS si:** retrieval estructurado jerárquico · no top-k ingenuo.

---

## Rúbrica de scoring (consolidación S8 + S9)

```
Cada anti-pattern: PASS / FAIL + evidencia archivo:línea

AGENTE_LISTO       → 13/13 PASS (y 5/5 quality tests)
NECESITA_ITERACION → ≥1 FAIL · listar cuáles + stage de ALAN-4AI a re-ejecutar

Sub-agente Evaluador (S8, ventana limpia distinta) emite el primer veredicto.
Sub-agente Adversarial (S9, tercer sub-agente) intenta REFUTAR los PASS.
Si Adversarial contradice al Evaluador en algún ítem → flag para GATE 3 (el usuario decide).

Modo cross-provider opcional: Evaluador sobre GPT-4o-mini (`OPENAI_API_KEY`) ·
Adversarial sobre Kimi (`OPENROUTER_API_KEY`). Sin esas claves → ambos como
sub-agentes Claude en ventanas limpias distintas (modo mono-proveedor).
```

**Regla de oro:** el evaluador NUNCA es la misma ventana que generó el agente (mata el Evaluation Blindness · causa #1 de fallos de meta-agentes 2026).
