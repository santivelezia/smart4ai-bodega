# 00 · ÍNDICE · Cómo construir agentes con Claude al máximo nivel (2026)

> Knowledge base lista para cargar en Stage 0 del **Agente 6 · Creador de agentes Claude**.
> Fecha cierre: 2026-05-19. Versión: 1.0.

## Estructura

| # | Archivo | Sub-Qs cubiertas | Líneas | Resumen |
|---|---|---|---|---|
| 01 | [Resumen ejecutivo](01_resumen-ejecutivo.md) | todas | ~80 | TL;DR + 10 insights críticos |
| 02 | [Fundamentos y arquitectura](02_fundamentos-y-arquitectura.md) | q01, q02, q03 | ~190 | 7 componentes core, 5 patrones canónicos, workflow vs agent decision |
| 03 | [Claude Code completo](03_claude-code-completo.md) | q04, q05 | ~310 | Settings (5 scopes), 28 hooks, 6 permission modes, sub-agents, common workflows |
| 04 | [Prompt y system design](04_prompt-y-system-design.md) | q06 | ~140 | CLAUDE.md include/exclude, XML tags, pruning ruthless |
| 05 | [Agent SDK en producción](05_agent-sdk-en-produccion.md) | q07, q08 | ~210 | SDK vs CLI vs Managed, setup, sessions, June 2026 billing change |
| 06 | [MCPs y Skills · ecosistema](06_mcps-y-skills-ecosistema.md) | q09, q10 | ~390 | MCP 3 transports + permissions + custom; Skills 15 fields frontmatter, lifecycle, dynamic context injection |
| 07 | [Memory y context engineering](07_memory-y-context-engineering.md) | q11 | ~220 | 3 capas (CLAUDE.md/auto-memory/Memory MCP), prompt caching pricing + breakpoints |
| 08 | [Calidad, costos y operaciones](08_calidad-costos-ops.md) | q12, q13 | ~210 | Framework SMART, 6 eval methods, un router multi-modelo, receipts pattern |
| 09 | [Anti-patrones y SOTA](09_antipatrones-y-sota.md) | q14, q15 | ~270 | 5 anti-patterns canónicos, SOTA papers MALT/CoPlanner/LaRMA/FlowBench, frameworks comparativos |
| 98 | [Contradicciones y gaps](98_contradicciones-y-gaps.md) | — | ~50 | Claims uncertain, áreas de validación pendiente |
| 99 | [Fuentes y bibliografía](99_fuentes-y-bibliografia.md) | — | ~80 | URLs oficiales + papers HF con fecha consulta |

## Para qué sirve esta investigación

- **Stage 0 del Agente 6** (Creador de agentes Claude): cargar carpeta entera como knowledge base
- **Onboarding técnico** para nuevos colaboradores Smart4AI que construyan agentes
- **Referencia rápida** durante refactor o decisión arquitectural
- **Base para Skill** "build-claude-agent" si decides crear uno reutilizable

## Cómo navegar

- Buscas un componente específico (hooks, skills, MCPs) → vé directo al archivo 03, 06
- Buscas justificación de una decisión arquitectural → archivo 02 (canónicos Anthropic) + 09 (SOTA papers)
- Buscas optimizar costo de un agente existente → archivos 07 (caching) + 08 (un router multi-modelo)
- Buscas validar que tu agente no cae en anti-patterns → archivo 09 + categoría 04 (CLAUDE.md hygiene)

## 5 Tests de Calidad

Ver el reporte de auditoría del run original para resultado de:
- Coverage Test (≥3 claims por sub-pregunta)
- Citation Test (100% claims con cita trazable)
- Deduplication Test (<5% redundancia)
- Token Efficiency Test (densidad >0.7)
- Retrieval Test (otro Claude responde 80%+ correctas)
