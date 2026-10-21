# Template de Memoria v2.0 · Patrón 5 por Tier

> Usado por el **Stage 5 (memory_strategy)**. Inyecta los sistemas de memoria correspondientes según el tier declarado en el Discovery (S1).
> Fuente: KB-D (`agentes-con-memoria-viva-self-improving-systems-2026`) · `[D 09]` (template de memoria) + `[D 03]` (arquitectura de memoria jerárquica).

---

## Gradación por tier (cuántos sistemas inyectar)

| Tier | Sistemas | Cuáles |
|---|---|---|
| **CORE** (agentes centrales, siempre activos) | 5/5 | Working + Episodic + Semantic + Procedural + Identity |
| **Ops Internas** (de apoyo) | 4/5 | Working + Episodic + Semantic + Procedural (sin Identity) |
| **Comerciales** (de cara a usuarios/clientes) | 3/5 | Working + Episodic + Semantic |

Regla: si el tier no fue declarado en S1 → default a **Comercial (3/5)** + warning (conservador · evita over-engineering).

---

## Los 5 sistemas · config skeleton

### 1. Working Memory (todos los tiers)
```yaml
working_memory:
  storage: context_window + system_prompt_dinamico
  scope: tarea_activa
  retention: efímera (se descarta al terminar la tarea)
  costo: $0 (vive en el contexto)
```

### 2. Episodic Memory (todos los tiers)
```yaml
episodic_memory:
  storage: PostgreSQL + pgvector (o cualquier DB vectorial que gestiones tú)
  scope: historial de interacciones del agente
  retention: 12 meses · particionado por mes · archivado automático
  embeddings: un modelo de embeddings (ej. text-embedding-3-small)
  costo: bajo (embeddings + DB gestionada por ti)
  compliance: delete-on-request por user_id (Habeas Data)
```

### 3. Semantic Memory (todos los tiers)
```yaml
semantic_memory:
  storage: Context Tree en markdown (ByteRover pattern)
  scope: knowledge base del dominio del agente
  retention: versionado en Git · Adaptive Knowledge Lifecycle
  costo: $0 (filesystem)
```

### 4. Procedural Memory (CORE + Ops · NO Comercial)
```yaml
procedural_memory:
  storage: archivos markdown + skill router (Memento-Skills)
  scope: skills y workflows aprendidos por el agente
  retention: versionado · +26.2% en General AI Assistants
  costo: $0 (filesystem)
```

### 5. Identity Memory (SOLO CORE)
```yaml
identity_memory:
  storage: CLAUDE.md + constitution versionada
  scope: constitución evolutiva del agente
  retention: Git semantic versioning + aprobación humana (revisión del owner del agente)
  costo: $0 (filesystem)
  guardrail: cambio >20% sin aprobación → alerta de drift de personalidad
```

---

## Sección a inyectar en el CLAUDE.md del agente generado

ALAN-4AI escribe esta sección en el `CLAUDE.md` del agente nuevo, incluyendo SOLO los sistemas del tier:

```markdown
## MEMORIA · Patrón 5 ({tier} · {N}/5 sistemas)

- Working: contexto activo · efímero
- Episodic: PostgreSQL+pgvector · historial · delete-on-request
- Semantic: Context Tree markdown · KB del dominio
[- Procedural: skill router markdown · solo si CORE u Ops]
[- Identity: CLAUDE.md versionado · solo si CORE · validación humana de drift]
```

---

## Validación (checklist para Stage 5)

- [ ] Tier leído correctamente de `discovery_spec.md`
- [ ] Nº de sistemas inyectados coincide con el tier (CORE 5 · Ops 4 · Comercial 3)
- [ ] Cada sistema con storage + scope + retention definidos
- [ ] Sección de memoria escrita en el CLAUDE.md del agente generado
- [ ] Si tier = CORE → Identity Memory incluye guardrail de drift (validación humana)

**Anti-patterns a evitar:** inyectar 5/5 a un Comercial (over-engineering) · saltar la declaración de tier (rompe la gradación).
