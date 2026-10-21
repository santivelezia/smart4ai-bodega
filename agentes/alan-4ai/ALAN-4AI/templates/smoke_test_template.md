# Smoke Test Plan · {NOMBRE_AGENTE}
Generado por: ALAN-4AI · Run ID: {RUN_ID} · {FECHA}

---

## Caso de smoke test

- **Input:** {INPUT_CONCRETO_COPY_PASTE_LISTO}
- **Output esperado:** {DESCRIPCION_RESULTADO_IDEAL_EN_2_LINEAS}
- **Criterio de éxito:** {QUE_VERIFICAR · binario · verificable en <30 seg}
- **Costo:** corre sobre tu Claude Code (plan Max/Pro o API propia) · no hay cobro aparte.
- **Tiempo estimado:** {N} min

---

## Invocación exacta

Escribir en Claude Code (working dir: la carpeta de ALAN-4AI):

```
Lee output/{NOMBRE_KEBAB}/agent.md y ejecútalo {PARAMETROS_SI_APLICA}
```

---

## Métricas a verificar

| Métrica | Valor esperado | Cómo verificar |
|---|---|---|
| Tiempo wall-clock | < {N} min | Reloj desde invocación hasta reporte final |
| Archivos generados | {N} archivos | Windows: `(Get-ChildItem output\{nombre}\ -Recurse).Count` · mac/linux: `find output/{nombre} -type f | wc -l` |
| Checkpoints | {M} archivos | Windows: `(Get-ChildItem runs\ -Filter "*.json" -Recurse).Count` · mac/linux: `find runs -name "*.json" | wc -l` |
| error_log.md | vacío | Windows: `Get-Content runs\{run_id}\error_log.md` · mac/linux: `cat runs/{run_id}/error_log.md` |

---

## Escenario ✅ · Salió bien

**Condición:** pipeline completó · output principal generado · sin STOPs inesperados.

**Señales visuales:**
- Reporte final de ALAN-4AI muestra `Estado: AGENTE_LISTO`
- `{OUTPUT_PRINCIPAL_RUTA}` existe
- `runs\{run_id}\error_log.md` vacío o inexistente

**Acción:** marcar smoke test como **PASS** · agente listo para uso.

---

## Escenario ⚠️ · Salió parcial

**Condición:** pipeline ejecutó parcialmente · algún stage con warning · output incompleto.

**Señales visuales:**
- ALAN-4AI imprime `⚠️` o `NECESITA_ITERACION`
- Checkpoint existe pero output final ausente
- `error_log.md` tiene warnings (no errores críticos)

**Acción:**
1. Anotar exactamente el mensaje de warning
2. Ver qué stage falló: Windows `Get-Content runs\{run_id}\checkpoints\stage_*.json` · mac/linux `cat runs/{run_id}/checkpoints/stage_*.json`
3. Reportar: "Falló en Stage {N}: {mensaje exacto}"

---

## Escenario 🚨 · Falló

**Condición:** STOP antes de completar · error crítico · sin output.

**Señales visuales:**
- ALAN-4AI imprime `🚨 STOP` con mensaje específico
- `error_log.md` tiene entradas de error
- Sin reporte final

**Acción:**
1. Copiar el mensaje de error completo
2. Ejecutar: Windows `Get-Content runs\{run_id}\error_log.md` · mac/linux `cat runs/{run_id}/error_log.md`
3. Reportar: "STOP en Stage {N}: {mensaje exacto del error_log}"
4. NO intentar re-ejecutar sin entender la causa

---

## Criterios PASS / FAIL

**PASS = todos:**
- ✓ Pipeline completó sin STOP no controlado
- ✓ `{OUTPUT_PRINCIPAL_RUTA}` existe
- ✓ Tiempo < {N} min
- ✓ `error_log.md` vacío (o sin errores críticos)

**FAIL = cualquiera:**
- ✗ STOP en stage crítico
- ✗ Output principal ausente
- ✗ Tiempo >> estimado sin warning previo
- ✗ Error en `error_log.md` sin recovery

---

## Resultado del smoke test (completar al ejecutar)

```
Fecha ejecución:    _______________
Tiempo real:        _______________
Escenario:          ✅ / ⚠️ / 🚨
Veredicto:          PASS / FAIL
Notas:              _______________
```
