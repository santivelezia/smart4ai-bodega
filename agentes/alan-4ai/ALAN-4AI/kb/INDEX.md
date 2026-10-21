# kb/ · Bases de conocimiento de ALAN-4AI · INDEX

> Estas 3 investigaciones son la base de conocimiento que ALAN-4AI carga para construir agentes
> de clase mundial. El Stage 2 (`stages/2_kb_coverage.md`) lee este INDEX para medir cobertura.
> Cada carpeta trae un `.meta.json` y archivos categóricos numerados (`00_INDICE.md` es el mapa interno).

## Entradas

| KB | Cubre | Path |
|---|---|---|
| **base** · Cómo construir agentes Claude | Arquitectura de agentes · Claude Code · prompt/system design · Agent SDK · MCPs y skills · memoria y context engineering · anti-patterns canónicos · calidad/costos/ops | [como-construir-agentes-claude-2026/](como-construir-agentes-claude-2026/00_INDICE.md) |
| **D** · Agentes con memoria viva (self-improving) | Memoria jerárquica · mecanismos de aprendizaje continuo · gobernanza y drift · anti-patterns de memoria · **Patrón 5 de memoria por tier** | [agentes-con-memoria-viva-self-improving-systems-2026/](agentes-con-memoria-viva-self-improving-systems-2026/00_INDICE.md) |
| **E** · Meta-agente de clase mundial | Arquitectura de meta-agentes · pipeline robustness & lifecycle · eval frameworks · LLM-as-judge · elicitación/especificación · anti-patterns y failure modes | [meta-agente-clase-mundial-alan-2026/](meta-agente-clase-mundial-alan-2026/00_INDICE.md) |

## Cómo la usa ALAN-4AI

1. **S2 · KB Coverage Check** lee este INDEX y las 3 KBs, y calcula `coverage_score` (0–1) contra el
 dominio del agente que vas a construir.
2. Si `coverage_score < 0.5`, ALAN-4AI te dice qué dominio queda descubierto y sugiere un tema de
 investigación. Puedes investigarlo tú (WebSearch / tus propias fuentes) y agregar notas a `kb/`,
 o continuar con los gaps documentados.
3. Los stages S3–S9 citan estas KBs con códigos cortos: **[base NN]**, **[D NN]**, **[E NN]**, donde `NN`
 es el archivo numerado dentro de la carpeta.

## Cómo ampliar la KB (opcional)

- Para agregar conocimiento de un dominio nuevo (ej. "WhatsApp Business API", "SEO técnico"), crea una
 carpeta `kb/<tema-slug>/` con tus notas y un `.meta.json` mínimo (`{"estado":"INVESTIGACION_LISTA",
 "fecha_creacion":"YYYY-MM-DD"}`) y añádela a la tabla de arriba.
- Regla: KBs con fecha >90 días conviene refrescarlas (los claims pueden haber cambiado).

---

*Convenciones: slug en kebab-case · fecha `YYYY-MM-DD` · estado `INVESTIGACION_LISTA | LISTA_CON_RESERVAS`.*
