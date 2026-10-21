# 07 · Memory, state y prompt caching

> *3 capas de memory en agentes Claude (CLAUDE.md, auto-memory, Memory MCP knowledge graph), prompt caching como memory implícita (pricing, breakpoints, lifecycle).*

## Fuentes

- [F1] Prompt caching docs · https://platform.claude.com/docs/en/build-with-claude/prompt-caching
- [F2] Memory MCP server · https://github.com/modelcontextprotocol/servers (memory)
- [F3] Best practices · context · https://code.claude.com/docs/en/best-practices
- [F4] Anthropic Context Engineering · https://www.anthropic.com/engineering/context-engineering
- [F5] Settings · auto-memory · https://code.claude.com/docs/en/settings

---

## 1 · Las 3 capas de memory en agentes Claude

### 1.1 · Capa 1 · CLAUDE.md persistent instructions [F3]

Persistent **across sessions**. Loaded al inicio de cada conversación.

- `~/.claude/CLAUDE.md` — home, todas las sesiones
- `./CLAUDE.md` — project, committed a git, team-wide
- `./CLAUDE.local.md` — project personal, gitignored
- Parent + child dirs (monorepo)

Ver categoría 04 para qué incluir/excluir.

### 1.2 · Capa 2 · Auto-memory [F5]

Learnings entre sesiones que Claude construye **sin que el user escriba**.

- Toggle: `autoMemoryEnabled: true` en settings.json
- Custom location: `autoMemoryDirectory: "~/my-memory-dir"`
- Control via `/memory` slash command
- Excludes: `claudeMdExcludes: ["**/vendor/**/CLAUDE.md"]` glob patterns
- Cleanup: `cleanupPeriodDays: 30` (min 1)

Ejemplo típico de qué guarda: build commands, debugging insights, project-specific quirks descubiertos durante uso.

### 1.3 · Capa 3 · Memory MCP knowledge graph [F2]

`@modelcontextprotocol/server-memory` — persistencia relational entre sesiones.

API exposed:
- `add_observations` — add facts to entities
- `create_entities` — create new entities
- `create_relations` — link entities
- `delete_entities` / `delete_observations` / `delete_relations`
- `search_nodes` — query
- `read_graph` — full dump
- `open_nodes` — fetch specific

Cuándo usar vs filesystem:
- **Filesystem (CLAUDE.md/auto-memory)**: flat data, instructions, project knowledge
- **Memory MCP**: relational data (X conoce a Y, X trabajó en proyecto Z), entity-centric queries

## 2 · Prompt caching como memory implícita

### 2.1 · Definición [F1]

> *"Prompt caching optimizes your API usage by allowing resuming from specific prefixes in your prompts. This significantly reduces processing time and costs for repetitive tasks or prompts with consistent elements."*

Es memory **implícita** del PROVEEDOR (Anthropic) sobre tu request, no de Claude sobre el usuario. Pero efectivamente: si tienes un system prompt grande estable + user message variable, el sistema **recuerda** el system prompt entre requests y solo procesa el delta nuevo.

### 2.2 · Dos modos de cache control [F1]

**Modo 1 · Automatic (recomendado para multi-turn)**:
```json
{
 "model": "claude-opus-4-7",
 "max_tokens": 1024,
 "cache_control": {"type": "ephemeral"},
 "system": "You are an AI assistant...",
 "messages": [{"role": "user", "content": "Your question here"}]
}
```

El sistema mueve el breakpoint automáticamente conforme crece la conversación.

**Modo 2 · Explicit breakpoints (fine-grained)**:
```json
{
 "system": [
 {"type": "text", "text": "Your system prompt", "cache_control": {"type": "ephemeral"}}
 ],
 "messages": [
 {"role": "user", "content": "Your message", "cache_control": {"type": "ephemeral"}}
 ]
}
```

**Hasta 4 breakpoints por request** en modo explicit.

### 2.3 · Jerarquía + invalidation [F1]

`tools` → `system` → `messages` (en ese orden).

| Cambio | Invalida |
|---|---|
| Tool definition changes | TODO el cache |
| System prompt changes | system + messages cache |
| Image changes anywhere | messages cache |
| Tool choice changes | messages cache only |

### 2.4 · TTL · 5-min vs 1-hour [F1]

**5-min (default)**:
- No additional cost vs base input
- Auto-refresh sin costo extra cuando cached content se reusa

**1-hour (opcional)**:
```json
{"cache_control": {"type": "ephemeral", "ttl": "1h"}}
```

Multiplier:
- 1h cache write tokens: **2x base input price**
- 5m cache write tokens: **1.25x base input price**
- Cache hit (read) tokens: **0.1x base input price** (90% discount)

### 2.5 · Pricing exacto (Opus 4.7) [F1]

| Token type | $/1M tokens |
|---|---|
| Base input | $5 |
| 5m cache write | $6.25 |
| 1h cache write | $10 |
| **Cache hit/refresh** | **$0.50** |
| Output | $25 |

**Implicación operacional**: si tu system prompt es 5,000 tokens y lo usas 100 veces por día, sin caching pagas 500,000 input tokens/day = $2.50/day. Con caching: 1 write ($0.03) + 99 hits ($0.0247) = **$0.05/day** (98% savings).

### 2.6 · Mínimo cacheable por modelo [F1]

- Opus 4.7, 4.6, 4.5: **4,096 tokens mínimo**
- Sonnet 4.6, 4.5: **1,024 tokens mínimo**
- Haiku 4.5: **4,096 tokens mínimo**

Si tu prompt está bajo este threshold, caching no aplica.

### 2.7 · Lookback window: 20 blocks [F1]

> *"The system checks up to 20 positions backward to find a previous cache write."*

