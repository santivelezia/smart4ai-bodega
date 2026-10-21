# ⚙️ ALAN-4AI · Tu constructor de agentes Claude

> **ALAN-4AI** es un *meta-agente*: un agente cuyo trabajo es **construir otros agentes de Claude**
> de clase mundial. Le dices qué agente quieres, te entrevista hasta que la idea queda sin ambigüedad,
> diseña la arquitectura, genera todos los archivos, los hace evaluar por un revisor independiente y te
> entrega el agente listo para usar — todo desde **Claude Code**, en tu propio computador.
>
> Inspirado en Alan Turing, que diseñó la Máquina Universal de la que nacen todos los computadores.
> Versión para alumnos del curso **Claude for Devs** (Smart4AI).

---

## 🎯 ¿Qué hace ALAN-4AI por ti?

- **Modo A · Construir:** de una idea ("quiero un agente que resuma reuniones") a un agente completo,
  probado y versionado.
- **Modo B · Mejorar:** audita un agente que ya tienes y lo mejora de forma quirúrgica (con backup y
  test de no-regresión).

Y lo hace aplicando lo que funciona en 2026 para agentes de clase mundial:

1. **Discovery obligatorio** antes de generar nada (te pregunta hasta que la spec esté completa) → **+13.4%** de éxito medido.
2. **Cada fase en ventana limpia** (sub-agentes vía la herramienta Task) → sin saturación de contexto.
3. **Evaluador externo obligatorio**: la ventana que revisa el código **nunca** es la que lo generó → mata el auto-engaño.
4. **13 anti-patterns** verificados antes de dar por bueno cualquier agente.
5. **Memoria por tier** (Patrón 5) y **versionado con pin de modelo** para que nada se rompa en silencio.

---

## 📦 ¿Qué necesitas? (requisitos)

1. **Claude Code instalado** en tu computador (CLI de Anthropic). Guía: https://docs.claude.com/claude-code
2. **Una sesión de Claude Code activa** — con tu plan de Claude (Max/Pro) o tu propia API key.
3. **Nada más.** ALAN-4AI es autocontenido: la base de conocimiento viene incluida en `kb/`.

> *(Opcional)* Si quieres evaluación cross-provider (que un modelo de OTRO proveedor juzgue el código de
> Claude), puedes agregar claves de OpenAI y/o OpenRouter — ver `.env.local.example`. **No es necesario.**

---

## ⚡ Quickstart (3 pasos)

1. **Descomprime** este ZIP en una carpeta cómoda (ej. `Documentos/ALAN-4AI`).
2. **Abre Claude Code dentro de esa carpeta** (ver `GUIA_DE_DESPLIEGUE.md` para el paso exacto por sistema operativo).
3. **Escribe en Claude Code:**
   ```
   Lee agent.md y ejecútalo
   ```
   ALAN-4AI arranca el Discovery y te guía de principio a fin.

👉 **La guía completa, paso a paso y con qué esperar en cada pantalla, está en
[`GUIA_DE_DESPLIEGUE.md`](GUIA_DE_DESPLIEGUE.md).** Empieza por ahí si es tu primera vez.

---

## 📁 Qué hay en esta carpeta

```
ALAN-4AI/
├── README.md                 ← este archivo
├── GUIA_DE_DESPLIEGUE.md     ← cómo instalarlo y usarlo, paso a paso (EMPIEZA AQUÍ)
├── CLAUDE.md                 ← el "rol" de ALAN-4AI (Claude Code lo lee automáticamente)
├── agent.md                  ← el prompt principal: el pipeline de 12 stages
├── SPEC.md                   ← el contrato de diseño + de dónde sale cada decisión
├── .env.local.example        ← claves opcionales para evaluación cross-provider
├── stages/                   ← los 12 stages + la variante Modo B (uno por archivo)
├── templates/                ← plantillas que ALAN-4AI usa al generar agentes
├── docs/                     ← 13 anti-patterns explicados + lecciones destiladas
├── kb/                       ← 📚 base de conocimiento incluida (3 investigaciones)
├── output/                   ← 📤 aquí aparecen los agentes que construyas
└── runs/                     ← artefactos y checkpoints de cada ejecución
```

---

## 🔄 El pipeline en una imagen

```
IDEA → S1 Discovery → S2 KB → S3 Arquitectura →🛑GATE 1
     → S4 Pipeline → S5 Memoria →🛑GATE 2
     → S6 Genera código → S7 Smoke test → S8 Evalúa (ventana limpia) → S9 Refuta → S10 Versiona →🛑GATE 3
     → S11 Publica → ✅ AGENTE LISTO
```

Los **3 GATES** son puntos donde ALAN-4AI se detiene y te muestra un plan para que apruebes (✅),
edites (✏️) o rechaces (❌) antes de seguir. Tú siempre tienes el control.

---

## ❓ Preguntas frecuentes

- **¿Gasto dinero de API?** ALAN-4AI corre sobre tu Claude Code. Si usas plan Max/Pro, el consumo va por
  tu suscripción. Si usas API key propia, pagas tu consumo normal de Claude Code. ALAN-4AI no cobra nada aparte.
- **¿Sirve en Windows / Mac / Linux?** Sí. La guía trae los comandos para cada sistema.
- **¿Necesito saber programar?** No para *usarlo*: ALAN-4AI te entrevista en lenguaje natural y genera el
  código por ti. Leer los archivos que produce te ayuda a aprender.
- **¿Y si me equivoco en el Discovery?** En cada GATE puedes editar o rechazar. Y siempre puedes volver a correrlo.

---

*ALAN-4AI · versión para alumnos · derivado del meta-agente ALAN de Smart4AI · conocimiento en `kb/`.*
