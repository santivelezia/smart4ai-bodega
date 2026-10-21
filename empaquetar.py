"""Empaqueta la bodega en un ZIP para quien no usa git.

Uso (desde cualquier carpeta):
    Windows:  py empaquetar.py
    Mac:      python3 empaquetar.py

Crea smart4ai-bodega.zip en la carpeta de ARRIBA de la bodega (fuera del repositorio),
con todo su contenido dentro de una carpeta "smart4ai-bodega/". Solo usa la biblioteca
estándar de Python. Las rutas dentro del ZIP van con barras "/" para que se abra bien
en Windows, Mac y Linux. No incluye .git, claves (.env) ni temporales.
"""
import pathlib
import sys
import zipfile

RAIZ = pathlib.Path(__file__).resolve().parent          # carpeta de la bodega
DESTINO = RAIZ.parent / "smart4ai-bodega.zip"           # el ZIP queda afuera
PREFIJO = "smart4ai-bodega"                             # carpeta raíz dentro del ZIP

# Carpetas y archivos que nunca van en el ZIP
CARPETAS_FUERA = {".git", "__pycache__", ".venv", "node_modules"}
NOMBRES_FUERA = {".DS_Store", "Thumbs.db", "desktop.ini"}


def va_en_el_zip(ruta: pathlib.Path) -> bool:
    """Decide si un archivo entra al ZIP."""
    relativa = ruta.relative_to(RAIZ)
    if any(parte in CARPETAS_FUERA for parte in relativa.parts):
        return False
    nombre = ruta.name
    if nombre in NOMBRES_FUERA or nombre.endswith((".pyc", ".tmp", ".zip")):
        return False
    # Claves: .env y .env.* fuera, salvo los ejemplos sin valores reales
    if nombre == ".env" or (nombre.startswith(".env.") and not nombre.endswith(".example")):
        return False
    return True


def main() -> int:
    archivos = sorted(p for p in RAIZ.rglob("*") if p.is_file() and va_en_el_zip(p))
    if not archivos:
        print("No encontré archivos para empaquetar. Revisa que el script esté dentro de la bodega.")
        return 1
    with zipfile.ZipFile(DESTINO, "w", compression=zipfile.ZIP_DEFLATED) as z:
        for p in archivos:
            # as_posix() pone barras "/" sin importar el sistema operativo
            z.write(p, f"{PREFIJO}/{p.relative_to(RAIZ).as_posix()}")
    # Verificación: el ZIP se puede leer, no está corrupto y tiene todos los archivos
    with zipfile.ZipFile(DESTINO) as z:
        malo = z.testzip()
        nombres = z.namelist()
    if malo is not None or len(nombres) != len(archivos):
        print(f"ERROR: el ZIP quedó mal (archivo dañado: {malo}; {len(nombres)} de {len(archivos)}).")
        return 1
    print(f"Listo: {DESTINO} · {len(nombres)} archivos · {DESTINO.stat().st_size / 1024:.0f} KB")
    return 0


if __name__ == "__main__":
    sys.exit(main())
