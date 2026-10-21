# Categoría 2 · Arquitectura de Meta-Agentes y Auto-Mejora
> Sub-preguntas: A1 (patrones SOTA), A2 (bootstrapping/auto-referencia), T1 (novedades 2026)

---

## A1 · Patrones Arquitectónicos SOTA 2026 para Meta-Agentes

### Patrón 1: Agent Factory
[F1] Desarrollo estandarizado como línea de manufactura. Reduce build time 70% (semanas → días).
- Proveedores clave: Microsoft Agent Factory, Oracle Private Agent Factory, NVIDIA Agent Toolkit [F1]
- Patrones de orquestación: Sequential, Concurrent, Handoff, Group Chat, Magentic-One manager
- Caso real: Mizuho Financial desplegó miles de agentes con Amazon Bedrock AgentCore + Dify low-code [F1]
- Mejor para: Enterprise fleets (10+ agentes), compliance-critical, alta estandarización
- Limitación: overhead no justificado para <5 agentes

**Skeleton (agent factory pattern):**
```python
class AgentFactory:
 def __init__(self, templates: dict[str, AgentTemplate]):
 self.templates = templates
 
 def build(self, spec: AgentSpec) -> Agent:
 template = self.templates[spec.type]
 return Agent(
 system_prompt=template.render(spec),
 tools=spec.tools,
 version=f"{spec.major}.{spec.minor}.{spec.patch}"
 )
```

### Patrón 2: HyperAgents / Scaffold Builder (DGM-H)
[F2] Agentes auto-referenciales que modifican tanto el task agent como el meta agent.
- Paper clave: "Hyperagents" (arXiv 2603.19461, mar 2026) — DGM-H elimina asunción de domain-specific alignment [F2]
- Dos componentes: Task agent (resuelve tarea) + Meta agent (modifica ambos, incluyendo su propio proceso de modificación)
- **Metacognitive self-modification**: el meta agent lee código → analiza performance → genera versión modificada → evalúa → archiva [F2]
- Mejoras emergentes tras cientos de iteraciones: persistent memory, performance tracking, multi-stage verification, retry logic [F2]
- El DGM-H mejoró de 20% a 50%+ en coding benchmarks sin más datos de training [F2]
- Mejor para: sistemas de auto-mejora, investigación, agentes de larga duración
- Limitación: requiere cientos de iteraciones · caro · solo útil cuando el corpus de ejecuciones es grande

**Heurística**: La transición Agent Factory → HyperAgents ocurre cuando el agente ha procesado >500 invocaciones y tienes métricas de performance por versión.

### Patrón 3: Orchestrator-as-Builder (Claude Agent SDK)
[F3] El patrón más adecuado para ALAN v2.0 en 2026.
- Claude Agent SDK: `Task` tool spawna sub-agentes con contexto aislado; solo resultados finales vuelven al parent [F3]
- Sub-agentes no pueden spawnar sus propios sub-agentes (no tienen `Task` en sus tools) [F3]
- Claude decide parallelización; tú defines capability, no scheduling [F3]

```javascript
// Claude Agent SDK · meta-agente spawning sub-agentes
for await (const message of query({
 prompt: "Construye el agente-extractor con spec: {spec}",
 options: {
 allowedTools: ["Read", "Glob", "Grep", "Task", "Write"],
 agents: {
 "spec-validator": {
 description: "Valida que la spec tenga todas las secciones obligatorias",
 prompt: "Eres un validador de specs de agentes. Verifica: nombre, herramientas, stages, tests.",
 tools: ["Read"],
 model: "claude-sonnet-4-6"
 },
 "code-generator": {
 description: "Genera el código del agente desde la spec validada",
 prompt: "Eres un generador de agentes. Produce agent.md + stages/ + tests/ desde la spec.",
 tools: ["Read", "Write", "Glob"],
 model: "claude-opus-4-8"
 },
 "test-runner": {
 description: "Ejecuta smoke tests del agente generado",
 prompt: "Ejecuta los tests definidos en tests/smoke_test.md y reporta pass/fail.",
 tools: ["Read", "Bash"],
 model: "claude-sonnet-4-6"
 }
 }
 }
}))
```

**Implicación ALAN v2.0**: ALAN debe usar el patrón Orchestrator-as-Builder con 3 sub-agentes fijos: spec-validator, code-generator, test-runner.

### Patrón 4: ADP-MA (Autonomous Data Processing using Meta-Agents)
[F4] Framework de planificación + orquestación + monitoreo con backtracking.
- Planning module: meta-agente analiza input y diseña plan multi-fase [F4]
- Orchestration layer: instancia agentes especializados con tool integration [F4]
- Monitoring loop: evaluación iterativa con capacidad de backtracking [F4]
- Paper: arXiv 2025 — ADP-MA framework [F4]

### Patrón 5: MAS-ZERO (Zero Supervision Multi-Agent Design)
[F5] Meta-agente diseña el sistema multi-agente completo sin supervision.
- First self-evolved, inference-time framework for automatic MAS design [F5]
- Meta-feedback en solvabilidad y completeness guía la composición dinámica [F5]
- 7.44% accuracy improvement sobre los mejores baselines [F5]
- Paper: arXiv 2505.14996, mayo 2025 [F5]

---

## A2 · Bootstrapping Seguro y Auto-Referencia

