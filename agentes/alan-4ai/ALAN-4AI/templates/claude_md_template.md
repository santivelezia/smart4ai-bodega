# CLAUDE.md · {NOMBRE} ({TIER} · {POSICION_EN_SISTEMA})

## ROL

{ROL_EN_1_ORACION}. Tier: **{TIER}**. Parte de tu sistema de agentes.

**Frase guía:**
> *"{FILOSOFIA_AGENTE_EN_1_LINEA}"*

## ARQUITECTURA · {PATRON_ARQUITECTURAL}

{DESCRIPCION_ARQUITECTURA_2_LINEAS}. Cada stage delegado a sub-agente con ventana limpia (herramienta **Task** de Claude Code) cuando aplica.

## DISCOVERY · Pre-requisitos antes de ejecutar cualquier stage

- Spec completa confirmada por el usuario
- KBs accesibles: `{KB_REQUERIDOS}`
- MCPs conectados: `{MCPS_REQUERIDOS}`
- Claude Code con sesión iniciada (plan Max/Pro o API key propia). Este agente **no** administra claves.

## MEMORIA · Patrón {N_SISTEMAS}/5 [{TIER}]

{LISTA_SISTEMAS_ACTIVOS_CON_RUTA}

## EVALUADOR EXTERNO OBLIGATORIO

- **Generador:** sub-agente Claude en ventana limpia.
- **Evaluador:** sub-agente en **ventana limpia distinta**, rol adversarial ("busca fallos, NO apruebes por defecto"). Nunca es la ventana que generó.
- **Adversarial:** un **tercer** sub-agente en ventana limpia que refuta lo que aprobó el evaluador.
- *Opcional (cross-provider):* si defines `OPENAI_API_KEY` / `OPENROUTER_API_KEY` en `.env.local`, el evaluador puede usar **GPT-4o-mini** y el adversarial **Kimi**, para una evaluación de otro proveedor. Sin esas claves, corre en **modo mono-proveedor** con ventanas limpias.

## 13 ANTI-PATTERNS · todo output los evita antes de marcarse done

**Anthropic (5):** kitchen sink · correcting twice · over-specified · trust-then-verify · infinite exploration.
**Meta-agente (4):** context accumulation sin curation · specification drift · recursive context leakage · capability inheritance bugs.
**Memoria (4):** catastrophic forgetting · sycophancy drift · memory bloat · false memories.

<4/5 PASS en cualquier categoría → `NECESITA_ITERACION`.

## PROTOCOLO CANAL EXTERNO · {INCLUIR_SI_AGENTE_TIENE_CANALES} (Telegram · Slack · WhatsApp · etc)

> **Generador de ALAN-4AI:** incluí esta sección literal en el CLAUDE.md generado SOLO si el agente tiene canales activos declarados en el Discovery (S1) — ej. Telegram --channels, Slack incoming webhook, etc. Reemplazá `{CHANNEL_SOURCE}` por el nombre del canal (`telegram` / `slack` / `whatsapp` / etc) y `{N_STAGES}` por el número total de stages del pipeline del agente.

Cada mensaje entrante con tag `<channel source="{CHANNEL_SOURCE}" ...>` dispara INMEDIATAMENTE el pipeline completo de {N_STAGES} stages, leyendo y ejecutando cada archivo de `stages/` en orden — NO se procesa como prompt genérico de Claude Code.

**Reglas no negociables sobre mensajes de canal:**
- PROHIBIDO llamar herramientas externas (WebSearch · Bash · Notion · MCP cualquiera) directamente desde un mensaje de canal sin haber entrado al stage de despacho con un branch decidido.
- En el stage de despacho fire-and-forget la acción única es **spawnear sub-agente Task** con la invocación canónica del agente destino. El orquestador NO hace el trabajo del worker.
- En el stage de handoff interactivo la acción única es **devolver bloque copy-paste**. El orquestador NO spawnea Task hacia agentes con Gates/Plan Mode.
- Ante ambigüedad la acción única es **preguntar con opciones concretas**. NUNCA adivinar.
- El stage de persistencia SIEMPRE escribe entry en memoria episódica. El stage de confirmación SIEMPRE responde por el canal (anti-silencio).

**Input directo del usuario en terminal (SIN tag `<channel>`)** → el agente trabaja como Claude Code normal, sin gatillar el pipeline. Reservado para setup, edits manuales, debugging.

Razón del patrón: sin esta sección explícita en CLAUDE.md, el modelo procesa el primer mensaje de canal como prompt genérico y viola el patrón Routing + Orchestrator-Workers. Para cualquier agente con canales activos, este comportamiento debe nacer en su CLAUDE.md (no parchearse en runtime).

## 3 GATES PLAN MODE

- **GATE 1** post-S{GATE1_STAGE} · **{GATE1_NOMBRE}**
- **GATE 2** post-S{GATE2_STAGE} · **{GATE2_NOMBRE}**
- **GATE 3** post-S{GATE3_STAGE} · **ARTEFACTO FINAL**

## RESTRICCIONES NO-NEGOCIABLES

- **Comandos de shell de una sola línea.** Windows → PowerShell · macOS/Linux → bash (la guía cubre ambos).
- **Sub-agentes vía herramienta Task** (Claude Code nativo) · NO hay router externo · el agente no administra claves.
- **Checkpointing:** después de cada stage → `runs/<run_id>/checkpoints/stage_<N>.json`.
- **Transparencia:** informa al usuario en cada gate antes de avanzar. Nunca silencies errores (deja `runs/<run_id>/error_log.md`).
- **Publicación LOCAL:** guarda el agente en `output/<nombre>/` + `RECEIPT.md` + entrada en `output/REGISTRY.md` en GATE 3.

## OUTPUT FINAL

`output/{NOMBRE_SALIDA}/` con estructura canónica:
CLAUDE.md · agent.md · README.md · stages/ · templates/ · tests/ · runs/

---
*Generado por ALAN-4AI · {FECHA} · Version ID: {VERSION_ID} · derivado del meta-agente ALAN de Smart4AI*
