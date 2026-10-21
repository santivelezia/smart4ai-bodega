> **Publicada por Smart4AI · 2026-06-27 · licencia CC BY-NC 4.0** (puedes usarla y adaptarla sin fines comerciales, dando crédito a Smart4AI). Versión pública: se quitaron solo referencias internas.

# Marco Teórico — Estado del arte de la investigación rigurosa

> **Objetivo:** destilar las mejores prácticas metodológicas (no la arquitectura técnica de agentes) para elevar el skill/agente investigador, con base académica real y cada hallazgo convertido en una **heurística operativa pegable en un prompt**.
> **Fecha:** 2026-06-27 · **Idioma:** es-CO
> **Método:** patrón orquestador-worker. 5 sub-investigadores en paralelo (uno por framework), cada uno obligado a traer fuente **fundacional Y crítica**, fechar, verificar URLs con fetch y declarar el nivel de evidencia honestamente. Síntesis transversal + recomendaciones por el orquestador (Claude).
> **Honestidad de alcance:** esto NO es "investigación en general" — está anclado a 5 frameworks nombrados y verificables. Donde la evidencia de efectividad es débil, se dice.

---

## ⭐ Resumen ejecutivo — el ranking por evidencia (lo más importante)

No todos los frameworks valen lo mismo. Ordenados por **evidencia empírica de que de verdad mejoran la calidad del análisis**:

| # | Framework | Evidencia de efectividad | Qué hacer con él |
|---|---|---|---|
| 1 | **Calibración (Tetlock / GJP)** | **FUERTE** — torneo multi-año; +50% sobre control; superpronosticadores ~30% mejores que analistas con info clasificada; efecto de entrenamiento persistente | **Adoptar a fondo.** Mayor ROI. |
| 2 | **Lateral reading (núcleo de SIFT)** | **FUERTE** — estudios de Wineburg con datos; intervención llevó lateral reading espontáneo de 3/87 → 67/87 estudiantes | **Adoptar a fondo.** Alto ROI. |
| 3 | **GRADE / jerarquías de evidencia** | **Convención consensuada, NO probada como superior** en outcomes; su valor es estructural (separar certeza de fuerza) | Tomar la **estructura**, no el ranking médico. |
| 4 | **PRISMA / búsqueda reproducible** | **Moderado para transparencia; débil para "mejor precisión"** — es estándar de *reporte*, no intervención probada | Quedarse con el **ledger** (casi gratis); el resto, opt-in por riesgo. |
| 5 | **ACH (la matriz formal)** | **DÉBIL / NEGATIVA** — varios experimentos (Mandel et al. 2018-2024) + RAND: poco o ningún beneficio, a veces daño | Conservar solo el **espíritu** (hipótesis múltiples + buscar refutación); descartar la matriz pesada. |

**Si te llevás UNA cosa:** invertí en **calibración** y **lateral reading** (evidencia fuerte), usá la **estructura** de GRADE (separar certeza/fuerza), conservá un **ledger** de búsqueda estilo PRISMA, y quedate con el **espíritu** de ACH (no la matriz). El movimiento senior aquí es *acotar*: estos 5, bien destilados, cierran el 20% que faltaba.

---

## Las 5 fichas

