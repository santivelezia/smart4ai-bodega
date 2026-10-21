# 06 · MCPs y Skills · ecosistema y construcción

> *MCP (definición, 3 transports, config, permission rules, catálogo, custom MCP). Skills (frontmatter 15 fields, scopes, lifecycle, dynamic context injection, integration con sub-agents).*

## Fuentes

- [F1] MCP en Claude Code · https://code.claude.com/docs/en/mcp
- [F2] Sitio oficial MCP · https://modelcontextprotocol.io/
- [F3] Catálogo MCP servers · https://github.com/modelcontextprotocol/servers
- [F4] Skills · https://code.claude.com/docs/en/skills
- [F5] Agent Skills open standard · https://agentskills.io
- [F6] Sub-agents · https://code.claude.com/docs/en/sub-agents

---

# Parte A · MCPs

## A1 · Definición y propósito [F1]

> *"Claude Code can connect to hundreds of external tools and data sources through the Model Context Protocol (MCP), an open source standard for AI-tool integrations. MCP servers give Claude Code access to your tools, databases, and APIs."*

**Heurística de uso**: connect cuando te encuentras *"copying data into chat from another tool, like an issue tracker or a monitoring dashboard. Once connected, Claude can read and act on that system directly instead of working from what you paste."* [F1]

## A2 · Use cases canónicos [F1]

| Use case | Ejemplo |
|---|---|
| Implement features from issue trackers | "Add the feature described in JIRA issue ENG-4521 and create a PR on GitHub." |
| Analyze monitoring data | "Check Sentry and Statsig to check the usage of the feature described in ENG-4521." |
| Query databases | "Find emails of 10 random users who used feature ENG-4521, based on our PostgreSQL database." |
| Integrate designs | "Update our standard email template based on the new Figma designs that were posted in Slack" |
| Automate workflows | "Create Gmail drafts inviting these 10 users to a feedback session about the new feature." |
| React to external events | MCP como channel push messages a session (Telegram, Discord, webhooks) |

## A3 · 3 transports [F1]

- **stdio** (default) — local process spawn. MCP server como child process.
- **HTTP** — remote MCP via HTTPS POST + SSE responses
- **SSE** — remote MCP via Server-Sent Events

## A4 · CLI commands [F1]

```bash
claude mcp add <name> <command> # Add stdio server
claude mcp add --transport sse <name> <url> # SSE remote
claude mcp add --transport http <name> <url> # HTTP remote
claude mcp list # List configured
claude mcp remove <name>
claude mcp get <name> # Inspect config
```

## A5 · Config storage (3 lugares) [F1]

| Scope | File | Notas |
|---|---|---|
| User | `~/.claude.json` (**NO** en settings.json) | All projects |
| Project | `.mcp.json` en root | Team-shared, commit |
| Local | `.claude/settings.local.json` | Personal, gitignore |

Settings.json controla auto-approval con:
```json
{
 "enableAllProjectMcpServers": true,
 "enabledMcpjsonServers": ["memory", "github"],
 "allowedMcpServers": [{"serverName": "github"}], // managed only
 "deniedMcpServers": [{"serverName": "filesystem"}] // managed only
}
```

## A6 · Permission rules MCP [F1]

Format: `MCP(server-name)` para todo el server o `MCP(server-name:tool-name)` para tools específicas.

```json
{
 "permissions": {
 "allow": ["MCP(notion)", "MCP(github:create-pr)"],
 "deny": ["MCP(filesystem:write)"]
 }
}
```

## A7 · Catálogo MCPs canónicos 2026

### A7.1 · Oficiales Anthropic (modelcontextprotocol/servers)

- `@modelcontextprotocol/server-filesystem` — local FS access
- `@modelcontextprotocol/server-memory` — knowledge graph persistence
- `@modelcontextprotocol/server-github` — repos, issues, PRs
- `@modelcontextprotocol/server-slack` — channels, DMs
- `@modelcontextprotocol/server-postgres` — DB queries
- `@modelcontextprotocol/server-puppeteer` — browser automation
- `@playwright/mcp` — Playwright browser

