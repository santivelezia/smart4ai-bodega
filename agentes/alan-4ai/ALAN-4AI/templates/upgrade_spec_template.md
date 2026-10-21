# Upgrade Spec · {nombre-agente} · v{actual} → v{objetivo}

> Generado por ALAN-4AI · Modo B · Stage 1b (Agent Audit)
> Run ID: {run_id} · Fecha: {ISO8601}
> Este documento es el ANCLA del upgrade — S2-S11 derivan de aquí, igual que elicitation_spec.md en Modo A.

## 1 · ESTADO PRE-UPGRADE (audit S1b · esto es lo que el upgrade CORRIGE — no es el resultado) [L11]

- Versión actual: v{X.Y.Z} · Tier: {CORE | Ops | Comercial} · Patrón: {patrón}
- Inventario: {N} archivos · CLAUDE.md {K}L (cap 80) · agent.md {L}L (cap 300)
- **Baseline 13 anti-patterns: {N}/13 PASS**

| Anti-pattern | Veredicto | Evidencia (archivo:línea) |
|---|---|---|
| A1 Kitchen Sink | {PASS/FAIL} | {evidencia} |
| ... (13 filas) | | |

- Drift vs spec propia: {hallazgos o "sin spec previa — reconstruida en este audit"}
- Evidencia de producción (`runs/` del agente): {fallos recurrentes o "sin runs previos"}

## 2 · Qué duele (input del usuario)

{Queja concreta + ejemplo del último fallo real}

## 3 · SE PRESERVA (intocable · verificado que funciona)

| Elemento | Evidencia de que funciona | Regla |
|---|---|---|
| {archivo/runner/comportamiento} | {run/receipt que lo prueba} | NO tocar en S6 |

## 4 · CAMBIA (el delta)

| # | Cambio | Origen (audit hallazgo / pedido usuario) | Stage que lo implementa |
|---|---|---|---|
| 1 | {cambio concreto} | {evidencia o pedido} | S6 |

## 5 · Spec-by-example del delta

### Comportamiento nuevo esperado (2)
1. Input: {ejemplo} → Output esperado: {resultado}
2. ...

### No-regresión (1+ · lo que debe seguir idéntico)
1. Input: {ejemplo que hoy funciona} → Output: {mismo resultado de hoy}

## 6 · Criterios de no-regresión (gate de S7)

- [ ] {caso verificable 1 — copy-paste ejecutable}
- [ ] Baseline 13 AP post-upgrade ≥ baseline pre-upgrade ({N}/13)
- [ ] Caps respetados: CLAUDE.md <80 · agent.md <300

## 7 · Version bump propuesto

**{MAJOR | MINOR | PATCH}** — Razón: {breaking change en behavior/output · capacidad nueva · solo fixes}
Version ID objetivo: v{X.Y.Z}+{prompt_hash}+{model_snapshot}

## 8 · Confirmación

- [ ] Usuario confirmó "delta completo" · Fecha: {ISO8601}
- Backup verificado: `output/{nombre}/_backup_v{X.Y.Z}/` ✓ (pre-requisito S0)
