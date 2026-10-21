# 🚀 Guía de despliegue de ALAN-4AI

> Esta guía te lleva de **"acabo de recibir un ZIP por WhatsApp"** a **"ALAN-4AI está construyendo mi
> primer agente"**. Está escrita para que la sigas aunque nunca hayas usado una terminal.
>
> Estructura de cada paso: **qué vamos a hacer → cómo hacerlo → qué deberías ver**.
> Al final hay una sección de problemas comunes (✅ salió / ⚠️ parcial / 🚨 falló).

---

## Etapa 0 · Lo que necesitas antes de empezar (5 min)

**Qué:** ALAN-4AI corre dentro de **Claude Code**, la herramienta de línea de comandos de Anthropic.
Necesitas tenerla instalada y con sesión iniciada.

**Cómo:**
1. Instala Claude Code siguiendo la guía oficial: https://docs.claude.com/claude-code
2. Inicia sesión con tu plan de Claude (Max o Pro) o con tu API key. En una terminal:
   ```
   claude
   ```
   La primera vez te pedirá autenticarte (se abre el navegador o te pide la API key).

**Qué deberías ver:** al escribir `claude` y presionar Enter, se abre la interfaz de Claude Code
(un recuadro para escribir tus mensajes). Si te pregunta *"¿Usar API key?"* y prefieres tu plan Max/Pro,
elige iniciar sesión con tu cuenta de Claude.

---

## Etapa 1 · Descomprimir el ZIP (2 min)

**Qué:** sacar la carpeta `ALAN-4AI/` del ZIP y ponerla en un lugar fácil de encontrar.

**Cómo:**
- **Windows:** clic derecho sobre el ZIP → *"Extraer todo…"* → elige `Documentos` → *Extraer*.
- **Mac:** doble clic sobre el ZIP (se descomprime solo al lado).
- **Linux:** clic derecho → *"Extraer aquí"*, o en terminal `unzip ALAN-4AI.zip -d ~/Documentos`.

**Qué deberías ver:** una carpeta llamada **`ALAN-4AI`** que contiene `README.md`, `agent.md`, `CLAUDE.md`,
y las carpetas `stages/`, `templates/`, `kb/`, `output/`, `runs/`, `docs/`.

> 💡 Anota la ruta donde quedó. Ejemplos:
> - Windows: `C:\Users\TU_USUARIO\Documents\ALAN-4AI`
> - Mac/Linux: `/Users/TU_USUARIO/Documentos/ALAN-4AI`

---

## Etapa 2 · Abrir Claude Code DENTRO de la carpeta ALAN-4AI (3 min)

**Qué:** Claude Code trabaja sobre la carpeta desde la que lo abres. Tiene que ser la carpeta `ALAN-4AI`
(así encuentra `agent.md`, `kb/`, etc.).

**Cómo — Windows (PowerShell):** abre PowerShell y escribe esta única línea (ajusta la ruta a la tuya):
```powershell
cd "C:\Users\TU_USUARIO\Documents\ALAN-4AI"; claude
```

**Cómo — Mac / Linux (Terminal):**
```bash
cd ~/Documentos/ALAN-4AI && claude
```

> 🖱️ **Atajo sin escribir la ruta:**
> - Windows: abre la carpeta `ALAN-4AI` en el Explorador, haz clic en la barra de dirección, escribe
>   `powershell` y Enter → luego escribe `claude`.
> - Mac: arrastra la carpeta sobre el ícono de Terminal, o clic derecho → *"Nuevos servicios → Nueva
>   terminal en la carpeta"* → luego `claude`.

**Qué deberías ver:** Claude Code abierto, y en algún lado la ruta que termina en `ALAN-4AI`. Eso confirma
que estás "parado" en la carpeta correcta.

**Verificación rápida (opcional):** escríbele a Claude Code:
```
¿Ves el archivo agent.md y la carpeta kb/ en esta carpeta?
```
Debería responder que sí y mencionar las 3 carpetas dentro de `kb/`.

---

## Etapa 3 · (Opcional) Activar el modo automático (1 min)

**Qué:** el "auto mode" deja que ALAN-4AI encadene los stages sin pedirte permiso en cada pasito
(igual se detiene en los 3 GATES importantes).

**Cómo:** dentro de Claude Code, presiona `Shift + Tab` hasta ver `⏵⏵ auto mode on` en la barra inferior.

**Qué deberías ver:** el indicador `auto mode on`. Si no lo activas, no pasa nada: Claude Code te pedirá
confirmación más seguido, y listo.

---

## Etapa 4 · Invocar a ALAN-4AI (¡el momento!) (1 min)

**Qué:** arrancar el pipeline.

**Cómo — para construir un agente NUEVO (Modo A):** escribe en Claude Code, tal cual:
```
Lee agent.md y ejecútalo
```

**Cómo — para MEJORAR un agente que ya construiste (Modo B):**
```
Lee agent.md y ejecútalo en MODO B sobre output/<nombre-del-agente>
```