### A7.2 · Anthropic Directory (claude.ai/directory) [F1]

Reviewed connectors usando misma MCP infrastructure que Claude Code. Cualquier remote server listado se agrega con `claude mcp add`. Tiene filtros de calidad + verificación de privacy/security.

Servers populares: Notion, Linear, Gmail, Figma, Sentry, Statsig, Bitly, ClickUp, Calendly, Fathom, Gamma, Google Drive/Calendar, Hugging Face, Miro, Vercel, Docusign, Audible.

## A8 · Patrón emergente "Channels" [F1]

MCP server puede actuar como **channel** que pushes messages a la session. Claude reacts mid-session a eventos externos.

Ejemplos:
- Telegram MCP push de mensaje de bot
- Discord MCP push de menciones a un canal
- Webhook receiver MCP push de eventos GitHub

Eventos hook relacionados: `Elicitation`, `ElicitationResult` permiten auto-respond formularios MCP.

## A9 · Crear custom MCP server [F2]

SDKs oficiales:
- **Python**: `mcp` package
- **TypeScript**: `@modelcontextprotocol/sdk`

Estructura mínima TS:
```typescript
import { Server } from "@modelcontextprotocol/sdk/server/index.js";

const server = new Server({ name: "my-mcp", version: "0.1" });
server.setRequestHandler(ListToolsRequestSchema, async () => ({...}));
server.setRequestHandler(CallToolRequestSchema, async (req) => ({...}));
```

Spec completa en modelcontextprotocol.io.

## A10 · MCP resources via `@mcp:`

Format: `@server:resource-path` directamente en prompt.

Ejemplo: `@github:repos/owner/repo/issues` fetches MCP resource directamente.

## A11 · Security considerations

- "Review project skills before trusting a repository, since a skill can grant itself broad tool access" [F4]
- Managed scope puede usar `allowedMcpServers`/`deniedMcpServers` para org-wide control [F1]
- `strictKnownMarketplaces` y `blockedMarketplaces` controlan plugin sources [F1]

---

# Parte B · Skills

## B1 · Definición [F4]

> *"Skills extend what Claude can do. Create a `SKILL.md` file with instructions, and Claude adds it to its toolkit. Claude uses skills when relevant, or you can invoke one directly with `/skill-name`."*

Skills siguen el **Agent Skills open standard** [F5] que funciona across multiple AI tools. Claude Code extiende con: invocation control, subagent execution, dynamic context injection.

## B2 · Cuándo crear un skill [F4]

> *"Create a skill when you keep pasting the same instructions, checklist, or multi-step procedure into chat, or when a section of CLAUDE.md has grown into a procedure rather than a fact."*

**Diferencia clave vs CLAUDE.md**: *"Unlike CLAUDE.md content, a skill's body loads only when it's used, so long reference material costs almost nothing until you need it."* [F4]

## B3 · Custom commands → merged en skills [F4]

> *"Custom commands have been merged into skills. A file at `.claude/commands/deploy.md` and a skill at `.claude/skills/deploy/SKILL.md` both create `/deploy` and work the same way."*

Los existentes `.claude/commands/` siguen funcionando. Skills agregan: directory para supporting files, frontmatter para invocation control, ability para Claude auto-load.

## B4 · Bundled skills built-in [F4]

`/simplify`, `/batch`, `/debug`, `/loop`, `/claude-api`. Prompt-based (no fixed logic). Marcados como **Skill** en commands reference.

## B5 · Skill structure mínima [F4]

```text
my-skill/
├── SKILL.md # Main instructions (required)
├── template.md # Template Claude llena
├── examples/
│ └── sample.md # Example output con formato esperado
└── scripts/
 └── validate.sh # Script Claude puede ejecutar
```

`SKILL.md` es required. Otros files referenciados desde SKILL.md (*"Reference supporting files from SKILL.md so Claude knows what each file contains and when to load it"*).

**Tip oficial**: *"Keep SKILL.md under 500 lines. Move detailed reference material to separate files."* [F4]

## B6 · Frontmatter completo · 15 fields [F4]

