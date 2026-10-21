# 03 · Claude Code · configuración completa, hooks, sub-agents

> *Las 28 categorías de hooks, scopes de settings, 6 permission modes, sub-agents (built-in y custom), common workflows.*

## Fuentes

- [F1] Claude Code Overview · https://code.claude.com/docs/en/overview
- [F2] Settings reference · https://code.claude.com/docs/en/settings
- [F3] Hooks reference · https://code.claude.com/docs/en/hooks
- [F4] Sub-agents · https://code.claude.com/docs/en/sub-agents
- [F5] Common workflows · https://code.claude.com/docs/en/common-workflows
- [F6] Best practices · https://code.claude.com/docs/en/best-practices

---

## 1 · Settings · 5 scopes con precedence

`settings.json` tiene **5 scopes con precedence highest → lowest** [F2]:

```
Managed (no se puede override) → /etc/claude-code/managed-settings.json, registry, MDM
 ↓
Command-line args (--flag overrides)
 ↓
Local .claude/settings.local.json (gitignored)
 ↓
Project .claude/settings.json (committed)
 ↓
User ~/.claude/settings.json
```

**Paths managed**:
- macOS: `/Library/Application Support/ClaudeCode/`
- Linux: `/etc/claude-code/`
- Windows: `C:\Program Files\ClaudeCode\` (+ `HKLM\SOFTWARE\Policies\ClaudeCode`)
- WSL hereda Windows con `wslInheritsWindowsSettings: true`

**Shape básico** del settings.json:

```json
{
 "$schema": "https://json.schemastore.org/claude-code-settings.json",
 "permissions": {
 "allow": ["Bash(npm run lint)", "Read(~/.zshrc)"],
 "deny": ["Bash(curl *)", "Read(./.env)"],
 "ask": ["Bash(git push *)"],
 "additionalDirectories": ["../docs/"],
 "defaultMode": "acceptEdits"
 },
 "env": {"CLAUDE_CODE_ENABLE_TELEMETRY": "1"},
 "model": "claude-sonnet-4-6",
 "tui": "fullscreen",
 "autoMemoryEnabled": true
}
```

**Reload behavior**:
- ✅ Sin restart: `permissions`, `hooks`, `apiKeyHelper`, `env`, `language`
- ❌ Require restart: `model`, `outputStyle`

**Permission rules MERGE across scopes** (a diferencia de otros settings que override): deny de cualquier scope bloquea; allow/ask acumulan [F2].

## 2 · Los 6 permission modes [F2]

Mode | Behavior
---|---
`default` | Prompts for all tool use
`acceptEdits` | Auto-approves edits, prompts bash/webfetch
`plan` | Shows plan before execution
`auto` | Classifier blocks risky (NO settable en project/local desde v2.1.142)
`dontAsk` | Approves allowed rules silently
`bypassPermissions` | Skip all (emergency, requires confirm)

**Regla de seguridad**: `auto` no puede setearse en project/local settings desde v2.1.142, para evitar que repos enableen el classifier mode sin consentimiento explícito [F2].

## 3 · Permission rule syntax [F2]

Format: `Tool` o `Tool(specifier)`. Evaluación: Deny → Ask → Allow, first match wins.

```
Bash — all bash
Bash(npm run *) — wildcards npm run
Read(./.env) — specific file
Edit(./.config/*.json) — pattern
WebFetch(domain:example.com)
MCP(memory) — server completo
MCP(github:create-pr) — tool específica
Agent(code-reviewer)
Skill(commit) — exact skill
Skill(review-pr *) — prefix
```

## 4 · Hooks · los 28 eventos disponibles [F3]

### 4.1 · Mapa completo por categoría

**Session-level**:
- `SessionStart` — startup/resume/clear/compact. Inject inicial context. Non-blocking.
- `Setup` — solo con `claude --init-only`/`--maintenance`. Non-blocking.
- `SessionEnd` — clear/resume/logout/etc. Non-blocking.

**Per-turn**:
- `UserPromptSubmit` — antes de procesar prompt. **Timeout 30s** (vs 600s default). Bloqueante.
- `UserPromptExpansion` — cuando slash command expande. Bloqueante.
- `Stop` — Claude termina respuesta. Bloqueante.
- `StopFailure` — API error (rate_limit, auth, billing, etc.). Non-blocking.

**Agentic loop**:
- `PreToolUse` — antes de tool call. Matcher con `if: "Bash(rm *)"` permite narrower match. Bloqueante con `permissionDecision: deny`.
- `PostToolUse` — después tool call exitoso. Bloqueante con `decision: block`.
- `PostToolUseFailure` — después tool call falló. Non-blocking.
- `PostToolBatch` — después batch parallel calls. Bloqueante.
- `PermissionRequest` — cuando dialog appears. Bloqueante con `decision.behavior: deny`.
- `PermissionDenied` — auto-mode denegó. Non-blocking, puede retornar `retry: true`.

**File/config**:
- `FileChanged` — watch disk changes. Non-blocking. Access a `CLAUDE_ENV_FILE`.
- `ConfigChange` — settings file changes. Bloqueante (excepto policy_settings).
- `CwdChanged` — directory change. Non-blocking.
- `InstructionsLoaded` — CLAUDE.md/.claude/rules cargados. Non-blocking. Para audit logging.

**Notification/context**:
- `Notification` — permission_prompt/idle_prompt/auth_success/elicitation_*. Non-blocking.
- `SubagentStart` — subagent spawned. Non-blocking, puede inject context.
- `SubagentStop` — subagent finishes. Bloqueante.
- `TeammateIdle` — agent team teammate va a idle. Bloqueante.
- `TaskCreated` — TaskCreate tool. Bloqueante.
- `TaskCompleted` — task marcada complete. Bloqueante.

**Compaction**:
- `PreCompact` — manual/auto compaction. Bloqueante.
- `PostCompact` — después de compaction. Non-blocking.

**Worktrees**:
- `WorktreeCreate` — `--worktree` o `isolation: "worktree"`. Any non-zero exit falla.
- `WorktreeRemove` — Non-blocking.

**MCP elicitation**:
- `Elicitation` — MCP server pide input. Bloqueante con `action: decline`.
- `ElicitationResult` — después de user response. Bloqueante.

### 4.2 · Input/output JSON estándar [F3]

**Input fields comunes**:
```json
{
 "session_id": "abc123",
 "transcript_path": "/path/transcript.jsonl",
 "cwd": "/current/dir",
 "hook_event_name": "EventName",
 "permission_mode": "default|plan|acceptEdits|auto|dontAsk|bypassPermissions",
 "effort": {"level": "low|medium|high|xhigh|max"},
 "agent_id": "uuid-when-in-subagent",
 "agent_type": "name-when-applicable"
}
```

**Output fields comunes**:
```json
{
 "continue": true,
 "stopReason": "optional",
 "suppressOutput": false,
 "systemMessage": "warning to user",
 "terminalSequence": "...",
 "additionalContext": "text to inject",
 "hookSpecificOutput": {"hookEventName": "X"}
}
```

### 4.3 · Los 4 patrones de decision control

Pattern | Used by | Values
---|---|---
Top-level `decision: block` | UserPromptSubmit, Post*, Stop, ConfigChange, PreCompact | "block"
`hookSpecificOutput.permissionDecision` | PreToolUse | allow/deny/ask/defer
`hookSpecificOutput.decision.behavior` | PermissionRequest | allow/deny
`hookSpecificOutput.action` | Elicitation/ElicitationResult | accept/decline/cancel

### 4.4 · Exit codes [F3]

- **0**: success. JSON stdout procesado. Non-JSON → debug log only (excepto UserPromptSubmit/UserPromptExpansion/SessionStart donde stdout text se convierte en context).
- **2**: blocking error. stderr fed back a Claude. JSON ignorado. Behavior varía por evento.
- **Otros non-zero**: non-blocking. stderr solo con `--verbose`.

### 4.5 · Patrones canónicos de uso

1. **Validate + block**: PreToolUse + `permissionDecision: deny` para tools peligrosas (`Bash(rm *)`).
2. **Lint after edit**: PostToolUse matcher `Edit|Write` + run ESLint/black/prettier.
3. **Inject startup context**: SessionStart + return `additionalContext` con state del repo (git branch, recent commits).
4. **Audit trail**: PostToolUse non-blocking → write to audit log.
5. **Reactive env**: FileChanged matcher `.envrc|.env` → reload env vars.

### 4.6 · Security considerations [F3]

10 rules canónicas:
1. **Path traversal**: usar `${CLAUDE_PROJECT_DIR}`, `${CLAUDE_PLUGIN_ROOT}` placeholders
2. **Env var injection**: solo `allowedEnvVars` en HTTP hooks; unlisted → empty
3. **Command injection**: exec form (args array) para user input, no shell form
4. **Managed policies override**: `allowManagedHooksOnly` bloquea user/project/plugin
5. **MCP server trust**: tool hooks requieren pre-configured + already-connected
6. **JSON injection prevention**: output strings cap 10,000 chars; no controlling terminal
7. **Terminal escape allowlist**: solo OSC 0/1/2/9/99/777 + BEL
8. **Tool input modification**: `modifiedInput` PreToolUse solo afecta current call
9. **Timeout protection**: 600s default; UserPromptSubmit 30s
10. **bypassPermissions** mode SIGUE ejecutando hooks; pueden override

## 5 · Sub-agents en Claude Code [F4]

### 5.1 · Para qué sirven

> *"Subagents are specialized AI assistants that handle specific types of tasks. Use one when a side task would flood your main conversation with search results, logs, or file contents you won't reference again: the subagent does that work in its own context and returns only the summary."* [F4]

5 beneficios:
- **Preserve context** del main session
- **Enforce constraints** limitando tools disponibles
- **Reuse** user-level subagents across projects
- **Specialize** focused system prompts para domains
- **Control costs** routeando a modelos baratos (Haiku)

### 5.2 · Built-in subagents

- **Explore** — read-only, optimizado para codebase exploration. Skip CLAUDE.md y git status para contexto pequeño.
- **Plan** — planning específico, también skip CLAUDE.md.
- **general-purpose** — balance, full access, carga CLAUDE.md y git status.

### 5.3 · Custom subagent definition

Archivo: `.claude/agents/<name>.md` (project) o `~/.claude/agents/<name>.md` (user).

Ejemplo canónico [F4]:
```markdown
---
name: security-reviewer
description: Reviews code for security vulnerabilities
tools: Read, Grep, Glob, Bash
model: opus
---
You are a senior security engineer. Review code for:
- Injection vulnerabilities (SQL, XSS, command injection)
- Authentication and authorization flaws
- Secrets or credentials in code
- Insecure data handling

Provide specific line references and suggested fixes.
```

**Frontmatter fields**:
- `name` — display name
- `description` — KEY para auto-delegation (Claude decide leyendo esto)
- `tools` — subset permitido
- `model` — override (opus/sonnet/haiku) para cost control
- `skills` — preload skills
- `mcp_servers` — MCP disponibles

### 5.4 · Invocation patterns

1. **Auto-delegated** — Claude lee `description`, decide invocar cuando matchea contexto
2. **Explicit** — *"Use the security-reviewer subagent to..."*
3. **From skill con `context: fork`** — skill content se vuelve subagent task

### 5.5 · Context loading by type

Type | CLAUDE.md | git status | Preloaded skills
---|---|---|---
Explore | No | No | Sí (frontmatter)
Plan | No | No | Sí
general-purpose | Sí | Sí | Sí
Custom | Sí (default) | Sí | Sí

### 5.6 · Parallel execution + tracking

Multiple subagents pueden lanzarse paralelos desde Agent tool. Stagger recomendado para rate limits. Mensajes desde subagent contexto traen `parent_tool_use_id` field para tracking [F4].

### 5.7 · Patrón cost-savings con Haiku subagent [F4][F6]

Routear research/exploration → Haiku subagent (cheap). Solo summary final llega a main session (con Opus si configurado así). Preserva context window Y reduce costos.

```markdown
---
name: explorer-haiku
description: Cheap exploration of large codebases
tools: Read, Glob, Grep
model: haiku
---
Explore the codebase and return ONLY:
1. File list relevant to the query
2. Key patterns observed
3. Specific line refs for follow-up
```

### 5.8 · Anti-patterns sub-agents

❌ Description sin keywords claros → Claude no sabe cuándo delegar
❌ Tools list demasiado amplia → mismo context cost que main agent (no aprovecha)
❌ Subagent para tarea trivial (<3 file reads) → overhead supera el savings
❌ Subagent que escribe a filesystem sin permiso explícito (rompe sandbox de exploración)

## 6 · Common workflows (desde docs canónicas) [F5]

### 6.1 · Resume conversations
`claude --continue` resume most recent en current dir. `claude --resume` lista picker. `/resume` desde dentro. Sesiones nombradas con `/rename oauth-migration` se vuelven branches.

### 6.2 · Parallel sessions con worktrees
```bash
claude --worktree feature-auth # terminal 1
claude --worktree bugfix-cache # terminal 2, isolated checkout
```
Para monitor multi-session desde una pantalla: background agents (`/agent-view`).

### 6.3 · Plan mode antes de editar
```bash
claude --permission-mode plan
```
O `Shift+Tab` mid-session. Claude lee files y propone plan SIN editar hasta que apruebas.

### 6.4 · Delegate research to sub-agents
```text
use a subagent to investigate how our auth system handles token refresh
```
> *"The subagent reads files in its own context window and reports a summary."*

### 6.5 · Pipe Claude into scripts
```bash
git log --oneline -20 | claude -p "summarize these recent commits"
tail -200 app.log | claude -p "Slack me if you see any anomalies"
git diff main --name-only | claude -p "review these changed files for security"
```

### 6.6 · @-mentions
```text
Explain the logic in @src/utils/auth.js # file content full
What's the structure of @src/components? # dir listing
Show me data from @github:repos/owner/repo/issues # MCP resource
```
@ file references **add CLAUDE.md from file's dir and parent dirs to context** automáticamente.

### 6.7 · Scheduled tasks comparison

Option | Where runs | Best for
---|---|---
Routines | Anthropic infra | Run even when computer off, GitHub/API triggers
Desktop scheduled tasks | Your machine | Access local files, uncommitted changes
GitHub Actions | CI pipeline | Repo events, cron config con workflow
`/loop` | Current CLI session | Quick polling while open

**Tip crítico autónomo**: *"Be explicit about what success looks like and what to do with results. The task runs autonomously, so it can't ask clarifying questions."* [F5]

## 7 · Env vars críticas [F2]

Var | Purpose
---|---
`CLAUDE_CODE_ENABLE_TELEMETRY` | Enable telemetry (1/0)
`CLAUDE_CODE_DISABLE_THINKING` | Disable extended thinking
`CLAUDE_CODE_DISABLE_AUTO_MEMORY` | Disable auto memory
`CLAUDE_CODE_NO_FLICKER` | Fullscreen alt-screen renderer
`CLAUDE_CODE_SKIP_PROMPT_HISTORY` | Don't persist transcripts
`DISABLE_AUTOUPDATER` | Disable auto-updates
`ANTHROPIC_MODEL` | Model override one session
`CLAUDE_CODE_USE_POWERSHELL_TOOL` | PowerShell tool on Windows
`CLAUDE_CODE_DISABLE_AGENT_VIEW` | Disable background agents
`CLAUDE_CODE_ADDITIONAL_DIRECTORIES_CLAUDE_MD` | Load CLAUDE.md from `--add-dir`

## 8 · Sandbox config (macOS/Linux/WSL2) [F2]

```json
"sandbox": {
 "enabled": true,
 "failIfUnavailable": true,
 "filesystem": {
 "allowWrite": ["/tmp/build", "~/.kube"],
 "denyRead": ["~/.aws/credentials"]
 },
 "network": {"allowedDomains": ["github.com", "*.npmjs.org"]}
}
```

## 9 · Worktrees config [F2]

```json
"worktree": {
 "baseRef": "head", // fresh|head
 "sparsePaths": ["packages/my-app"],
 "symlinkDirectories": ["node_modules", ".cache"],
 "bgIsolation": "worktree" // worktree|none
}
```

---

## Si te llevas UNA cosa

**Sub-agents existen para preservar tu context window, no para "hacer las cosas más rápido"**. Úsalos cuando una tarea side fillearía tu conversación con file reads o logs. Si la tarea son <3 file reads, hazla inline. Si son 30+ file reads y solo te interesa el summary, lanza subagent. La regla de oro es: ¿el output que necesitas cabe en un párrafo? → subagent.