### 1. Analysis of Competing Hypotheses (ACH) y SATs
- **Qué es:** Las *Structured Analytic Techniques* (SATs) de la comunidad de inteligencia son métodos paso a paso para externalizar y disciplinar el razonamiento y mitigar sesgos (Heuer 1999; Heuer & Pherson 2010). ACH es la insignia: en vez de buscar apoyo para la hipótesis favorita, se listan TODAS las hipótesis plausibles y se confrontan en una matriz (hipótesis × evidencia), priorizando la evidencia **diagnóstica** (la que distingue entre hipótesis) y refutando las que acumulan inconsistencias.
- **Qué problema resuelve que el skill típico NO aborda:** el cierre prematuro y el sesgo de confirmación — fijar una respuesta temprano y luego solo buscar lo que la apoya. Fuerza a competir hipótesis en paralelo y razonar por *eliminación*.
- **Heurísticas operativas:**
  1. **Competí hipótesis, no las confirmes:** "Cuando haya 2+ explicaciones plausibles, listalas como hipótesis mutuamente excluyentes ANTES de concluir. Por cada evidencia preguntá: ¿es consistente con varias hipótesis (poco diagnóstica) o solo con una (diagnóstica)? Concluí por la evidencia diagnóstica y por qué hipótesis tiene más evidencia *inconsistente*, no por cuál tiene más apoyo."
  2. **Buscá lo que te refutaría:** "Por cada afirmación clave, generá explícitamente el dato que la *desmentiría* y andá a buscarlo. Si no podés imaginar qué dato cambiaría tu conclusión, marcala como posible sesgo de confirmación."
  3. **Key Assumptions Check + Premortem (rápido):** "Antes de cerrar: (a) listá los supuestos no verificados de los que depende la conclusión y marcá los que la tumbarían si fueran falsos; (b) 'asumí que esta conclusión resultó equivocada en 6 meses, ¿cuál fue la causa más probable?' y corregí."
  - *Otras SATs (1 línea):* **Key Assumptions Check** = explicitar/cuestionar supuestos base. **Premortem** = imaginar el fracaso y deducir por qué. **Devil's Advocacy** = construir el mejor caso CONTRA tu conclusión. **What-If** = asumir un evento improbable y razonar causas/consecuencias.
- **Nivel de evidencia:** **Convención sin prueba; para ACH, evidencia NEGATIVA.** RAND (Artner, Girven & Bruce 2016) documentó que las SATs casi no tienen validación empírica. Para ACH: Wilcox & Mandel (2024) revisaron 6 experimentos → "poco o ningún beneficio sobre la calidad del juicio, y puede dañarlo"; Dhami, Belton & Mandel (2019) → no redujo confirmación y aumentó inconsistencia; Mandel, Karvetski & Dhami (2018) → no mejoró precisión (el control rindió algo mejor). *Matiz:* sí hay soporte parcial para brainstorming y devil's advocacy, no para la matriz ACH.
- **Límites / cuándo NO aplicarlo:** la matriz formal es costosa y su beneficio no está probado; sobre-ingeniería para preguntas simples. Nació para geopolítica con evidencia escasa/ambigua y adversarios que engañan; transfiere mal a tareas con datos abundantes y verificables (ahí conviene medir directo + ponderación bayesiana). **Destilación:** quedate con el espíritu (hipótesis múltiples + refutación + supuestos), descartá la matriz salvo casos genuinamente ambiguos y de alto riesgo.
- **Fuentes clave (verificadas):** Heuer (1999) *Psychology of Intelligence Analysis*, CIA — https://www.cia.gov/resources/csi/books-monographs/psychology-of-intelligence-analysis-2/ · Heuer & Pherson (2010) *Structured Analytic Techniques*, CQ Press · Dhami, Belton & Mandel (2019), *Applied Cognitive Psychology* 33(6) · Mandel, Karvetski & Dhami (2018), *Judgment and Decision Making* 13(6) · Karvetski & Mandel (2020), *JDM* 15(6) · Wilcox & Mandel (2024), *Intelligence and National Security* 39(6) — https://doi.org/10.1080/02684527.2024.2304934 · Artner, Girven & Bruce (2016), RAND RR-1408 — https://www.rand.org/pubs/research_reports/RR1408.html

### 2. SIFT y Lateral Reading
- **Qué es:** SIFT (Caulfield 2019) = 4 movimientos para evaluar info online antes de creerla/citarla: **S**top, **I**nvestigate the source, **F**ind better coverage, **T**race claims to origin. Su técnica central es el *lateral reading* (Wineburg & McGrew): en vez de juzgar una fuente leyéndola por dentro (URL, diseño, "About"), **salís de la página** y averiguás en *otras* fuentes qué es ese emisor y si el claim está corroborado.
- **Qué problema resuelve que el skill típico NO aborda:** un investigador típico evalúa la fuente *desde dentro* (¿se ve seria, dominio .org/.edu?) — el error del no-experto. SIFT obliga a evaluar al emisor **desde afuera** y verificar contra el consenso de otras fuentes antes de leer en profundidad. Separa "¿qué es esto?" de "¿qué dice?".
- **Heurísticas operativas:**
  1. **Lectura lateral antes de citar:** "Antes de usar una fuente, abrí ≥2 fuentes independientes SOBRE el emisor/claim (no la fuente misma) y resolvé qué es y qué agenda tiene. Si no podés establecer qué es el emisor, no lo trates como evidencia."
  2. **Mejor cobertura, no la primera:** "Para un dato, ignorá la primera fuente que lo trae y buscá la mejor cobertura existente (la más autorizada o el consenso de varias). Reportá desde esa."
  3. **Rastreá al original:** "Rastreá todo claim/cifra/cita/imagen hasta su fuente ORIGINAL. Si solo hay reportes que se citan entre sí sin origen, marcá [no verificado / circular]."
  4. **Anti-anzuelo:** "Si una afirmación encaja demasiado bien con tu tesis o provoca reacción fuerte, SUBÍ el umbral de verificación (más fuentes, fuente primaria obligatoria)."
