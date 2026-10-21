# 98 · Contradicciones y gaps

> Claims marcados `uncertain` o `[INFERENCIA]` que requieren validación adicional o aceptar como hipótesis.

---

## 1 · Claims marcados `uncertain` en validations.jsonl

### c008 · Patrones SOTA no canónicos Anthropic

**Claim**: "Patrones SOTA emergentes 2024-2026 que NO están en el post canónico de Anthropic: ReAct, Reflection, Ensemble, Planner/Executor split, Hybrid LRM+LLM."

**Razón uncertain**: Anthropic docs no mencionan ReAct/Reflection/Ensemble como patrones canónicos; survey HF (2504.19678) sí. Es válido como knowledge externo pero NO se debe presentar como recomendación oficial Anthropic.

**Recomendación**: Mantener marca [INFERENCIA] cuando se cite. Para validar adopción → ejecutar pilot interno con uno de los patrones (ej: Reflection en Agente 6) y medir impacto en quality eval Stage 11.

### c043 · Catálogo MCPs canónicos

**Claim**: Lista de MCPs canónicos 2026 (filesystem, memory, github, slack, postgres, puppeteer, Playwright, Notion, Linear, Gmail).

**Razón uncertain**: Catálogo MCPs cambia rápido. Lista probablemente correcta a 2026-05-19 pero requiere refresh trimestral.

**Recomendación**: Programar un `claude mcp list` + scrape de claude.ai/directory cada trimestre. Si Smart4AI adopta nuevos MCPs, agregarlos al brief del Agente 6.

### c081 · Patrones convergentes SOTA

**Claim**: 7 patrones convergentes SOTA 2024-2026 (Planner/Executor, Verifier agents, Workflow-guided, Tool-augmented ReAct, Hybrid LRM+LLM, Protocol convergence, Live benchmarks).

**Razón uncertain**: Síntesis inferida de mi análisis cruzado de 6 papers HF. No hay paper único que afirme "estos son los 7 patrones convergentes".

**Recomendación**: Tratar como hipótesis razonable. Si Stage 11 quality audit detecta que el output del Agente 6 puede mejorarse adoptando uno → testear formalmente vs baseline.

### c082 · Frameworks comerciales ranked

**Claim**: Tabla comparativa Claude Agent SDK / LangGraph / CrewAI / AutoGen / AgentLite / LlamaIndex Agents.

**Razón uncertain**: Comparativa no oficialmente ranked por entidad neutra. Estado de cada framework cambia mensualmente.

**Recomendación**: Marcar fecha del snapshot (2026-05-19) en el documento. Considerar tabla como starting point para due-diligence, no como verdad absoluta.

---

## 2 · Gaps explícitos del brief que la investigación NO cerró completamente

### Gap 1 · Cuándo skill vs agente dedicado

El brief preguntaba: *"Cuándo crear Skill vs agent dedicado"*.

**Respondido parcialmente** en categoría 06 (Skills): "create skill when you keep pasting the same instructions" + table de control de invocación.

**Pendiente**: criterio explícito para decidir cuándo una operación amerita su propio sub-agent en .claude/agents/ vs solo skill en .claude/skills/.

Hipótesis (no validada):
- **Skill**: cuando el output requerido es texto/markdown/explicación + no necesita herramientas que el main agent no tenga
- **Sub-agent dedicado**: cuando necesita context window aislado + posiblemente modelo diferente + permission rules específicas

### Gap 2 · Eval frameworks objetivos prácticos

El brief preguntaba: *"frameworks de evaluación objetiva de calidad de agentes"*.

**Respondido**: framework SMART + 6 métodos eval canónicos Anthropic.

**Pendiente**: comparativa de **herramientas comerciales** (LangSmith, Anthropic Console evals, custom un router multi-modelo evals). La investigación no profundizó en pricing/integration de cada uno.

**Recomendación**: investigación follow-up de 2-3 horas si Smart4AI quiere adoptar uno antes del bootcamp.

### Gap 3 · Memory MCP knowledge graph deep-dive

El brief preguntaba: *"Memory MCP (knowledge graph) vs filesystem"*.

**Respondido**: definición + API exposed + decision tree.

**Pendiente**: ejemplo concreto de cuándo entity-centric queries pagan vs flat storage. Sería ideal tener case study de Smart4AI usando Memory MCP en producción para validar.

---

## 3 · Contradicciones reales identificadas

### Contradicción 1 · `model` field reload behavior

Source A (settings doc): "Settings que requieren restart: model, outputStyle"
Source B (overview doc): "/model mid-session"

**Resolución**: ambos son ciertos. Configurar via settings.json requiere restart, pero `/model` slash command cambia para current session.

### Contradicción 2 · Auto-mode availability

Source A: "auto mode classifier evaluates tool use"
Source B (v2.1.142+): "auto mode cannot be set in project/local settings"

**Resolución**: la restricción es para PERMISSION SETTINGS (no se puede setear en project/local), pero auto-mode SÍ está disponible para invocación manual con `--permission-mode auto` o set en user settings.

---

## 4 · Áreas donde se cita una sola fuente (priority=medium o below)

Estas no son contradicciones pero conviene cross-validar si se acciona en producción crítica:

- c019: UserPromptSubmit timeout 30s (vs 600s default) — solo hooks doc
- c041: MCP config storage en 3 lugares — solo MCP doc (no contradicho, pero no triangulado)
- c054: Skill descriptions budget = 1% context window — solo skills doc
- c091: Auto mode no en project/local desde v2.1.142 — solo settings doc

**Mitigación**: estas son docs oficiales Anthropic. Confiables al menos hasta refresh trimestral.

---

## 5 · Recomendación para el Agente 6

Cuando se construya el Agente 6 (Creador de agentes Claude) y use esta knowledge base:

1. **Tratar claims c008, c081, c082** con marca [INFERENCIA] al output
2. **Refrescar catálogo MCPs (c043)** cada 90 días via `claude mcp list` + scrape de directory
3. **Validar gap 1** (skill vs sub-agent) con un piloto cuando construya Agente 6 — registrar la decisión
4. **Cerrar gap 2** (eval frameworks) ANTES de construir el Agente 6 si se quiere usar eval automation
