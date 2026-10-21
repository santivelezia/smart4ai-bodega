# 04 · Prompt y system design · CLAUDE.md, system prompts, XML

> *Best practices Anthropic para system prompts, estructura de CLAUDE.md (qué incluir/excluir), regla "pruning ruthless", imports modulares, XML tags.*

## Fuentes

- [F1] Best practices Claude Code · https://code.claude.com/docs/en/best-practices
- [F2] Skills (frontmatter + body) · https://code.claude.com/docs/en/skills
- [F3] Define success criteria · https://platform.claude.com/docs/en/test-and-evaluate/define-success

---

## 1 · La regla #1 · Simplicity first

> *"Most best practices are based on one constraint: Claude's context window fills up fast, and performance degrades as it fills."* [F1]

Cuando context window se llena, *"Claude may start 'forgetting' earlier instructions or making more mistakes. The context window is the most important resource to manage"* [F1].

Aplicado a system prompts: **un CLAUDE.md inflado causa que Claude IGNORE actual instructions** porque rules críticas se pierden en el ruido. El test canónico:

> *"Would removing this cause Claude to make mistakes?"* Si no → cut. [F1]

## 2 · Qué incluir vs excluir en CLAUDE.md [F1]

| ✅ Include | ❌ Exclude |
|---|---|
| Bash commands que Claude no puede inferir | Cosas que Claude figura del código |
| Code style rules que difieren de defaults | Standard language conventions |
| Testing instructions, preferred test runners | Detailed API docs (link instead) |
| Repository etiquette (branch naming, PR conventions) | Information que cambia frecuentemente |
| Architectural decisions específicas | Long explanations o tutorials |
| Developer env quirks (required env vars) | File-by-file codebase descriptions |
| Common gotchas / non-obvious behaviors | Self-evident practices ("write clean code") |

Ejemplo canónico de Anthropic:

```markdown
# Code style
- Use ES modules (import/export) syntax, not CommonJS (require)
- Destructure imports when possible (eg. import { foo } from 'bar')

# Workflow
- Be sure to typecheck when you're done making a series of code changes
- Prefer running single tests, and not the whole test suite, for performance
```

## 3 · Patterns para CLAUDE.md efectivo

### 3.1 · Emphasis para tuning adherence [F1]

Agregar emphasis ("IMPORTANT", "YOU MUST") mejora adherence cuando Claude se desvía. **Si Claude sigue haciendo algo a pesar de la regla, el file probablemente es demasiado largo y la regla está perdida**.

### 3.2 · Imports modulares [F1]

```markdown
See @README.md for project overview and @package.json for available npm commands.

# Additional Instructions
- Git workflow: @docs/git-instructions.md
- Personal overrides: @~/.claude/my-project-instructions.md
```

Beneficio: modulariza, evita un mega-archivo, permite que CLAUDE.md principal sea conciso pero referencie documentos detallados.

### 3.3 · Múltiples locations con propósitos distintos [F1]

- `~/.claude/CLAUDE.md` — home, aplica a TODAS las sesiones (personal preferences)
- `./CLAUDE.md` — project root, **commit a git** para team-wide
- `./CLAUDE.local.md` — project-specific personal, **gitignore**
- Parent directories — monorepos pulled in automáticamente
- Child directories — pulled on-demand cuando trabajas con files allá

## 4 · System prompts más allá de CLAUDE.md

### 4.1 · XML tags como estructura [F3]

Anthropic usa XML tags consistentemente en sus prompt templates. Ejemplos del docs canónico:

```xml
<rubric>The answer should always mention 'Acme Inc.' in the first sentence</rubric>
<answer>{model_output}</answer>
Think through your reasoning in <thinking> tags, then output 'correct' or 'incorrect' in <result> tags.
```

Beneficios documentados:
- **Estructura predecible** facilita parsing por modelos y debugging por humanos
- **Encourage reasoning** con `<thinking>` + output en `<result>` tags **mejora performance** especialmente en complex judgement tasks [F3]
- Discard the reasoning tag content after extracting result si no lo necesitas

### 4.2 · Use DIFFERENT model para grading [F3]

> *"Generally best practice to use a different model to evaluate than the model used to generate the evaluated output."* [F3]

Razón: avoid self-rating bias. Si Claude Opus generó, usa Claude Sonnet o GPT-4o-mini para evaluar.

### 4.3 · Reference vs Task content en skills [F2]

Anthropic recomienda explícitamente separar:

**Reference content** — knowledge inline para current work:
```yaml
---
name: api-conventions
description: API design patterns for this codebase
---
When writing API endpoints:
- Use RESTful naming conventions
- Return consistent error formats
- Include request validation
```

**Task content** — step-by-step procedures para acciones específicas:
```yaml
---
name: deploy
description: Deploy the application to production
context: fork
disable-model-invocation: true
---
Deploy the application:
1. Run the test suite
2. Build the application
3. Push to the deployment target
```

Para task content con side effects → siempre `disable-model-invocation: true` (solo user invoca). Razón: *"You don't want Claude deciding to deploy because your code looks ready"* [F2].