- **Nivel de evidencia:** **FUERTE para lateral reading** (SIFT es el envoltorio pedagógico). Wineburg & McGrew (2019, *Teachers College Record* 121): fact-checkers que leían lateralmente identificaban la fuente confiable en segundos mientras historiadores PhD y estudiantes —leyendo vertical— se dejaban engañar por logos/dominios. La transferibilidad por enseñanza está medida: Breakstone et al. (2021, *HKS Misinformation Review*, n=87) → lateral reading espontáneo 3/87 → 67/87 y puntaje 3.95 → 7.08/13 (p<.001). Los checklists tipo CRAAP mejoran el ranking de páginas aisladas pero NO la resistencia a desinformación.
- **Límites / cuándo NO aplicarlo:** el lateral reading puro **requiere búsqueda en vivo**. Un agente que SOLO lee texto pegado (sin WebSearch/WebFetch) no puede ejecutar SIFT de verdad — degrada a heurísticas internas (detectar circularidad, exigir primaria). Con herramientas de búsqueda SÍ es directamente implementable. No sustituye la evaluación metodológica *dentro* de un paper (eso es lectura vertical experta); SIFT es triage de credibilidad, no peer review.
- **Fuentes clave (verificadas):** Caulfield (2019) *SIFT (The Four Moves)* — https://hapgood.us/2019/06/19/sift-the-four-moves/ · Wineburg & McGrew (2019), *Teachers College Record* 121(11) · Breakstone et al. (2021), *HKS Misinformation Review* — https://misinforeview.hks.harvard.edu/article/lateral-reading-college-students-learn-to-critically-evaluate-internet-sources-in-an-online-course/

### 3. GRADE y Jerarquías de Evidencia
- **Qué es:** GRADE (GRADE Working Group, desde 2000; 120+ organizaciones) califica (a) la **certeza/calidad** de un cuerpo de evidencia (alta/moderada/baja/muy baja) y (b) la **fuerza de una recomendación** (fuerte/débil). Su rasgo definitorio: **separar explícitamente** ambos juicios. El diseño del estudio fija un punto de partida que luego sube o baja por factores nombrados.
- **Qué problema resuelve que el skill típico NO aborda:** colapsar "qué tan buena es la fuente" con "qué tan seguro estoy de la conclusión", y tratar el tipo de fuente como veredicto final en vez de punto de partida ajustable.
- **Heurísticas operativas:**
  1. **Separá dos campos siempre:** "En la salida, distinguí 'Certeza de la evidencia' (alta/moderada/baja) de 'Fuerza de la conclusión' (fuerte/tentativa). No los fusiones. Una conclusión fuerte puede salir de evidencia débil y viceversa: nombralo cuando pase."
  2. **Nivel de partida + ajuste nombrado:** "Asigná un nivel por tipo de fuente y ajustalo escribiendo el motivo. Bajá por (riesgo de sesgo / inconsistencia / evidencia indirecta o no transferible / imprecisión / sesgo de selección). Subí por (efecto muy grande / dosis-respuesta / sesgos jugarían en contra y aun así aparece). Ej.: 'Baja certeza (-1 indirecta: otro mercado; -1 fuente única)'."
  3. **Recomendación = más que evidencia:** "Al recomendar, declará balance de pros/contras, certeza, variabilidad de valores del decisor y costo. Si el balance es estrecho, marcala 'tentativa/discrecional'."
