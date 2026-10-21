# Operaciones, Costos y Decisión Build vs Buy

## 1. Proyección de Costos de Memoria Continua: Compute, Storage y Tokens

El costo total de propiedad de la memoria de agentes se descompone en tres vectores acoplados: infraestructura de cómputo, persistencia de datos (vectorial, estructurada o filesystem) y consumo de tokens de contexto en cada llamada al LLM. En el extremo del ahorro absoluto, ByteRover demuestra viabilidad productiva con cero infraestructura externa —sin vector DB, sin graph DB, sin embedding service— persistiendo la memoria episódica en archivos markdown sobre el filesystem nativo mediante un Context Tree jerárquico (Domain → Topic → Subtopic → Entry) con Adaptive Knowledge Lifecycle; esto reduce el costo de memoria a prácticamente cero dólares más allá del compute del LLM, resolviendo la mayoría de queries en menos de 100ms [F8]. Esta arquitectura desafía la suposición de que la memoria de agentes requiere obligatoriamente bases de datos especializadas [F8]. Si, por política o complejidad, el equipo requiere stack tradicional, existe una vía de costo marginal cercano a cero:

> ⚠️ INFERENCIA: Oracle Always Free ARM ofrece 4 OCPU Ampere A1 y 24GB RAM permanentemente gratuitos; para una flota de 12 agentes con aproximadamente 500MB de memoria cada uno (~6GB totales en pgvector), el costo de storage extra se proyecta en ~$0.15/mes, mientras que OpenAI text-embedding-3-small cotiza ~$0.02 por millón de tokens, arrojando una proyección anual por debajo de 5 USD totales en memoria para 12 agentes, siendo el compute del LLM el dominante absoluto del costo [F31].

Paralelamente, la optimización algorítmica impacta directamente la factura del LLM: MemPO reduce el consumo de tokens de memoria en un 73.12% respecto al baseline SOTA mientras mejora el F1 score en 25.98% sobre el modelo base, lo que se traduce en una reducción de aproximadamente 73% en costo por llamada para agentes con memoria activa [F32]. Esto es crítico porque, como formaliza el survey de Du (2026), la memoria autónoma opera bajo un ciclo write-manage-read donde la compresión context-resident y la gestión aprendida por política determinan el volumen de tokens inyectados en cada inferencia [F7]. En ese sentido, un agente que no comprima su memoria está quemando dinero en cada step, independientemente de si corre en servidor propio o en la nube.

| Componente | Costo estimado (12 agentes, 12 meses) | Driver principal |
|---|---|---|
| Compute (Oracle ARM Free Tier) | $0 | 4 OCPU + 24GB RAM permanentes [F31] |
| Storage extra (pgvector) | ~$1.80/año | ~$0.15/mes por encima del tier gratuito [F31] |
| Embeddings (OpenAI small) | ~$2-3/año | ~$0.02/M tokens [F31] |
| Tokens de contexto (LLM) | Dominante | Variable según compresión (MemPO -73%) [F32] |

**Implicaciones para Smart4AI:** Para la fase inicial, el costo de memoria es un redondeo respecto al compute del LLM; la decisión debe privilegiar la arquitectura que minimice tokens de contexto y elimine servicios gestionados de pago, usando compute gratuito o filesystem local. Tenga presente que la proyección de menos de 5 USD anuales depende de mantenerse dentro de los límites del Always Free Tier y de un perfil de embedding ligero; cualquier exceso en tráfico de tokens puede pulverizar ese presupuesto en horas.

Si te llevas UNA cosa: El storage de memoria puede costar casi cero si se eliminan las bases de datos vectoriales pagas, pero el verdadero golpe financiero está en los tokens de contexto que se envían al LLM en cada llamada.

## 2. Build vs Buy: Modalidades de Despliegue y Control Operativo

La decisión de construir o comprar no es binaria sino un espectro de control operativo que va desde una librería embebida hasta un SaaS gestionado. Mem0 ofrece tres modos de despliegue —Library (pip install, para testing), Self-Hosted (docker compose, infraestructura propia) y Cloud (app.mem0.ai, producción sin ops)— que permiten migrar progresivamente sin reescribir código, aprovechando sus tres capas de memoria (User Memory, Session Memory, Agent Memory) y recuperación multi-señal que puntuada en paralelo combina semántica, BM25 keyword y entity matching [F2]. Para Smart4AI v1 single-user, el modo Self-Hosted es el recomendado porque garantiza control total, privacidad de datos y cero tarifa SaaS [F2]. En el otro extremo del espectro técnico, Cognee propone un approach híbrido único que combina embeddings, knowledge graph y principios de ciencia cognitiva, superando a los frameworks puramente vectoriales; ofrece seis opciones de deployment (Cloud, Modal, Railway, Fly.io, Render, Daytona) que cubren desde edge computing hasta serverless [F6]. Para Smart4AI v2 multi-tenant, la combinación Cognee + Modal con auto-scaling representa un stack diferenciado que escala por uso sin mantener clusters subutilizados [F6].

| Dimensión | Mem0 Self-Hosted | Cognee + Modal | ByteRover FS |
|---|---|---|---|
| Costo infraestructura | $0 (propio) | Variable (serverless) | $0 |
| Costo operación | Alto (ops propio) | Bajo (auto-scaling) | Mínimo |
| Modelo memoria | 3 capas, multi-señal [F2] | Híbrido (embed+KG) [F6] | Context Tree + AKL [F8] |
| Escalabilidad | Manual/K8s | Serverless auto-scaling | Single-node |
| Ideal Smart4AI | v1 single-user | v2 multi-tenant | v1 edge/offline |

**Implicaciones para Smart4AI:** La versión 1 debe bloquearse en Self-Hosted Mem0 o ByteRover para evitar lock-in y facturas recurrentes; la versión 2 debe evaluar Cognee sobre Modal si el conocimiento relacional entre tenants justifica el knowledge graph y el costo serverless. Usted no debería pagar por un SaaS de memoria hasta que el tráfico multi-tenant haga imposible justificar el tiempo de ops propio.

Si te llevas UNA cosa: El espectro Library→Self-Hosted→Cloud permite postergar la decisión