**Qué deberías ver:** ALAN-4AI se presenta y empieza el **Stage 1 · Discovery**: te hace preguntas en
4 niveles (qué existe hoy → cómo funciona → qué sale mal → cómo mides el éxito) y te pide ejemplos.

---

## Etapa 5 · La entrevista de Discovery (~20–30 min)

**Qué:** ALAN-4AI NO genera nada hasta entender bien tu agente. Es la parte más importante.

**Cómo:** responde con tus palabras. Te pedirá:
- **4 niveles:** Superficie · Flujo · Excepciones · Criterios de éxito.
- **Spec-by-example:** 3 ejemplos de lo que el agente DEBE hacer + 2 de lo que NO debe hacer.
- **Tier del agente:** CORE (central, siempre activo) · Ops (apoyo interno) · Comercial (de cara a usuarios).

**Qué deberías ver:** al final, ALAN-4AI te muestra la spec y te pide confirmar escribiendo
*"spec completa"*. No avanza hasta que confirmes. Si algo no cuadra, corrígelo ahí mismo.

---

## Etapa 6 · Los 3 GATES (tú apruebas) (~5 min cada uno)

**Qué:** ALAN-4AI se detiene 3 veces y te muestra un plan para que decidas.

| GATE | Cuándo | Qué apruebas |
|---|---|---|
| **GATE 1 · Alcance** | tras diseñar la arquitectura | tier + si es single o multi-agente + el enfoque |
| **GATE 2 · Arquitectura** | tras diseñar pipeline y memoria | los stages del agente + qué memoria tendrá |
| **GATE 3 · Artefacto final** | tras generar y evaluar | los archivos + el resultado de los 13 anti-patterns + la versión |

**Cómo:** en cada GATE responde ✅ (apruebo), ✏️ (cambia esto) o ❌ (mejor no).

**Qué deberías ver:** entre GATE 2 y GATE 3, ALAN-4AI genera el código, diseña el smoke test y lo hace
evaluar por un sub-agente **independiente** (y un tercero adversarial). Verás esos veredictos en GATE 3.

---

## Etapa 7 · Tu agente listo (1 min)

**Qué:** recibir el agente terminado.

**Qué deberías ver:** un reporte final con el nombre, la versión (`v1.0.0+...`), el resultado de los
13 anti-patterns y la ruta. Tu agente nuevo queda en:
```
output/<nombre-de-tu-agente>/
```
con su `README.md`, `agent.md`, `CLAUDE.md`, `stages/` y un `RECEIPT.md`. Además se registra en
`output/REGISTRY.md`.

**Cómo usar tu agente nuevo:** abre Claude Code dentro de su carpeta y escríbele:
```
Lee agent.md y ejecútalo
```
(o corre primero su smoke test: `Lee tests/smoke_test_plan.md y ejecútalo`).

---

## 🧯 Problemas comunes

**🚨 "No encuentra agent.md / kb/"**
→ Abriste Claude Code en la carpeta equivocada. Cierra, haz `cd` a la carpeta `ALAN-4AI` (Etapa 2) y
vuelve a abrir `claude`. Verifica con: *"¿ves agent.md aquí?"*.

**🚨 "Me pregunta por una API key y no quiero gastar de API"**
→ Elige iniciar sesión con tu plan de Claude (Max/Pro) en vez de pegar una API key. ALAN-4AI no necesita
ninguna clave propia para funcionar.

**⚠️ "Dice que corre en modo mono-proveedor / no encontró OPENAI_API_KEY"**
→ Es normal y está bien. Significa que la evaluación externa la hace un sub-agente de Claude en ventana
limpia. Solo si QUIERES evaluación de otro proveedor, copia `.env.local.example` a `.env.local` y pega
tus claves (opcional).

**⚠️ "El evaluador (S8) dice NECESITA_ITERACION"**
→ No es un error: es control de calidad. ALAN-4AI te dirá qué stage re-ejecutar. Déjalo iterar o ajusta
la spec y vuelve a correr ese stage.

**⚠️ "El adversarial (S9) contradice al evaluador"**
→ Esa contradicción ES la señal de calidad. ALAN-4AI verifica la premisa contra el archivo real y te
presenta ambas opiniones en un GATE para que decidas. Es el comportamiento esperado.

**✅ "Terminó y tengo mi carpeta en output/"**
→ ¡Listo! Ese es el resultado correcto. Corre su smoke test para verlo funcionar.

---

## 📎 Resumen ultra-corto (para pegar en la nevera)

```
1. Instala Claude Code y inicia sesión (plan Max/Pro o API key).
2. Descomprime el ZIP → carpeta ALAN-4AI.
3. Abre Claude Code DENTRO de esa carpeta:
     Windows:  cd "RUTA\ALAN-4AI"; claude
     Mac/Linux: cd RUTA/ALAN-4AI && claude
4. Escribe:  Lee agent.md y ejecútalo
5. Responde el Discovery → aprueba los 3 GATES → recoge tu agente en output/.
```

*¿Dudas? Empieza por el `README.md`. El diseño completo está en `SPEC.md`.*