Conversaciones que crecen más de 20 blocks desde el último write necesitan **breakpoints adicionales**. Si tu agente tiene long history, agrega breakpoints intermedios cada ~15 turns.

### 2.8 · Patrón pre-warm con `max_tokens: 0` [F1]

Cargar system prompt al startup, antes de que llegue user request:

```python
# Pre-warm: cargar sistema en cache (cobra solo 1 write 1.25x)
prewarm = client.messages.create(
 model="claude-opus-4-7",
 max_tokens=0,
 system=[
 {
 "type": "text",
 "text": "[5000 tokens system prompt]",
 "cache_control": {"type": "ephemeral"}
 }
 ],
 messages=[{"role": "user", "content": "warmup"}]
)

# Subsequent requests: cache hit (0.1x = 90% off)
response = client.messages.create(
 model="claude-opus-4-7",
 max_tokens=1024,
 system=[
 {
 "type": "text",
 "text": "[mismo system prompt]",
 "cache_control": {"type": "ephemeral"}
 }
 ],
 messages=[{"role": "user", "content": "Real user question"}]
)
```

Benefit: elimina la latency penalty del first user message.

### 2.9 · Cache breakpoint strategy [F1]

**Regla**: Place breakpoint on the **LAST identical block** across requests.

- System prompt static + user message variable → marcar **system**
- Tools static + system y messages variables → marcar **tools** y **system**

### 2.10 · Tracking de cache performance [F1]

Response usage block:
```json
{
 "usage": {
 "cache_creation_input_tokens": 5000,
 "cache_read_input_tokens": 100000,
 "input_tokens": 50,
 "output_tokens": 503
 }
}
```

Total input = `cache_read + cache_creation + input`. Calcula cache hit rate como `cache_read / total_input`.

### 2.11 · Disponibilidad por plataforma [F1]

✅ Disponible: Claude API, Claude Platform on AWS, Vertex AI (org-level isolation), Microsoft Foundry (beta)
❌ NO disponible: Bedrock (docs separadas)
✅ ZDR (Zero Data Retention) eligible: Sí

## 3 · Context engineering · gestión activa del context window [F3][F4]

### 3.1 · La constraint base [F3]

> *"Most best practices are based on one constraint: Claude's context window fills up fast, and performance degrades as it fills."*

> *"LLM performance degrades as context fills. When the context window is getting full, Claude may start 'forgetting' earlier instructions or making more mistakes. The context window is the most important resource to manage."*

### 3.2 · Manage aggressively · 5 técnicas [F3]

1. **`/clear` entre tasks irrelevantes** — reset context window entirely
2. **`/compact <instructions>`** — `/compact Focus on the API changes`
3. **`Esc + Esc` o `/rewind`** — restore conversation/code/both, o summarize-from-here
4. **Customize compaction en CLAUDE.md** — `"When compacting, always preserve the full list of modified files and any test commands"`
5. **`/btw` para quick questions** — answer en dismissible overlay, no entra a history

### 3.3 · Auto-compaction behavior [F3]

> *"When auto compaction triggers, Claude summarizes what matters most, including code patterns, file states, and key decisions."*

Re-attached skills después de compaction: first 5,000 tokens cada uno, combined 25,000 tokens budget, fill desde el más reciente.

### 3.4 · Track context con status line [F3]

Custom status line muestra context usage continuamente. Setup:

```json
{
 "statusLine": {
 "type": "command",
 "command": "~/.claude/statusline.sh"
 }
}
```

## 4 · Cuándo usar cada capa de memory

Decision tree práctico:

```
¿Es info que aplica a TODOS los projects?
 Sí → ~/.claude/CLAUDE.md
 No → ¿Es info project-specific compartida con team?
 Sí → ./CLAUDE.md (commit)
 No → ¿Es info personal sobre este project?
 Sí → ./CLAUDE.local.md (gitignore)
 No → ¿Es info que Claude debe descubrir durante uso?
 Sí → auto-memory (autoMemoryEnabled: true)
 No → ¿Es info relational/entity-centric (X conoce a Y)?
 Sí → Memory MCP knowledge graph
 No → reconsider si es realmente memory o más bien prompt content
```

## 5 · Patrones combinados

### 5.1 · Agente RAG con triple capa
- **CLAUDE.md**: roles, conventions, output format
- **Memory MCP**: user-specific entities, relationships
- **Prompt caching**: system prompt (CLAUDE.md content) cached → cada query del user es delta cheap

### 5.2 · Long-running agent
- **CLAUDE.md**: identity + invariants
- **Auto-memory**: build_commands, debugging_insights descubiertos
- **Memory MCP**: state de tareas en curso, hand-offs entre sesiones

### 5.3 · Team productivity agent
- **CLAUDE.md project**: team conventions, repo etiquette
- **Memory MCP**: ticket history, PR feedback, code review patterns
- **Prompt caching**: system + memory cargados con cache_control para responses rápidos

## 6 · Anti-patterns memory

❌ Pegar todo el knowledge en CLAUDE.md → bloat causes Claude to ignore rules
❌ Auto-memory enabled en projects sensibles → puede persistir info confidencial
❌ Memory MCP knowledge graph para flat data → overhead injustificado
❌ Prompt caching sin medir hit rate → puede que no estés ahorrando nada
❌ Cache TTL 1h para system prompts que cambian frequently → 2x cost wasted
❌ No usar pre-warm cuando user-facing latency importa → primer message lento

---

## Si te llevas UNA cosa

**Prompt caching es la palanca de mayor leverage que tienes para reducir costo de agentes con system prompts grandes.** Un agente con 5,000 tokens de system prompt usado 100 veces/día baja de $2.50/day a $0.05/day (98% savings) sólo activando `cache_control`. Es el ROI #1 de cualquier agente en producción.