- **Nivel de evidencia:** **Convención consensuada, NO probada como superior en resultados.** Estándar de facto en medicina, pero eso mide legitimidad, no que produzca mejores decisiones que otro método; los propios autores reconocen que no garantiza consistencia. Su valor defendible es **estructurante y de transparencia**, no superioridad demostrada.
- **Límites / cuándo NO aplicarlo:** **transferible = la estructura** (separar certeza/fuerza; certeza ajustable; directa vs indirecta; juicio explícito). **NO transferible = el ranking médico** ("RCT en la cima" supone pregunta de eficacia causal con outcome medible; en mercado/tecnología muchas preguntas son descriptivas/predictivas donde un buen estudio de campo tiene mejor validez externa). No copies los niveles médicos a fuentes web heterogéneas: redefinilos.
- **Fuentes clave (verificadas):** Guyatt et al. (2008) *GRADE: an emerging consensus...*, BMJ — https://pmc.ncbi.nlm.nih.gov/articles/PMC2335261/ · GRADE Working Group — https://www.gradeworkinggroup.org/ · OCEBM Levels of Evidence (2011), Oxford CEBM — https://www.cebm.ox.ac.uk/resources/levels-of-evidence/ocebm-levels-of-evidence

### 4. Calibración de Incertidumbre (Tetlock / Superforecasting)
- **Qué es:** expresar la confianza como **probabilidad numérica explícita** y verificar empíricamente si acierta (cuando decís 70%, ocurre ~70% de las veces). Surge del Good Judgment Project (GJP) de Tetlock y Mellers, que ganó el torneo de IARPA (2011-2015) identificando "superpronosticadores" medibles y entrenables. Se mide con el Brier score (0 = perfecto).
- **Qué problema resuelve que el skill típico NO aborda:** el skill marca confianza "alto/medio/bajo" como etiqueta subjetiva sin metodología ni forma de saber si miente. La calibración la vuelve una probabilidad falsable y auditable.
- **Heurísticas operativas:**
  1. **Empezá por la tasa base:** "Antes de estimar, preguntá '¿con qué frecuencia ocurre algo así en situaciones así?' (outside view / clase de referencia) y partí de ese número; recién después ajustá por el caso." *(En el GJP fue la técnica de mayor ganancia: Brier 0.17 vs 0.26.)*
  2. **Probabilidad numérica, no palabra vaga:** "Reemplazá 'probable/posible' por un %, con granularidad fina (distinguí 65% de 75%, no redondees a 50/50). Redondear destruía la ventaja de los superpronosticadores."
  3. **Fermi + actualización incremental:** "Descomponé la pregunta en sub-estimaciones, asigná un número a cada una y combiná. Ante evidencia nueva, movete en incrementos (0.60 → 0.65), sin anclarte ni saltar a 0/100."
  4. **Autoevaluación Brier:** "Registrá predicción + % y, al resolverse, calculá el error; detectá sesgo sistemático ('siempre digo 90% y acierto 70%' → sobreconfianza)."
- **Nivel de evidencia:** **FUERTE (para humanos).** GJP: torneo competitivo multi-año; el equipo Good Judgment superó al control en >50%; top ~30% más precisos que analistas con info clasificada; consistencia año a año (~0.65) descarta azar; entrenamiento de ~1h con efecto ≥1 año. *Matiz:* predecir *quién* será buen pronosticador es solo moderado (~0.64, Mellers et al. 2015). **En LLMs la calibración NO está resuelta** (tienden a sobreconfianza) → es disciplina de autoevaluación, no garantía.
- **Límites / cuándo NO aplicarlo:** no transfiere bien entre dominios sin feedback específico; requiere preguntas resolubles con horizonte acotado (para colas gruesas/cisnes negros pierde tracción — crítica de Taleb); riesgo de falsa precisión (un "73%" sobre aire es peor que un "no sé" honesto).
- **Fuentes clave (verificadas):** Tetlock & Gardner (2015) *Superforecasting* · Mellers et al. (2015), *Perspectives on Psychological Science* 10(3) — https://faculty.wharton.upenn.edu/wp-content/uploads/2015/07/2015---superforecasters.pdf · AI Impacts, síntesis del GJP (cifras de Brier) — https://aiimpacts.org/evidence-on-good-forecasting-practices-from-the-good-judgment-project/ · Good Judgment "Ten Commandments" — https://fs.blog/ten-commandments-for-superforecasters/

