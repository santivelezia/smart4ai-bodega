# 05 · Claude Agent SDK · standalone en producción

> *Decisión SDK vs CLI vs Client SDK vs Managed Agents, setup Python/TypeScript, multi-provider auth, sessions, cambio comercial June 2026.*

## Fuentes

- [F1] Agent SDK Overview · https://code.claude.com/docs/en/agent-sdk/overview
- [F2] Claude Code Overview · https://code.claude.com/docs/en/overview

---

## 1 · Decisión Agent SDK vs alternativas [F1]

### 1.1 · vs Claude Code CLI

| Use case | Best choice |
|---|---|
| Interactive development | CLI |
| CI/CD pipelines | **SDK** |
| Custom applications | **SDK** |
| One-off tasks | CLI |
| Production automation | **SDK** |

> *"Many teams use both: CLI for daily development, SDK for production. Workflows translate directly between them."* [F1]

### 1.2 · vs Anthropic Client SDK

- **Client SDK**: tú implementas el tool loop manualmente
- **Agent SDK**: Claude maneja el loop autonómicamente

```python
# Client SDK: TÚ implementas el loop
response = client.messages.create(...)
while response.stop_reason == "tool_use":
 result = your_tool_executor(response.tool_use)
 response = client.messages.create(tool_result=result, **params)

# Agent SDK: Claude maneja tools autonomously
async for message in query(prompt="Fix the bug in auth.py"):
 print(message)
```

### 1.3 · vs Managed Agents (hosted REST API)

| Dimensión | Agent SDK | Managed Agents |
|---|---|---|
| Runs in | Tu proceso, tu infra | Anthropic-managed infra |
| Interface | Python o TypeScript library | REST API |
| Files | Tu infra | Managed sandbox por sesión |
| Session state | JSONL en tu FS | Anthropic-hosted event log |
| Custom tools | In-process Python/TS functions | Claude triggers, tú ejecutas |
| Best for | Local prototyping, agents en tu FS | Production sin operar sandbox, long-running async |

**Path típico** [F1]: prototipar con Agent SDK localmente → mover a Managed Agents para producción.

## 2 · Cambio comercial CRÍTICO · Junio 15, 2026 [F1]

> *"Starting June 15, 2026, Agent SDK and `claude -p` usage on subscription plans will draw from a new monthly Agent SDK credit, separate from your interactive usage limits."*

Implicaciones para Smart4AI:
- Planning de Agent SDK usage debe presupuestarse separado
- Plan Max actual cubre interactive usage, no Agent SDK production
- Documento que Anthropic publica con detalles: support.claude.com/en/articles/15036540

## 3 · Restricción legal third-party login [F1]

> *"Unless previously approved, Anthropic does not allow third party developers to offer claude.ai login or rate limits for their products, including agents built on the Claude Agent SDK. Please use the API key authentication methods."*

Para Smart4AI: agentes que distribuyamos NO pueden ofrecer claude.ai login. Deben requerir que el usuario final tenga su propio ANTHROPIC_API_KEY (alineado con filosofía Smart4AI: "muestra el patrón, alumno paga su infra").

## 4 · Setup mínimo [F1]

### 4.1 · Instalación

**TypeScript** (bundle Claude Code binary opcional):
```bash
npm install @anthropic-ai/claude-agent-sdk
```

**Python**:
```bash
pip install claude-agent-sdk
```

### 4.2 · API key

```bash
export ANTHROPIC_API_KEY=your-api-key
```

⚠️ Nota: con plan Max, deja que Claude Code use tu sesión; no configures una API key directa (se cobraría aparte). Ver categoría 09 anti-patterns.

### 4.3 · Auth alternativos (multi-provider)

| Provider | Env var | Required adicional |
|---|---|---|
| Amazon Bedrock | `CLAUDE_CODE_USE_BEDROCK=1` | AWS credentials |
| Claude Platform on AWS | `CLAUDE_CODE_USE_ANTHROPIC_AWS=1` | `ANTHROPIC_AWS_WORKSPACE_ID` + AWS creds |
| Google Vertex AI | `CLAUDE_CODE_USE_VERTEX=1` | Google Cloud creds |
| Microsoft Azure | `CLAUDE_CODE_USE_FOUNDRY=1` | Azure creds |

## 5 · API surface esencial [F1]

### 5.1 · Hola mundo Python

```python
import asyncio
from claude_agent_sdk import query, ClaudeAgentOptions

async def main():
 async for message in query(
 prompt="Find and fix the bug in auth.py",
 options=ClaudeAgentOptions(allowed_tools=["Read", "Edit", "Bash"]),
 ):
 print(message)

asyncio.run(main())
```

### 5.2 · Hola mundo TypeScript

```typescript
import { query } from "@anthropic-ai/claude-agent-sdk";

for await (const message of query({
 prompt: "Find and fix the bug in auth.ts",
 options: { allowedTools: ["Read", "Edit", "Bash"] }
})) {
 console.log(message);
}
```

## 6 · Built-in tools del SDK [F1]

