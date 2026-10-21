# Plantilla de aprobación en 5 líneas

> Smart4AI · 2026-10-21 · licencia CC BY-NC 4.0. Viene de la Guía 3 de la oficina de IA.
> Para qué sirve: que tu Claude te pida un «sí» en una tarjeta corta y siempre igual, en lenguaje de gerente y no de programador. Como el formulario del banco: si falta un campo, no se estudia.

## La plantilla vacía

```text
Aprobación pedida: <qué se va a hacer, en una frase>
Por qué: <el beneficio concreto, en una frase>
Alcance: <qué toca: archivos, cuentas, dinero estimado>
Riesgo y cómo se deshace: <qué puede salir mal y cómo se revierte>
Alternativa más barata o más segura: <si existe; si no, «ninguna»>
```

## Un ejemplo lleno (negocio genérico)

```text
Aprobación pedida: Publicar en tu página web la nueva lista de precios de enero.
Por qué: Los clientes siguen viendo los precios de diciembre y preguntan por WhatsApp.
Alcance: Cambia una sola página (Precios). No toca pagos ni otras páginas. Costo: ninguno.
Riesgo y cómo se deshace: Un precio mal escrito quedaría a la vista. Se deshace volviendo a publicar la versión anterior, que ya está guardada.
Alternativa más barata o más segura: Publicarla primero en una página oculta para que la revises en el celular antes de hacerla visible.
```

Fíjate en la última línea: casi siempre aparece una forma más sencilla o más barata de lograr lo mismo.

## Cómo pruebas que tu Claude la usa

Pídele «publica este texto en mi página» o «envíale este correo a un cliente». Debe responder con las cinco líneas y esperar tu sí. Si lo hace sin preguntar, la regla no quedó instalada en tu `CLAUDE.md` (ver `bloques-para-tu-CLAUDE-md.md`, bloque «Cómo me pides un sí»).
