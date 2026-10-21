# Stage 5 · Memory Strategy · modelo rápido y capaz (ej. Claude Sonnet, con cache)

## Propósito

Inyectar el **Patrón 5 de Memoria** según el tier declarado en S1. Cada agente nace con los sistemas de memoria correctos para su rol desde el primer día. La gradación no es opcional: los sistemas se seleccionan por tier para controlar costo, riesgo de drift y overhead de gobernanza. [D 09]

**Regla invariante del patrón:** nunca eliminar Semantic ni Episodic de ningún agente — la generalización OOD depende de la primera y la personalización de la segunda. [D 09]

---

## 1 · Input

| Fuente | Contenido |
|---|---|
| `runs/<run_id>/elicitation_spec.md` | Tier declarado (CORE / Ops / Comercial) · dominio · casos de uso |
| `runs/<run_id>/pipeline_design.md` | N stages · herramientas · integraciones del agente |
| KB-D `09_template-hefesto.md` | Los 5 sistemas de memoria · variantes por tier · código skeleton |
| `CLAUDE.md §MEMORIA POR TIER` | Regla de decisión consolidada |

---

## 2 · Proceso

**Paso 1 — Leer el tier de S1**
- Leer `elicitation_spec.md` · campo "Tier declarado"
- Tier es el ancla inmutable que determina qué sistemas se inyectan

**Paso 2 — Seleccionar sistemas según tier** [D 09 Variantes por Tipo de Agente]

| Sistema | CORE (5/5) | Ops (4/5) | Comercial (3/5) |
|---|---|---|---|
| **Working Memory** | ✅ | ✅ | ✅ |
| **Episodic Memory** | ✅ | ✅ | ✅ |
| **Semantic Memory** | ✅ | ✅ | ✅ |
| **Procedural Memory** | ✅ | ✅ | ❌ |
| **Identity Memory** | ✅ | ❌ | ❌ |

Justificación de la gradación [D 09]:
- Ops omite Identity → evita overhead de pipeline de aprobación constitucional (comportamiento estandarizado fijo)
- Comercial omite Procedural e Identity → ~40% menos recursos de memoria · comportamiento fijo por contrato
- Ningún tier elimina WM + EM + SM → sin estos tres, el agente pierde coherencia, no aprende del usuario y no recupera conocimiento

---

**Paso 3 — Para cada sistema activo, generar la spec de implementación**

### Working Memory (WM) — todos los tiers [D 09 F2]

**Qué es:** context window activo + system prompt inyectado con user profile actualizado. Mantiene estado conversacional inmediato y perfil dinámico.

**Implementación:**
```typescript
// El system prompt se construye en cada turno:
const systemPrompt = [
  identityMemory.load(),          // CORE únicamente: CLAUDE.md versionado
  semanticMemory.retrieve(query, tier=1), // Tier 1 (sin costo LLM)
  episodicMemory.retrieve(query, userId, k=3), // Top-3 episodios relevantes
  userProfile                     // Perfil dinámico actualizado
].join('\n\n');
```

**Señal de fallo:** respuestas genéricas sin personalización · pierde coherencia intra-sesión. [D 09 F3]

---

### Episodic Memory (EM) — todos los tiers [D 09 F1 F2]

**Qué es:** tabla PostgreSQL + pgvector · almacena experiencias pasadas como embeddings · recuperación multi-señal.

**Recuperación híbrida:** semántica (cosine) 60% + recency decay 30% + signal_score 10%. [D 09 F2]

**Schema mínimo** (extraído de KB-D 09):
```sql
CREATE TABLE episodes (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  agent_id TEXT NOT NULL,
  user_id TEXT NOT NULL,
  session_id TEXT,
  role TEXT CHECK (role IN ('user','assistant','system','tool')),
  content TEXT NOT NULL,
  embedding VECTOR(1536),
  entities TEXT[],
  metadata JSONB DEFAULT '{}',
  signal_score FLOAT DEFAULT 0.0,
  created_at TIMESTAMPTZ DEFAULT NOW()
);
```

**Regla crítica:** append-only · NUNCA poda post-hoc de la query result → evita false memories. [D 09 F10]

---

### Semantic Memory (SM) — todos los tiers [D 09 F8]

**Qué es:** archivos markdown en Context Tree jerárquico `Domain → Topic → Subtopic → Entry`. Sin infraestructura externa. [D 09 ByteRover pattern]

