# LECCIONES.md · Memoria de aprendizajes de ALAN-4AI

> Cada run de ALAN-4AI que descubra algo nuevo APPENDEA una entrada aquí (regla de S11).
> Esto es la memoria procedural del meta-agente: los fixes viven en los stages, pero el POR QUÉ vive aquí.
> Formato: fecha · run · lección · dónde quedó aplicada. Mantener <500 líneas (consolidar al acercarse).
>
> Nota: este archivo arranca con lecciones destiladas del meta-agente ALAN del que deriva ALAN-4AI.
> Son aprendizajes reales de construir agentes de distintos tipos; los nombres propios internos se
> generalizaron para que te sirvan como plantilla.

---

## Run de un agente CORE (smoke test) — 3 lecciones fundacionales

**L1 · Protocolo de canal explícito en CLAUDE.md.** Sin sección "PROTOCOLO CANAL", el modelo procesa el primer mensaje del canal como prompt genérico y viola Routing + Orchestrator-Workers. Aplicada en: `templates/claude_md_template.md` (sección obligatoria si el agente declara canales en S1).

**L2 · Los sub-agentes lanzados con la herramienta Task NO heredan `process.env`.** Un "401" del evaluador cross-provider resultó ser una key vacía por env no cargado, no una key inválida. Aplicada en: S8/S9 Paso 1.5 (carga manual de `.env.local` + validación anti-placeholder antes del spawn) — **solo si activas el modo cross-provider opcional**. En modo mono-proveedor (default) no hay claves que cargar.

**L3 · Regla anti-falso-negativo en evaluadores.** Un 401 con key vacía y un 401 con key inválida son indistinguibles desde el API — leer `.env.local` ANTES de degradar al fallback. Aplicada en: S9 Paso 1.5 (relevante solo en cross-provider).

## Run de un agente CORE (segunda iteración) — falsos positivos del adversarial

**L4 · Verificar la premisa antes de aceptar un FAIL.** El juez adversarial afirmó "CLAUDE.md >80 líneas" cuando el archivo tenía 54. Un FAIL con premisa falsa contamina el arbitraje. Aplicada en: S9 prompt de refutación (regla anti-falso-positivo) + S9 Paso 4 (verificar premisa contra el archivo real).

**L5 · El tercer juez debe ser una ventana verdaderamente independiente.** El adversarial (S9) tiene que correr en una **ventana limpia distinta** de la que generó y de la que evaluó (S8). Si activas cross-provider, puede ser además otro proveedor; si no, un sub-agente Claude con rol adversarial cumple la función. Aplicada en: S9 y en el check de S0 (detección de modo mono/cross-provider).

## Run de mejora de un agente existente — nace el Modo B

**L6 · ALAN-4AI puede mejorar agentes existentes con el mismo pipeline.** La convergencia de un agente real de una versión a la siguiente funcionó con: backup previo, spec de delta dada por completa, modificación quirúrgica (archivos que funcionan preservados), panel S8+S9 normal, version bump. Formalizada como **Modo B** en: `agent.md §MODO B` + `stages/1b_agent_audit.md` + `templates/upgrade_spec_template.md`.

**L7 · El panel multi-juez funciona mejor con roles complementarios.** Un juez aprobó con reservas (85/100); el otro encontró 6 ambigüedades reales que el primero no vio — ninguna bloqueante, todas corregidas antes de publicar. El valor del panel no es el veredicto, es la lista de fixes.

**L8 · Algunos modelos cortan el reasoning por token cap pero entregan el análisis en `content`.** Comportamiento conocido de ciertos jueces (p. ej. Kimi vía OpenRouter en cross-provider) — no tratarlo como fallo del juez; lee el `content`. Aplicada como nota operativa en este archivo.

**L9 · Consenso entre modelos = señal, NO prueba.** La confianza la dan las fuentes/archivos verificados, no que dos LLMs coincidan. Principio aplicable a todo agente que ALAN-4AI genere con múltiples motores: inyecta un anti-patrón "consenso-de-modelos" en el CLAUDE.md del agente cuando use un panel.

## Upgrade de ALAN-4AI a sí mismo (meta: el meta-agente mejorándose)

**L11 · En Modo B, el paquete de evaluación S8 debe separar ANTES/DESPUÉS explícitamente.** En un run de upgrade, el evaluador leyó la sección "Estado actual (audit)" del `upgrade_spec` como si fuera el resultado y RECHAZÓ con 6 hallazgos — los 6 eran premisa falsa (el adversarial los descartó todos aplicando la regla anti-falso-positivo de L4). Fix: en S8 Modo B, el paquete debe rotular "ESTADO PRE-UPGRADE (lo que se corrige)" vs "RESULTADO POST-UPGRADE (lo que se evalúa)" y adjuntar evidencia de los archivos escritos. También validado: un patrón fire-and-forget con ACK duro es subfamilia legítima de routing.

**L10 · La documentación divergió del comportamiento real.** Varios archivos (README/S0/S3/S10/S11) seguían citando un modelo/juez que ya no se usaba, y la doc externa describía una versión vieja del pipeline (con más stages de los reales). Fix: el **registro de modelos vive como fuente única en `agent.md`** (la tabla "Modelos por stage") + regla operativa "actualizar la tabla, no los stages" + revisar la doc en cada bump MAJOR/MINOR. Lección portable: cuando cambies un modelo o un stage, busca TODAS las referencias antes de dar por cerrado el upgrade.