### 5. PRISMA / Investigación Reproducible
- **Qué es:** PRISMA 2020 (Page et al., *BMJ* 2021) es una guía de **reporte** (no de ejecución) para revisiones sistemáticas: checklist de 27 ítems + diagrama de flujo. Exige documentar fuentes consultadas, la *search strategy* completa (queries por base), criterios de inclusión/exclusión, y el flujo de cuántos registros se identificaron/descartaron y por qué. La metodología hermana (systematic/scoping review; Arksey & O'Malley 2005) aporta el *cómo conducir*.
- **Qué problema resuelve que el skill típico NO aborda:** la **reproducibilidad y la trazabilidad del descarte** — un agente típico reporta lo que encontró pero oculta qué buscó, qué ignoró y por qué, haciendo imposible auditar sesgo de selección.
- **Heurísticas operativas:**
  1. **Ledger de búsqueda:** "Registrá cada query ejecutada (texto exacto + fuente) y, por cada fuente relevante descartada, el motivo (off-topic, sin fecha, baja autoridad, duplicada). La búsqueda debe poder reproducirse desde el ledger."
  2. **Criterios I/E explícitos antes de buscar:** "Declará criterios de inclusión/exclusión (recencia, tipo de fuente, idioma, autoridad) ANTES y aplicalos consistentemente; no decidas relevancia ad hoc."
  3. **Conteo de flujo:** "Reportá N encontradas → N revisadas → N usadas, con motivos de exclusión agregados. Que el lector vea qué quedó afuera."
- **Nivel de evidencia:** **Moderado para transparencia/reproducibilidad; débil para 'mejor precisión'.** Es estándar de reporte consensuado, no intervención con RCTs que demuestren conclusiones "más correctas". Su valor probado es completitud/auditabilidad.
- **Límites / cuándo NO aplicarlo:** para investigación rápida/exploratoria/de baja consecuencia, la maquinaria completa es sobre-ingeniería (una revisión sistemática real tarda 6 meses-2 años; los *rapid reviews* legitiman recortar). **Regla: escalá el rigor a la consecuencia.** El **ledger de queries/descartes vale la pena SIEMPRE** (casi gratis); criterios I/E + conteo de flujo, opt-in según riesgo (decisión costosa/legal/financiera/citada por terceros).
- **Fuentes clave (verificadas):** Page et al. (2021) *PRISMA 2020 statement*, BMJ 372:n71 — https://pubmed.ncbi.nlm.nih.gov/34446261/ · *PRISMA 2020 explanation & elaboration*, BMJ 372:n160 — https://www.prisma-statement.org/prisma-2020-explanation-elaboration · Arksey & O'Malley (2005), scoping framework

---

## Síntesis transversal

### Heurísticas que se REPITEN entre frameworks (señal de robustez)
Cuando técnicas independientes convergen, la heurística es robusta. Tres convergencias fuertes:
1. **"Buscá lo que te refutaría" (anti-confirmación).** Aparece en ACH (evidencia diagnóstica/inconsistente), SIFT (anti-anzuelo), y calibración (evitar sobreconfianza). → **La heurística más robusta de todas.**
2. **"Salí de la fuente / mirá desde afuera".** SIFT (lateral reading: juzgar al emisor desde otras fuentes) y Tetlock (outside view: partir de la clase de referencia, no de la impresión interna). → Mismo principio en credibilidad y en estimación.
3. **"Separá dos cosas que se confunden".** GRADE (certeza de evidencia vs. fuerza de conclusión) y los skills de investigación típicos (nivel de fuente vs. confianza del hallazgo). → Convergente; GRADE lo legitima.
4. **"Documentá / rastreá".** PRISMA (ledger de queries+descartes), SIFT (rastrear al original), y el fechado de fuentes. → Convergente en trazabilidad.

### Dónde se CONTRADICEN
- **Exhaustividad (PRISMA) vs. agilidad (rapid review / Exprés).** Resolución: *escalá el rigor a la consecuencia* — ledger siempre; maquinaria completa solo en alto riesgo.
- **"Competí hipótesis" (ACH) vs. ponderación bayesiana (calibración).** Mandel mostró que ACH puede *desconectar* la fuerza de la evidencia del juicio. Resolución: la **actualización bayesiana/calibración es primaria**; ACH entra solo como checklist de debiasing barato (hipótesis + refutación + supuestos), no como matriz que reemplace la ponderación.

### Ranking por evidencia (repetido, porque es la decisión clave)
**Fuerte:** Calibración, Lateral reading. → invertir a fondo.
**Estructura útil (no probada en outcomes):** GRADE. → tomar la forma.
**Útil pero acotado:** PRISMA (solo el ledger es "siempre"). → opt-in por riesgo.
**Débil/negativo:** ACH matriz. → solo el espíritu.

---

## Cambios recomendados para el SKILL (claude.ai)
Vía *progressive disclosure*: las heurísticas viven en un `reference` (este marco) que se carga en modo **Profundo**; las baratas y universales van en el body.

| Prioridad | Cambio | Modo | Dónde |
|---|---|---|---|
| 1 | **Calibración:** dar % numérico + ancla de tasa base en hallazgos clave (no "alto/medio/bajo" a secas) | Estándar+ / Profundo | body (regla corta) + reference (método) |
| 2 | **Lateral reading:** investigar al emisor DESDE AFUERA (≥2 fuentes sobre la fuente) antes de confiar | Todos | body (es barato y universal) |
| 3 | **Anti-confirmación:** por cada claim fuerte, nombrar qué lo refutaría y buscarlo | Estándar+ / Profundo | body |
| 4 | **Estructura GRADE:** separar "certeza de la evidencia" de "fuerza de la conclusión" en la salida | Estándar+ | body (formato de salida) |
| 5 | **Ledger ligero:** registrar queries + descartes (reproducibilidad) | Profundo | reference |
| 6 | **Espíritu ACH + key assumptions check** (sin matriz pesada) | Profundo | reference |

### Cambios recomendados para el AGENTE (Claude Code) — subrutinas REALES
El agente puede *implementar* lo que el skill solo puede *aludir*:

| Prioridad | Subrutina real | Se apoya en |
|---|---|---|
| 1 | **Verificación lateral en retrieval:** por cada fuente, fetch de ≥2 fuentes independientes SOBRE el emisor antes de aceptarla | Herramientas de búsqueda y lectura web (WebSearch, WebFetch) |
| 2 | **Paso de refutación:** para claims priority=high, búsqueda activa de evidencia DESCONFIRMATORIA (no solo confirmatoria) | Stage de verificación |
| 3 | **Calibración con ledger:** cada hallazgo clave con % + clase de referencia; loguear predicción→resultado; Brier cuando haya ground truth | `sources_ledger.json` / nuevo `calibration_log.json` |
| 4 | **Ledger reproducible (PRISMA-light):** queries ejecutadas + fuentes descartadas con motivo + conteo de flujo | Un `sources_ledger.json` |
| 5 | **Campos separados certeza/fuerza** (GRADE) en el output | Formato de salida |
| 6 | **Key assumptions check** como paso del loop antes de sintetizar | Pre-síntesis |

> Nota: NINGUNA de estas requiere modelos más grandes ni más fuentes — son método. Y todas encajan en cualquier skill o agente investigador que ya pueda buscar y leer en la web.

---

## Matriz de confianza y vacíos honestos
- **Confianza ALTA (múltiples fuentes verificadas):** efectividad fuerte de calibración (GJP) y lateral reading (Wineburg); evidencia negativa de ACH-matriz (4 estudios Mandel + RAND); GRADE/PRISMA como convención de reporte no probada en outcomes.
- **Confianza MEDIA / [verificación parcial]:** algunas cifras exactas de Wineburg & McGrew 2019 (PDF primario no se pudo re-abrir; corroboradas por fuentes secundarias). La formulación textual de los 8 pasos de ACH (matriz descrita y verificada; numeración textual de Heuer no extraída del PDF).
- **Vacíos declarados:** la calibración de LLMs específicamente NO está resuelta (área activa) — las heurísticas de calibración son disciplina, no garantía de que el % auto-reportado sea correcto. La transferibilidad de cada framework fuera de su dominio se marcó individualmente.

---

*Marco teórico v1.0 · 2026-06-27 · Smart4AI · método orquestador-worker (5 sub-investigadores + síntesis) · insumo para mejorar un skill (claude.ai) y un agente (Claude Code) de investigación.*