```yaml
---
name: my-skill # Display name. Lowercase + hyphens. Max 64 chars
description: What this skill does + when to use it
when_to_use: Trigger phrases / example requests
argument-hint: "[issue-number]"
arguments: [issue, branch]
disable-model-invocation: false
user-invocable: true
allowed-tools: Read Grep
model: inherit
effort: medium
context: fork
agent: Explore
hooks: {...}
paths: ["src/**/*.ts"]
shell: bash
---
```

**Solo `description` es recomendado**. Texto combinado `description + when_to_use` truncado a **1,536 chars** en skill listing.

## B7 · Skill scopes con precedence [F4]

| Location | Path | Applies to |
|---|---|---|
| Enterprise | managed settings | All users in org |
| Personal | `~/.claude/skills/<skill-name>/SKILL.md` | All projects |
| Project | `.claude/skills/<skill-name>/SKILL.md` | This project only |
| Plugin | `<plugin>/skills/<skill-name>/SKILL.md` | Where plugin enabled |

**Precedence**: enterprise > personal > project. Plugin skills usan namespace `plugin-name:skill-name` (sin conflict). Si skill y command tienen mismo nombre → **skill wins**.

## B8 · Live change detection [F4]

Claude Code watches skill directories. Add/edit/remove en `~/.claude/skills/` o project `.claude/skills/` toma efecto en current session **sin restart**. Crear nuevo top-level directory requiere restart.

**Discovery jerárquico**: project skills se cargan desde starting dir Y cada parent dir hasta repo root. Soporta monorepo. Edits en subdirs → busca también en nested `.claude/skills/`.

## B9 · String substitutions [F4]

| Var | Descripción |
|---|---|
| `$ARGUMENTS` | All args passed |
| `$ARGUMENTS[N]` o `$N` | N-th argument |
| `$<name>` | Named arg de frontmatter |
| `${CLAUDE_SESSION_ID}` | Current session ID |
| `${CLAUDE_EFFORT}` | Current effort level |
| `${CLAUDE_SKILL_DIR}` | Directory containing SKILL.md (works en plugin) |

Indexed arguments use shell-style quoting. `$ARGUMENTS` siempre expande al full string como typed.

## B10 · Dynamic context injection [F4]

`` !`<command>` `` ejecuta shell command **antes** del skill content sent to Claude. Command output replaces placeholder.

```yaml
---
name: pr-summary
description: Summarize changes in a pull request
context: fork
agent: Explore
allowed-tools: Bash(gh *)
---

## Pull request context
- PR diff: !`gh pr diff`
- PR comments: !`gh pr view --comments`
- Changed files: !`gh pr diff --name-only`
```

