# Categoría 3 · Pipeline Robustness y Agent Lifecycle
> Sub-preguntas: A4 (anti-saturación), A3 (versionado y lifecycle)

---

## A4 · Pipeline Robusto anti-Saturación de Contexto [CRÍTICO para ALAN]

> ALAN se satura hoy. Este bloque es el más urgente para v2.0.

### Por qué los pipelines largos fallan
- Doubling la duración de un pipeline cuadruplica la tasa de fallos [F16]
- La saturación de contexto es el desafío de ingeniería #1 para agentes en producción [F16]
- No se soluciona "dando más contexto" — la degradación es no-lineal

### Las 4 estrategias anti-saturación (en orden de aplicación)

#### Estrategia 1: Checkpointing por Stage
[F16] Patrón obligatorio para pipelines multi-stage.

| Tipo | Descripción | Tool |
|---|---|---|
| Checkpoint por Stage | Serializar estado completo al finalizar cada stage | LangGraph, Temporal Workflows |
| Checkpoint Comprimido | Solo estado esencial + resumen comprimido del historial (ahorra 60-70%) | Implementación custom |
| TTL-based Expiration | Eliminar checkpoints viejos automáticamente (ej. 7 días) | `ttl_seconds=86400*7` |

```python
# Patrón de checkpoint por stage para ALAN
class PipelineCheckpoint:
 def __init__(self, run_id: str, storage: ExternalStorage):
 self.run_id = run_id
 self.storage = storage
 
 async def save_stage(self, stage: int, state: dict):
 compressed = self._compress(state)
 await self.storage.put(f"{self.run_id}/stage_{stage}", compressed)
 
 async def load_last_valid(self) -> tuple[int, dict]:
 stages = await self.storage.list(f"{self.run_id}/stage_*")
 if not stages: return 0, {}
 last = max(stages, key=lambda s: int(s.split("_")[-1]))
 return int(last.split("_")[-1]), await self.storage.get(last)
 
 def _compress(self, state: dict) -> dict:
 # Mantener solo: resultado final del stage + metadata crítica
 # Descartar: historial de conversación raw, tool outputs intermedios
 return {
 "result": state.get("result"),
 "metadata": state.get("metadata"),
 "summary": self._summarize(state.get("conversation", []))
 }
```

#### Estrategia 2: Context Compression
[F16] Aplicar jerárquicamente cuando el contexto se acerca al límite:

1. **Tool result clearing**: Eliminar resultados de herramientas una vez consumida la información relevante
2. **Resumen de conversación**: Reemplazar historial antiguo con resumen condensado (decisiones clave)
3. **Extracción de memoria de sesión**: Extraer hechos permanentes a memoria separada
4. **Truncamiento gradual**: Eliminar los mensajes más viejos primero

> Claude Code implementa estas 5 estrategias simultáneamente en producción [F16]

#### Estrategia 3: Stage Isolation (la más importante para ALAN)
[F16] La solución correcta cuando una tarea excede genuinamente el context window:

| Enfoque | Beneficio | Cuándo usar |
|---|---|---|
| Multi-agent architecture | Cada sub-agente tiene ventana limpia y scope estrecho | Tareas complejas con sub-problemas diferenciados |
| Context window reset entre stages | Elimina "ruido" de stages anteriores | Pipeline secuencial donde stages son independientes |
| Scoped context por agente | Cada agente ve solo contexto relevante a su tarea | Workflows con agentes especializados |

**Regla de oro**: No "agotar más contexto" — dividir el trabajo. Asignar sub-agentes especializados con ventana limpia.

#### Estrategia 4: Recovery from Failures
[F16] Para pipelines que fallan inevitable:
- **Reinicio desde checkpoint**: cargar último estado válido, no desde el inicio
- **Reintentos con backoff exponencial** (500ms → 2s → 8s) para fallos temporales de API
- **Human-in-the-loop triggers**: para operaciones críticas, requerir confirmación antes de reanudar
- **Versionado de datos + rollback**: permitir volver a versiones anteriores del pipeline

### Patrón integrado de producción para ALAN v2.0

```
[Stage N] → Ejecutar → Checkpoint estatal → Comprimir historial
 ↓
 [¿Excede 80% del context window?]
 → SÍ → Resumir + Extraer memoria persistente
 → Aislar: nuevo sub-agente con ventana limpia
 ↓
 [¿Fallo?]
 → SÍ → Cargar último checkpoint válido
 → Reintentar con backoff exponencial
 → Si 3 fallos consecutivos → alertar + STOP
```

