# Bodega Smart4AI · agentes, plantillas e investigaciones para tu Claude

**v1.0.0 · 2026-10-21** · Licencia [CC BY-NC 4.0](LICENSE) · Hecho en Medellín por [Smart4AI](https://smart4ai.io)

La bodega es el material de trabajo que Smart4AI comparte con los alumnos de **«Arquitectos de IA»**, el curso de Claude en Skool: un agente que crea agentes, las plantillas para montar tu «oficina de IA» y varias investigaciones verificadas para que tu Claude trabaje con datos y no de memoria. Funciona con Claude Code, Cowork y claude.ai.

Piénsala como la bodega de un restaurante: no es el plato servido, son los ingredientes ya seleccionados. Tú los llevas a tu cocina («Mi oficina de IA») y tu Claude cocina con ellos.

> Consejo: descomprime o clona en una ruta corta (por ejemplo, Documentos). Windows corta las rutas de más de 260 caracteres.

## Cómo usarla (5 minutos)

1. **Descárgala.** En GitHub, botón verde **Code → Download ZIP**, y descomprime. Si usas git: `git clone https://github.com/santivelezia/smart4ai-bodega.git`.
2. **Llévala a tu oficina.** Copia la carpeta (o solo la parte que necesites) dentro de tu carpeta «Mi oficina de IA».
3. **Pídele a Claude que la use.** Abre Claude Code o Cowork en esa carpeta y pega, por ejemplo: «Lee `bodega/plantillas/oficina-de-ia/bloques-para-tu-CLAUDE-md.md` y úsalo: compáralo con mi CLAUDE.md y propónme lo que falte, sin guardar nada sin mi sí».

Regla de oro: cada archivo dice para qué sirve en sus primeras líneas. Si no sabes por dónde empezar, pídele a Claude «lee el README de la bodega y dime qué me sirve para mi negocio».

## Qué hay adentro

| Carpeta | Qué es | Empieza por |
|---|---|---|
| `agentes/alan-4ai/` | **ALAN-4AI v1.0**, el agente que crea agentes (lección 44). Te entrevista y te entrega tu agente listo | `LEEME.md` |
| `plantillas/oficina-de-ia/` | Los 6 prompts para armar tu oficina en 5 sesiones (v1.3), los bloques para tu `CLAUDE.md`, la plantilla de aprobación en 5 líneas y un `.gitignore` en lista blanca probado | `prompts_5-sesiones.md` |
| `investigaciones/investigacion-rigurosa/` | Cómo investigar con rigor: 5 marcos (calibración, lectura lateral, GRADE, PRISMA, hipótesis competidoras) ordenados por evidencia y convertidos en reglas para pegar en un prompt | `marco-teorico.md` |
| `investigaciones/extensibilidad-mcp-skills-plugins/` | Cómo se extiende Claude: protocolo MCP, MCP en Claude Code, anatomía de las skills, plugins, hooks y subagentes, seguridad y costo. Cada dato con su fuente | `04_skills-anatomia-y-uso.md` |
| `investigaciones/ecosistema-github-y-artefactos/` | Repos oficiales y SDK, cómo evaluar si un repo comunitario sirve, qué es un artefacto y sus límites, Projects y gobernanza | `03_como-evaluar-un-repo.md` |
| `enlaces/` | Lo que ya está publicado: marketplace de plugins, plugin Radar a Tienda y los dos artefactos de la oficina de IA | `README.md` |

`empaquetar.py` arma un ZIP de la bodega para quien no usa git (`py empaquetar.py` en Windows o `python3 empaquetar.py` en Mac; el ZIP queda en la carpeta de arriba).

## Enlaces rápidos

- **Plantilla «Mi oficina de IA»** (artefacto interactivo, 6 industrias): https://claude.ai/artifact/8yEyiQMjofpycLnSg5KFaS
- **Caso real: la oficina de IA de Smart4AI** (artefacto): https://claude.ai/artifact/JvjdgXZHSbHAGjkDJgJDYL
- **Marketplace de plugins de Smart4AI:** https://github.com/santivelezia/smart4ai-plugins

Más detalle en [`enlaces/README.md`](enlaces/README.md).

## Licencia y crédito

Todo el contenido está bajo **Creative Commons Atribución-NoComercial 4.0 (CC BY-NC 4.0)**: puedes usarlo, adaptarlo y compartirlo **sin fines comerciales**, dando crédito así: «Fuente: Smart4AI · github.com/santivelezia/smart4ai-bodega». No puedes venderlo ni incluirlo en un producto pago. Texto completo en [`LICENSE`](LICENSE).

El plugin Radar a Tienda (enlazado, no incluido aquí) se construyó sobre el skill de estudio de mercado de **Carlos Jiménez**, con su autorización; si lo usas o lo citas, dale crédito también a él.

## Aviso

Este material es educativo. **No es asesoría legal, médica, financiera ni tributaria.** Las investigaciones tienen fecha de corte: precios, límites y funciones de las herramientas cambian, así que verifica en la fuente oficial antes de tomar una decisión. Revisa todo lo que tu Claude genere antes de usarlo con clientes.

## Cómo aportar

¿Encontraste un error o tienes algo que sumar? Mira [`CONTRIBUTING.md`](CONTRIBUTING.md). Convivencia: [`CODE_OF_CONDUCT.md`](CODE_OF_CONDUCT.md).

## Cambios

- **v1.0.0 · 2026-10-21:** primera versión. ALAN-4AI v1.0, plantillas de la oficina de IA (prompts v1.3), tres investigaciones y enlaces.