## 5 · Provide specific context (anti-vagueness) [F1]

Comparación clave del docs Anthropic:

| Vague | Specific |
|---|---|
| "add tests for foo.py" | "write a test for foo.py covering the edge case where user is logged out. avoid mocks." |
| "why does ExecutionFactory have such a weird api?" | "look through ExecutionFactory's git history and summarize how its api came to be" |
| "add a calendar widget" | "look at how existing widgets are implemented on home page. HotDogWidget.php is a good example. follow the pattern..." |
| "fix the login bug" | "users report login fails after session timeout. check src/auth/, especially token refresh. write a failing test that reproduces, then fix it" |

**Caveat útil**: prompts vagos a veces son útiles para EXPLORAR ("what would you improve in this file?"). El truco es saber cuándo cada uno aplica:
- Vague cuando exploras y puedes course-correct rápidamente
- Specific cuando ejecutas y necesitas que sea right-first-try

## 6 · Provide rich content [F1]

5 técnicas para inyectar context efficiently:
1. **Reference files with `@`** en vez de describir dónde está
2. **Paste images directly** (copy/paste o drag-drop)
3. **Give URLs** para docs/API references (usar `/permissions` para allowlist domains frecuentes)
4. **Pipe in data** — `cat error.log | claude` envía contenido directo
5. **Let Claude fetch what it needs** — tell Claude pull con Bash/MCP/Read

## 7 · Patrón "Let Claude interview you" [F1]

Para features grandes, el prompt canónico recomendado:

```text
I want to build [brief description]. Interview me in detail using the AskUserQuestion tool.

Ask about technical implementation, UI/UX, edge cases, concerns, and tradeoffs.
Don't ask obvious questions, dig into the hard parts I might not have considered.

Keep interviewing until we've covered everything, then write a complete spec to SPEC.md.
```

Una vez completo el spec, **arrancar fresh session** para implementar. La fresh session tiene clean context focused en implementación.

## 8 · Communication patterns

### 8.1 · Ask codebase questions [F1]
> *"Ask Claude questions you'd ask a senior engineer."*

Ejemplos canónicos:
- "How does logging work?"
- "How do I make a new API endpoint?"
- "What does `async move { ... }` do on line 134 of `foo.rs`?"
- "What edge cases does `CustomerOnboardingFlowImpl` handle?"
- "Why does this code call `foo()` instead of `bar()` on line 333?"

### 8.2 · Course-correct early and often [F1]
> *"The best results come from tight feedback loops."*

Atajos:
- `Esc` — stop mid-action, context preserved
- `Esc + Esc` o `/rewind` — restore conversation/code/both
- `"Undo that"` — Claude reverts
- `/clear` — reset context entre unrelated tasks

**Regla canónica**: *"If you've corrected Claude more than twice on the same issue in one session, the context is cluttered with failed approaches. Run `/clear` and start fresh with a more specific prompt that incorporates what you learned."* [F1]

## 9 · Skills frontmatter al servicio del system design [F2]

Los 15 fields del SKILL.md frontmatter (extraído del docs oficial), cada uno con propósito system-design específico:

Field | Propósito design |
---|---|
`name` | Display name, hyphens, max 64 chars |
`description` | **KEY**: combinado con when_to_use truncado a 1,536 chars; Claude lo lee para decidir cargar skill |
`when_to_use` | Trigger phrases adicionales |
`argument-hint` | Hint en autocomplete |
`arguments` | Named positional args → `$name` substitution |
`disable-model-invocation` | true = solo user invoca (workflows con side effects) |
`user-invocable` | false = solo Claude (background knowledge) |
`allowed-tools` | Pre-approve tools sin permission prompt |
`model` | Override por skill (haiku para cheap tasks) |
`effort` | Override effort level |
`context: fork` | Run en subagent isolated |
`agent` | Subagent type cuando fork (Explore/Plan/general-purpose) |
`hooks` | Hooks scoped a skill lifecycle |
`paths` | Glob patterns activan auto |
`shell` | bash o powershell para `!\`cmd\`` |

## 10 · Common failure patterns [F1]

5 canonical mistakes (referenciados en categoría 09 también):

1. **Kitchen sink session** — un task → unrelated → back. Fix: `/clear` entre tasks.
2. **Correcting over and over** — context polluted. Fix: después de 2 fails, `/clear` + mejor prompt.
3. **Over-specified CLAUDE.md** — too long, rules perdidas. Fix: prune ruthlessly.
4. **Trust-then-verify gap** — plausible pero broken. Fix: always provide verification.
5. **Infinite exploration** — sin scope, llena context. Fix: scope narrow o use subagents.

---

## Si te llevas UNA cosa

**Trata CLAUDE.md como código: review when things go wrong, prune regularly, test changes by observing whether Claude's behavior actually shifts.** Un CLAUDE.md de 50 líneas bien diseñado vence a uno de 500 líneas siempre. La pregunta a hacerse para cada línea no es "¿es verdad?" sino "¿si la borro, Claude se equivocará?". Si la respuesta es no, córtala.