**Herramientas 2026**: LangGraph (checkpointing nativo), Temporal (workflows distribuidos), Redis (estado compartido efímero) [F16]

**Implicación ALAN v2.0**: ALAN v2.0 debe implementar checkpointing entre sus stages 0-12 usando almacenamiento externo (Redis o filesystem). El problema actual de saturación se resuelve con: (1) reset de contexto entre stages, (2) cada Stage que "llama a Claude" usa un sub-agente con ventana fresca, (3) solo el resultado final del stage se pasa al siguiente.

---

## A3 · Versionado y Lifecycle de Agentes Generados

### Hybrid SemVer para Agentes (2026 standard)
[F17] El versionado de agentes no es solo código — es código + prompts + modelo + tool schemas + output schemas.

```
MAJOR.MINOR.PATCH donde:
- MAJOR: Breaking changes en behavior/output schema O nuevo modelo base
- MINOR: Nuevas features backward-compatible O mejoras de prompt
- PATCH: Bug fixes O tweaks de prompt menores

Version ID completo: v{MAJOR}.{MINOR}.{PATCH}+{prompt_git_hash}+{model_snapshot}
Ejemplo: v1.3.2+a4f2b91+claude-sonnet-4-6-20260501
```

Adiciones críticas sobre SemVer tradicional [F17]:
- **Pin exact model versions** (no "claude-sonnet-4-6" genérico, sino snapshot fechado) — los silent model upgrades son la causa #1 de breakage
- **Incluir prompt git commit hash** en el version ID
- **Attachar eval scorecard** en el momento de deploy
- **Semantic changelog** documentando cambios de comportamiento, no solo de código

### Estrategia de Rollback [F17]

| Componente | Estrategia | Tiempo de rollback |
|---|---|---|
| Prompts | Prompt versioning tools (LangSmith, Langfuse, PromptLayer) con feature flags | Segundos |
| Modelo | Pin de versiones; nunca usar alias dinámicos como "latest" | Instantáneo |
| Código | Immutable deployments — cada deploy tiene ID único | Segundos via flag |
| Agente completo | Feature flags para A/B antes de full cutover | Instantáneo |

**Trigger de rollback automático** [F17]:
- Capa offline: golden test set en cada deploy; CI bloquea si hay regresiones
- Capa online: trazas de producción muestreadas y scoring por LLM judge en dashboard
- Alertas: si TSR cae >5% o hallucination rate sube >10%, rollback automático

### Canary Deployments para Agentes [F17]

```
Step 1: Definir métricas de éxito con baselines (latency, error rate, cost/task)
Step 2: Iniciar con 1-5% del tráfico (Nginx/Envoy routing)
Step 3: Monitorear 2-4 horas
Step 4: Si estable → escalar a 10% → 25% → 50% → 100%
Step 5: Plataforma de governance compara compliance/quality/cost vs baseline
Step 6: Si regresión en cualquier métrica → rollback automático
```

### A/B Testing de Versiones de Agentes [F17]
- Correr versiones old y new en paralelo, comparar outputs
- Métricas: latency baseline, error rate, CPU use, output quality (LLM judge), cost/successful task
- Cambiar a nueva versión cuando confidence en mejora es alta (ej. p<0.05 en prueba estadística)

### Deprecación y Compatibilidad [F17]
- **Compatibility matrix**: trackear qué versiones de agente funcionan juntas explícitamente
- **Schema-first versioning**: los agentes declaran qué schema versions soportan
- **In-flight workflow migrations**: workflows de horas pueden abarcar múltiples versiones — usar converters automáticos entre schemas
- Tratar el sistema como package manager: composiciones enteras versionen juntas

### Naming convention para outputs de agentes [F17]
```
{agente}_{propósito}_v{MAJOR}_{fecha}_{run_id}.{ext}
Ejemplo: alan_brief-extractor_v1_2026-05-29_run123.json
```

**Implicación ALAN v2.0**: Cada agente generado por ALAN debe recibir un version ID completo desde su creación, con prompt hash + model snapshot. El receipt de ALAN debe incluir esta metadata para auditabilidad CFO-grade.

**Si te llevas UNA cosa**: El silent model upgrade es la causa #1 de regresión inesperada en agentes. Pin siempre el modelo exacto con snapshot fechado, nunca alias dinámicos.