**Recuperación 5 tiers (en orden de costo creciente):**
1. Exact filename match (< 5ms)
2. Keyword BM25 sobre filenames (< 20ms)
3. Scan de headers markdown (< 50ms)
4. Full-text interno sin LLM (< 100ms)
5. Síntesis con LLM (solo si tiers 1-4 fallan)

**Regla:** 80% de queries resueltas en tiers 1-4 sin costo LLM. [D 09 F8 F14]

**Layout:**
```
memory/semantic/
├── {dominio-principal}/
│   └── {topic}/
│       └── {subtopic}.md   # frontmatter: importance, maturity, updatedAt
```

---

### Procedural Memory (PM) — CORE y Ops [D 09 F24]

**Qué es:** skills almacenados como archivos markdown con frontmatter + skill router behavior-trainable.

**Mejora medida:** Memento-Skills pattern → +26.2% en General AI Assistants benchmark. [D 09 F24]

**Estructura de skill:**
```markdown
---
id: skill_{nombre}
version: 1.0.0
router_patterns: ["patrón1", "patrón2"]
success_rate: 0.90
last_reflection: {ISO8601}
maturity: seed|sprout|evergreen
---
# Skill: {nombre}

## Trigger
## Preconditions
## Steps
## Reflection Log
```

**Routing:** score = patternScore × 0.4 + contextScore × 0.3 + successRate × 0.3

**Reflective Learning:** si outcome.success < threshold → patchSkill() → append al Reflection Log. [D 09 F15 F24]

---

### Identity Memory (IM) — CORE únicamente [D 09 F22 F35]

**Qué es:** `CLAUDE.md` versionado en git · define comportamiento invariante · anti-drift guardrails.

**Pipeline de aprobación obligatorio:** cualquier diff constitucional → canal de aprobación humano (ej. Telegram) → ACK antes de commit a main. Este gate es la única defensa confiable contra Agent Drift. [D 09 F22]

**Template base** (inyectado en system prompt de cada turno):
```markdown
# IDENTITY · AGENT_ID: {UUID}
version: {SEMVER}
approved_by: {APPROVER_USER_ID}
last_constitution_update: {ISO8601}

## Role Constitution
[rol · objetivo · invariantes]

## Tool Preferences & Fallback Chain
## Memory Integration Rules
## Anti-Drift Guardrails
## Version Changelog
```

**Actualización constitucional:** pipeline ALAS — retrieval web → QA data → eval → aprobación humana. [D 09 F35]

---

**Paso 4 — Generar `memory_spec.md` para el agente**

Documento que S6 usará para construir los archivos de memoria del agente nuevo.

**Paso 5 — Guardar checkpoint S5**
```python
await checkpoint.save_stage(5, {
    "result": {
        "tier": tier,
        "systems_active": systems_list,
        "memory_spec_path": "runs/<run_id>/memory_spec.md"
    },
    "metadata": {"model": "<snapshot que uses>", "duration_s": elapsed},
    "summary": f"Patrón 5 · tier={tier} · {len(systems)} sistemas · {'/'.join(systems)}"
})
```

---

## 3 · Output

`runs/<run_id>/memory_spec.md`:

```markdown
# Memory Strategy · <nombre-agente>
Tier: {CORE | Ops | Comercial}
Patrón: Patrón 5 de Memoria [D 09]

## Sistemas activos ({N}/5)
- [x] Working Memory
- [x] Episodic Memory (PostgreSQL + pgvector)
- [x] Semantic Memory (Context Tree ByteRover)
- [x] Procedural Memory (Memento-Skills)    ← CORE/Ops
- [x] Identity Memory (CLAUDE.md + git)     ← CORE only

## Implementación por sistema
[schemas SQL · paths filesystem · routing logic · reflection hooks]

## Gradación justificada
Tier {tier}: {razón en 1 línea}
No se eliminaron WM/EM/SM (regla invariante del patrón).

## Anti-patterns de memoria a evitar
1. Catastrophic forgetting → no hacer fine-tuning de pesos LLM [D 09]
2. Sycophancy drift → reasoning model para decisiones normativas [D 09 F26]
3. Memory bloat → compresión de episodic buffer [D 09 F12]
4. False memories → append-only + no poda post-hoc [D 09 F10]
```

---

## 4 · Modelo

**Modelo rápido y capaz (ej. Claude Sonnet) con cache** · la spec de memoria es altamente repetitiva entre agentes → cache hit garantizado.