**Es preprocessing, no algo que Claude ejecuta** [F4]. Sustitución corre una sola pasada (no recursive). Para multi-line: fenced block con ` ```! `.

Disable global con `"disableSkillShellExecution": true` en settings.

## B11 · Skill content lifecycle (CRÍTICO) [F4]

> *"When you or Claude invoke a skill, the rendered SKILL.md content enters the conversation as a single message and stays there for the rest of the session. Claude Code does not re-read the skill file on later turns."*

Implicaciones:
- Escribe como **standing instructions**, no one-time steps
- Cada línea = recurring token cost
- Auto-compaction carries invoked skills forward dentro de token budget
- Re-attached después de compaction: first 5,000 tokens cada uno, combined 25,000 tokens budget

## B12 · Run en subagent (context: fork) [F4]

Skill content **becomes the prompt** que drives the subagent. NO access a conversation history.

| Approach | System prompt | Task | Also loads |
|---|---|---|---|
| Skill con `context: fork` | From agent type | SKILL.md content | CLAUDE.md (excepto Explore/Plan) |
| Subagent con `skills` field | Subagent's markdown body | Claude's delegation message | Preloaded skills + CLAUDE.md |

**Warning** [F4]: `context: fork` solo tiene sentido para skills con instructions explícitas. Si skill solo tiene guidelines ("use these conventions") sin task, el subagent recibe guidelines sin actionable prompt y returns sin output.

Built-in agents para fork: `Explore`, `Plan`, `general-purpose`. Si omitido → `general-purpose`.

## B13 · Pre-approve tools [F4]

`allowed-tools` grants permission **while skill is active** sin prompting. No restringe qué tools están disponibles (todas siguen callable).

```yaml
allowed-tools: Bash(git add *) Bash(git commit *) Bash(git status *)
```

Para project skills, toma efecto después de aceptar workspace trust dialog.

## B14 · Control de quién invoca [F4]

| Frontmatter | You invoke | Claude invokes | Cuándo loaded |
|---|---|---|---|
| (default) | Sí | Sí | Description always in context, full loads when invoked |
| `disable-model-invocation: true` | Sí | No | Description NOT in context, full loads when YOU invoke |
| `user-invocable: false` | No | Sí | Description always in context, full loads when invoked |

Uso típico:
- `/commit`, `/deploy` → `disable-model-invocation: true` (side effects, no Claude auto)
- `legacy-system-context` → `user-invocable: false` (Claude usa cuando relevant, no es comando)

## B15 · `skillOverrides` desde settings [F4]

Controla visibility sin editar SKILL.md (útil para shared repos o MCP-provided skills):

```json
{
 "skillOverrides": {
 "legacy-context": "name-only",
 "deploy": "off"
 }
}
```

Values: `"on"` (default) | `"name-only"` | `"user-invocable-only"` | `"off"`. Plugin skills NO afectados.

`/skills` menu writes esto for you: highlight + Space cycles states + Enter saves a `.claude/settings.local.json`.

## B16 · Restringir Claude's skill access [F4]

3 ways:

**Deny ALL skills** en `/permissions`:
```
Skill # deny rules
```

**Allow/deny específicos**:
```
Skill(commit)
Skill(review-pr *)
Skill(deploy *) # in deny
```

**Hide skill** con `disable-model-invocation: true` en frontmatter → fuera del Claude context completamente.

## B17 · Skill descriptions budget [F4]

> *"All skill names are always included, but if you have many skills, descriptions are shortened to fit the character budget."*

- Budget = **1% of model's context window** por default
- Overflow → descriptions de skills less-invoked dropped first
- Cap por entry: **1,536 chars** combined description + when_to_use
- Raise budget: `skillListingBudgetFraction: 0.02` (2%) o `SLASH_COMMAND_TOOL_CHAR_BUDGET` env var
- Free budget: set low-priority a `"name-only"` en `skillOverrides`
- Diagnosis: `/doctor` muestra budget overflow

## B18 · Sharing/distribution [F4]

- **Project skills**: commit `.claude/skills/` to version control
- **Plugins**: directory `skills/` en plugin
- **Managed**: deploy org-wide via managed settings

## B19 · Patrón "Skill genera output visual" [F4]

Skills pueden bundle + run scripts en cualquier lenguaje. Ejemplo canónico oficial: codebase-visualizer.py que genera HTML interactivo con tree view + sidebar + bar chart.

Script path usa `${CLAUDE_SKILL_DIR}` para que funcione en personal/project/plugin levels.

Pattern works para: dependency graphs, test coverage reports, API docs, DB schema visualizations.

## B20 · Troubleshooting [F4]

**Skill no triggering**:
1. Check description includes keywords users would say naturally
2. Verify skill aparece en "What skills are available?"
3. Rephrase request para match description closer
4. Invoke directly con `/skill-name`

**Skill triggers too often**:
1. Make description más specific
2. Add `disable-model-invocation: true`

**Descriptions cut short**: ver B17.

---

## Si te llevas UNA cosa

**MCPs y Skills se complementan: MCP conecta Claude a TOOLS externos (APIs, DBs, services); Skills empaqueta WORKFLOWS reutilizables (procedures, conventions, prompts). Si necesitas que Claude pueda HACER algo nuevo en otro sistema → MCP. Si necesitas que Claude SIGA un workflow específico tuyo → Skill.** Y para tareas que sólo deben dispararse manualmente con side effects (deploy, commit a producción), siempre `disable-model-invocation: true`.
