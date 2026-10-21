# runs/

Aquí ALAN-4AI guarda los artefactos de cada ejecución (un run por construcción/upgrade):

```
runs/<run_id>/
├── checkpoints/          ← estado guardado tras cada stage (stage_0.json … stage_11.json)
├── elicitation_spec.md   ← la spec que confirmaste en el Discovery (S1)
├── receipt_final.md      ← el recibo final del run (S11)
└── error_log.md          ← errores si los hubo (nunca se silencian)
```

Si un run se cae a la mitad, ALAN-4AI puede reanudarlo desde el último checkpoint válido
(no vuelve a empezar desde cero). Puedes borrar carpetas de runs viejos cuando quieras.

`<run_id>` tiene el formato `alan_<AAAA-MM-DD-HHmm>`.
