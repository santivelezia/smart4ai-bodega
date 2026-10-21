# 99 · Fuentes y bibliografía

> Todas las fuentes consultadas, con URL + fecha de consulta + tipo. Para reproducir, ejecutar `una investigación Smart4AI` con el brief Notion `(id interno)`.

Fecha consulta general: **2026-05-19**.

---

## A · Docs oficiales Anthropic / Claude

### A1 · Claude Code (code.claude.com)

| URL | Categorías que lo citan |
|---|---|
| https://code.claude.com/docs/en/overview | 02, 03 |
| https://code.claude.com/docs/en/settings | 03 |
| https://code.claude.com/docs/en/hooks | 03 |
| https://code.claude.com/docs/en/sub-agents | 02, 03, 06 |
| https://code.claude.com/docs/en/common-workflows | 03 |
| https://code.claude.com/docs/en/best-practices | 02, 03, 04, 08, 09 |
| https://code.claude.com/docs/en/skills | 04, 06, 09 |
| https://code.claude.com/docs/en/mcp | 06 |
| https://code.claude.com/docs/en/agent-sdk/overview | 02, 05, 06 |

### A2 · Claude Platform (platform.claude.com)

| URL | Categorías |
|---|---|
| https://platform.claude.com/docs/en/build-with-claude/prompt-caching | 07, 08 |
| https://platform.claude.com/docs/en/test-and-evaluate/define-success | 04, 08 |

### A3 · Anthropic Engineering (www.anthropic.com/engineering/)

| URL | Categoría |
|---|---|
| https://www.anthropic.com/engineering/building-effective-agents | 02, 03, 09 |
| https://www.anthropic.com/engineering/multi-agent-research-system | 02 |
| https://www.anthropic.com/engineering/context-engineering | 07, 08 |

### A4 · Anthropic Research (www.anthropic.com/research/)

| URL | Categoría |
|---|---|
| https://www.anthropic.com/research | 09 |
| https://www.anthropic.com/research/teaching-claude-why (2026-05-08) | 09 |
| https://www.anthropic.com/research/automated-alignment-researchers (2026-04-14) | 09 |
| https://www.anthropic.com/research/project-vend-2 (2025-12-18) | 09 |
| https://www.anthropic.com/features/project-deal (2026-04-24) | 09 |

---

## B · Standards y catálogos

| URL | Tipo | Categoría |
|---|---|---|
| https://modelcontextprotocol.io/ | Spec oficial MCP | 06 |
| https://github.com/modelcontextprotocol/servers | Catálogo MCP servers | 06, 07 |
| https://agentskills.io | Agent Skills open standard | 06 |
| https://claude.ai/directory | Anthropic Directory de connectors MCP | 06 |
| https://github.com/anthropics/claude-code | Repo oficial Claude Code | 03 |
| https://github.com/anthropics/claude-agent-sdk-demos | Demos canónicos SDK | 05 |
| https://github.com/anthropics/claude-agent-sdk-typescript | SDK TS source | 05 |
| https://github.com/anthropics/claude-agent-sdk-python | SDK Py source | 05 |

---

## C · Papers académicos (Hugging Face)

Búsqueda: `LLM agents multi-agent planning reasoning tool use 2025 2026`. 120 papers matched. Top picks consultados:

### C1 · Surveys

| Paper | Fecha | URL | Categoría |
|---|---|---|---|
| From LLM Reasoning to Autonomous AI Agents · A Comprehensive Review | 2025-04-28 | https://hf.co/papers/2504.19678 | 09 |
| PlanGenLLMs: A Modern Survey of LLM Planning Capabilities | 2025-02-16 | https://hf.co/papers/2502.11221 | 09 |
| Large Language Model based Multi-Agents: A Survey of Progress and Challenges | 2024-01-21 | https://hf.co/papers/2402.01680 | 09 |

### C2 · Architectures

| Paper | Fecha | URL | Categoría |
|---|---|---|---|
| MALT: Improving Reasoning with Multi-Agent LLM Training | 2024-12-02 | https://hf.co/papers/2412.01928 | 09 |
| Cooperative Strategic Planning (CoPlanner) | 2024-10-25 | https://hf.co/papers/2410.20007 | 09 |
| Large Reasoning Models in Agent Scenarios (LaRMA) | 2025-03-14 | https://hf.co/papers/2503.11074 | 09 |
| AgentLite: Lightweight Library for Task-Oriented LLM Agents | 2024-02-23 | https://hf.co/papers/2402.15538 | 09 |
| Towards Robust Multi-Modal Reasoning via Model Selection (M3) | 2023-10-12 | https://hf.co/papers/2310.08446 | — |

### C3 · Benchmarks

| Paper | Fecha | URL | Categoría |
|---|---|---|---|
| FutureX: Advanced Live Benchmark for LLM Agents in Future Prediction | 2025-08-16 | https://hf.co/papers/2508.11987 | 09 |
| ThinkGeo: Tool-Augmented Agents for Remote Sensing | 2026-04-02 | https://hf.co/papers/2505.23752 | 09 |
| FlowBench: Workflow-Guided Planning | 2024-06-21 | https://hf.co/papers/2406.14884 | 09 |
| PlanBench (foundational) | 2022-06-21 | https://hf.co/papers/2206.10498 | 09 |
| MIRAI: LLM Agents for Event Forecasting | 2024-07-01 | https://hf.co/papers/2407.01231 | — |

### C4 · Safety / alignment

| Paper | Fecha | URL | Categoría |
|---|---|---|---|
| TrustAgent: Safe and Trustworthy LLM-based Agents | 2024-10-03 | https://hf.co/papers/2402.01586 | 09 |
| On the Planning Abilities of LLMs — Critical Investigation | 2023-05-25 | https://hf.co/papers/2305.15771 | 09 |

---

## D · Recursos internos Smart4AI

| Recurso | Path |
|---|---|
| CLAUDE.md global del programa Claude For Devs | el CLAUDE.md del proyecto (v1.6, 2026-05-18) |
| Brief de investigación Notion | (brief interno) |
| Router multi-modelo (interno) | — |
| Agente Investigador Profundo (este agente) | |
| Run artifacts | |

---

## E · Notas metodológicas

- **Fuentes excluidas por configuración del run**: Perplexity (parámetro `fuentes_excluidas=perplexity`)
- **Gemini Deep Research**: skipped en este run para optimizar tiempo wall-clock; reservado para refresh trimestral si se detectan gaps
- **NotebookLM**: no usado (no había Notebook previo del tema)
- **Idioma de citas**: original (mayoría inglés), narrativa en español Colombia
- **Total raw files generados**: 25 (en `.raw/` del run)
- **Total claims atómicos extraídos**: 100 (en `claims.jsonl`)
- **Total validations marcadas**: 15 (en `validations.jsonl`)
- **Total categorías editoriales**: 8
- **Total líneas output**: ~2,360 (cumple cap <800 por archivo)

## F · Reproducibilidad

Para regenerar esta investigación:

```text
Lee agent.md y ejecútalo con
 tema="Cómo construir agentes con Claude al máximo nivel · metodología completa 2026"
 brief=(brief interno)
 fuentes_excluidas=perplexity
```

Run ID: `inv_agentes-claude-2026_2026-05-19-0218`.

Costo real API: **$0.00 USD** (todo via plan Max + MCPs free).
Tiempo wall-clock: **~45 min**.