### El problema fundamental
Un agente que se auto-mejora puede entrar en bucles recursivos o degradarse si no tiene constraints explícitos. La governance se vuelve un problema de medición: **carecemos de indicadores confiables para detectar cuándo los optimization loops escapan sus bounds** [F6].

### Técnicas de prevención de degradación recursiva

| Técnica | Cómo funciona | Fuente |
|---|---|---|
| Execution gating | Rastrear cuándo el sistema puede proponer/refinar/actuar; forzar autoridad humana explícita en pasos de compounding | [F6] |
| Layered approvals | Aprobación multi-nivel para ediciones de alto impacto al código del agente | [F6] |
| Uncertainty-aware triggers | Solo permitir auto-modificación cuando confidence > umbral; fallback a baseline seguro | [F6] |
| Structured self-critique (Reflexion) | Pipelines de auto-crítica estructurada antes de updates (Shinn et al., 2024; Madaan et al., 2023) | [F6] |
| Sandboxed validation | Correr código auto-modificado en entorno Wasm/test aislado antes de deploy | [F6] |
| Halting criteria + rollback | Condiciones explícitas para detener updates y revertir estados cuando hay regresiones | [F6] |

### El insight crítico de la especificación como ancla
[F7] "Bootstrapping Coding Agents: The Specification Is the Program" (arXiv 2026):
- La spec en lenguaje natural es el artefacto estable, no la implementación
- Los agentes pueden regenerarse a sí mismos desde la spec sin perder correctness
- Ventaja: la spec es auditable por humanos; la implementación no

**Implicación ALAN v2.0**: ALAN debe mantener la spec del agente como el ground truth invariante. Cada generación de código se regenera desde la spec, no se parchea en lugar.

### Papers clave sobre auto-mejora segura

| Paper | arXiv | Hallazgo clave |
|---|---|---|
| MARS (metacognitive reflection) | 2601.11974 (ene 2026) | Single-recurrence cycle elimina loops multi-turn costosos; +SOTA en 6 benchmarks [F8] |
| Hyperagents (DGM-H) | 2603.19461 (mar 2026) | Meta-level improvements se transfieren cross-domain y se acumulan cross-runs [F2] |
| Recursive Agent Optimization (RAO) | 2605.06639 (may 2026) | Agentes recursivos escalan a tareas que exceden context window via divide-and-conquer [F9] |
| Huxley-Gödel Machine (HGM) | 2510.21614 (oct 2025) | Metaproductivity ≠ performance; HGM estima metaproductivity real para guiar self-modification [F10] |
| Gödel Agent | 2410.04444 (oct 2024) | Primer framework de self-modification sin rutinas predefinidas guiado solo por high-level objectives [F11] |
| WebEvolver | 2504.21024 (abr 2025) | World model co-evolving evita estancamiento en self-improvement; +10% sobre baselines [F12] |

### Loop de auto-mejora productiva (safe pattern 2026)
```
Ejecución → [Logging de trace completo]
 → [Análisis de performance por MARS/Reflexion]
 → [¿Confidence > umbral?] → NO → mantener versión actual
 → SÍ → generar candidato modificado
 → [Sandbox validation]
 → [Eval vs golden set]
 → [¿Mejora ≥1% y no regresión?] → NO → rollback
 → SÍ → deploy candidato
```

---

## T1 · Novedades Q1-Q2 2026 que ALAN debe incorporar

### Claude Managed Agents (beta pública: 9 abr 2026) [F13]
- 3 capacidades nuevas: Outcomes (métricas de éxito configurables), Multi-Agent Orchestration (delegación dinámica), **Dreaming** (research preview)
- **Dreaming**: el agente revisa sesiones anteriores, extrae patrones recurrentes, organiza "recuerdos" para auto-mejora sin retraining
- Runtime gestionado por Anthropic: handoffs automáticos + recuperación de fallos sin intervención humana
- Antes: orquestación multi-agente requería LangChain/LangGraph manualmente

### OpenAI Agents SDK: Sandbox Nativo [F14]
- Ejecución de código en sandbox integrado (manifest de carpetas, filesystem, cloud storage)
- Antes: agentes requerían infraestructura externa para ejecución segura
- Relevante para ALAN: patrón de aislamiento por stage puede implementarse así

### Google ADK 2.0 Alpha (marzo 2026) [F15]
- **Protocol A2A (Agent-to-Agent)**: comunicación cross-framework entre agentes de distintos SDKs
- Flujos de trabajo basados en grafos integrados en el kit (antes requería orquestador externo)
- Implicación: ALAN podría eventualmente interoperar con agentes en otros frameworks

### RAO: Recursive Agent Optimization (mayo 2026) [F9]
- Agentes recursivos que se auto-delegan sub-tareas superan sistemas single-agent en:
 - Escalabilidad: manejan tareas que exceden context window
 - Generalización: resuelven tareas más difíciles que las de training
 - Eficiencia: menor wall-clock time que sistemas single-agent
- Paper: arXiv 2605.06639

**Si te llevas UNA cosa**: El patrón Orchestrator-as-Builder con Claude SDK Task tool es el punto de partida óptimo para ALAN v2.0 en 2026. La auto-mejora estilo HyperAgents/Dreaming es el horizonte a 6-12 meses cuando el corpus de invocaciones sea suficiente.