| Tool | Función |
|---|---|
| Read | Read any file in working dir |
| Write | Create new files |
| Edit | Make precise edits to existing files |
| Bash | Run terminal commands, scripts, git |
| Monitor | Watch background script, react to each output line |
| Glob | Find files by pattern (`**/*.ts`) |
| Grep | Search file contents with regex |
| WebSearch | Search the web for current info |
| WebFetch | Fetch and parse web page content |
| AskUserQuestion | Ask user multiple-choice questions |

Disponibles sin implementar tool execution.

## 7 · Hooks en Agent SDK [F1]

Eventos disponibles: `PreToolUse`, `PostToolUse`, `Stop`, `SessionStart`, `SessionEnd`, `UserPromptSubmit`, etc.

Ejemplo logging Python:
```python
import asyncio
from datetime import datetime
from claude_agent_sdk import query, ClaudeAgentOptions, HookMatcher

async def log_file_change(input_data, tool_use_id, context):
 file_path = input_data.get("tool_input", {}).get("file_path", "unknown")
 with open("./audit.log", "a") as f:
 f.write(f"{datetime.now()}: modified {file_path}\n")
 return {}

async def main():
 async for message in query(
 prompt="Refactor utils.py to improve readability",
 options=ClaudeAgentOptions(
 permission_mode="acceptEdits",
 hooks={
 "PostToolUse": [
 HookMatcher(matcher="Edit|Write", hooks=[log_file_change])
 ]
 },
 ),
 ):
 if hasattr(message, "result"):
 print(message.result)

asyncio.run(main())
```

## 8 · Subagents en Agent SDK [F1]

```python
agents={
 "code-reviewer": AgentDefinition(
 description="Expert code reviewer for quality and security reviews.",
 prompt="Analyze code quality and suggest improvements.",
 tools=["Read", "Glob", "Grep"],
 )
}
```

Messages desde subagent contexto traen `parent_tool_use_id` field para tracking.

## 9 · MCP servers en Agent SDK [F1]

```python
options=ClaudeAgentOptions(
 mcp_servers={
 "playwright": {"command": "npx", "args": ["@playwright/mcp@latest"]}
 }
)
```

Soporta cientos de MCP servers del catálogo. Ver categoría 06.

## 10 · Permission control [F1]

```python
# Read-only agent
options=ClaudeAgentOptions(
 allowed_tools=["Read", "Glob", "Grep"],
)
```

Mismos permission_mode options que Claude Code: `default`, `acceptEdits`, `plan`, `auto`, `dontAsk`, `bypassPermissions`.

## 11 · Sessions multi-turn [F1]

Patrón canónico para mantener context entre llamadas:

```python
from claude_agent_sdk import query, ClaudeAgentOptions, SystemMessage, ResultMessage

async def main():
 session_id = None

 # Primer query: capturar session_id
 async for message in query(
 prompt="Read the authentication module",
 options=ClaudeAgentOptions(allowed_tools=["Read", "Glob"]),
 ):
 if isinstance(message, SystemMessage) and message.subtype == "init":
 session_id = message.data["session_id"]

 # Resume con full context del primer query
 async for message in query(
 prompt="Now find all places that call it", # "it" = auth module
 options=ClaudeAgentOptions(resume=session_id),
 ):
 if isinstance(message, ResultMessage):
 print(message.result)
```

## 12 · Claude Code features expuestos en SDK [F1]

El SDK también soporta filesystem-based configuration de Claude Code. Default loading: `.claude/` en working dir + `~/.claude/`.

| Feature | Location |
|---|---|
| Skills | `.claude/skills/*/SKILL.md` |
| Slash commands | `.claude/commands/*.md` |
| Memory | `CLAUDE.md` o `.claude/CLAUDE.md` |
| Plugins | Programático via `plugins` option |

Restringir cargas con `setting_sources` (Python) o `settingSources` (TypeScript).

## 13 · Branding rules para partners [F1]

Cuando integras Claude en tu producto:

**Allowed**:
- "Claude Agent" (preferred para dropdown menus)
- "Claude" (dentro de menú etiquetado "Agents")
- "{YourAgentName} Powered by Claude"

**NOT permitted**:
- "Claude Code" o "Claude Code Agent"
- Claude Code-branded ASCII art o visual elements

> *"Your product should maintain its own branding and not appear to be Claude Code or any Anthropic product."* [F1]

## 14 · Demos canónicos [F1]

GitHub: https://github.com/anthropics/claude-agent-sdk-demos
- Email assistant
- Research agent
- More

## 15 · Changelogs y reporting

- **TypeScript SDK**: https://github.com/anthropics/claude-agent-sdk-typescript/blob/main/CHANGELOG.md
- **Python SDK**: https://github.com/anthropics/claude-agent-sdk-python/blob/main/CHANGELOG.md

Issues:
- TS: github.com/anthropics/claude-agent-sdk-typescript/issues
- Py: github.com/anthropics/claude-agent-sdk-python/issues

---

## Si te llevas UNA cosa

**Agent SDK es Claude Code como library**. Si tu agente debe correr en producción 24/7, en CI, o como parte de tu app web, usa Agent SDK. Si es algo que invocas tú interactivamente, usa Claude Code CLI. La distinción NO es de capability (son lo mismo bajo el hood); es de runtime: ¿quién invoca y dónde corre?