Justificación: los 5 sistemas tienen estructura canónica (KB-D 09 es la fuente) · un modelo rápido aplica la estructura al contexto específico del agente · no requiere razonamiento de un modelo fuerte tipo Opus. [SPEC.md §4]

Lánzalo como sub-agente en ventana limpia con la herramienta Task, pasándole solo la spec del agente + la variante de tier del patrón + el prompt de estrategia de memoria.

---

## 5 · Nota de ejecución

Corre sobre tu Claude Code (plan Max/Pro o API propia); no hay cobro aparte. Es 1 llamada con cache, reutilizando la KB-D ya cacheada desde S2.

---

## 6 · Validación

- [ ] `memory_spec.md` existe con tier declarado y sistemas activos listados
- [ ] WM + EM + SM siempre presentes (invariante del patrón)
- [ ] Si CORE: PM + IM presentes con schemas y paths
- [ ] Si Ops: PM presente · IM ausente con justificación
- [ ] Si Comercial: PM + IM ausentes con justificación
- [ ] Schema SQL de episodes documentado con `VECTOR(1536)` y recuperación híbrida
- [ ] Path de Semantic Memory (`memory/semantic/Domain/Topic/`) documentado
- [ ] Si CORE: pipeline de aprobación humano para Identity Memory documentado
- [ ] 4 anti-patterns de memoria documentados
- [ ] `checkpoint stage_5.json` guardado
- [ ] **Listo para GATE 2**

---

## 7 · Fallback

| Falla | Acción |
|---|---|
| Tier no declarado en S1 | Preguntar al usuario antes de continuar (no asumir) |
| PostgreSQL/pgvector no disponible en stack | Warning: "EM requiere PostgreSQL · usar fallback JSONL local con cosine similarity aproximado" · documentar limitación |
| Tier CORE sin canal de aprobación configurado para IM | Warning: "Identity Memory requiere un canal de aprobación humano (ej. bot Telegram) · documentar cómo configurarlo en el agente generado" |
| KB-D no accesible en S5 | Usar esquemas desde `CLAUDE.md §MEMORIA POR TIER` como fallback |
| Stack incompatible con pgvector | Fallback documentado: pgvector → SQLite-vss → JSONL simple |

---

## 8 · Anti-patterns · Nunca hacer aquí

- ❌ Eliminar EM o SM de cualquier tier → el agente no aprende del usuario y no recupera conocimiento [D 09]
- ❌ Construir Identity Memory sin pipeline de aprobación humano → Agent Drift desde el primer día [D 09 F22]
- ❌ Usar fine-tuning de pesos LLM para actualizar memoria → catastrophic forgetting [D 09 F25]
- ❌ Top-k retrieval fijo en EM → false memories por poda de prerequisitos temporales [D 09 F10]
- ❌ Ignorar el tier declarado en S1 para "dar más features" → viola gradación de governance [D 09]
- ❌ Subestimar overhead de Identity Memory en CORE → la aprobación humana es el gate más lento

---

## GATE 2 · ARQUITECTURA (post-S5 · Plan Mode)

Presentar al usuario para aprobación:

```
🛑 GATE 2 · ARQUITECTURA

Agente propuesto: {nombre}
Tier:             {CORE | Ops | Comercial}
Patrón:           {patrón arquitectural}
Pipeline:         {N} stages · {M} sub-agentes
Stage Isolation:  {K} stages en ventana limpia
Memoria:          {N}/5 sistemas ({lista})
  Working Memory: ✅
  Episodic (pgvector): ✅
  Semantic (ByteRover): ✅
  Procedural (Memento): {✅|❌}
  Identity (CLAUDE.md): {✅|❌}

Opciones:
  ✅ Aprobar · continuar a S6 (Code Generation)
  ✏️  Ajustar tier o memoria · volver a S5
  ❌ Cancelar run
```

Si `auto_approve_gates=true` → GATE se salta automáticamente · registrar en receipt.

---

## Mensaje al usuario al terminar

```
✅ Stage 5 · Memory Strategy OK
   Tier:               {CORE | Ops | Comercial}
   Sistemas activos:   {N}/5 ({lista})
   WM:                 ✅ (invariante)
   EM (pgvector):      ✅ (invariante)
   SM (ByteRover):     ✅ (invariante)
   PM (Memento):       {✅|❌}
   IM (CLAUDE.md):     {✅|❌}

   ⏸ GATE 2 en espera · revisa arquitectura + memoria arriba...
```
