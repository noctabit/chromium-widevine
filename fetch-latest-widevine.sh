#!/bin/bash
set -euo pipefail

# 1. VERIFICACIÓN DE LA HERRAMIENTA DE DESCARGA (SOLO WGET)
#    Se comprueba que wget esté instalado, ya que es la única herramienta de descarga soportada.
if ! command -v wget >/dev/null 2>&1; then
    echo "Error: La herramienta 'wget' no está instalada en este sistema." >&2
    exit 1
fi

# 2. VALIDACIÓN DE LA ARQUITECTURA (SÓLO SISTEMAS DE 64 BITS)
#    Se verifica que el sistema sea de 64 bits comprobando tanto 'uname' como 'getconf'.
if [ "$(uname -m)" != "x86_64" ]; then
    echo "Error: Este script solo soporta sistemas de 64 bits (x86_64)." >&2
    exit 1
fi

if [ "$(getconf LONG_BIT)" -ne 64 ]; then
    echo "Error: Este script solo soporta sistemas de 64 bits." >&2
    exit 1
fi

# 3. OBTENCIÓN DE LA VERSIÓN DE WIDEVINE
#    Se descarga el archivo de versiones y se selecciona la última versión disponible.
VERSION_FILE=$(mktemp)
wget -qO- --timeout=10 https://dl.google.com/widevine-cdm/versions.txt > "$VERSION_FILE"
if [ ! -s "$VERSION_FILE" ]; then
    echo "Error: No se pudo obtener el archivo de versiones." >&2
    exit 1
fi

VERSION=$(tail -n1 "$VERSION_FILE")
rm -f "$VERSION_FILE"  # Limpieza del archivo temporal

if [ -z "$VERSION" ]; then
    echo "Error: No se pudo obtener la versión de Widevine." >&2
    exit 1
fi

# 4. VERIFICACIÓN DE LA VALIDEZ DE LA VERSIÓN
#    Se valida que la versión obtenida tenga el formato numérico esperado (por ejemplo, 4.10.2209.0).
if [[ ! "$VERSION" =~ ^[0-9]+(\.[0-9]+)*$ ]]; then
    echo "Error: La versión obtenida ('$VERSION') no es un número de versión válido." >&2
    exit 1
fi

# 5. VALIDACIÓN DE LOS ARGUMENTOS DE ENTRADA
#    Se verifica que no se haya incluido accidentalmente la opción '-o' en minúscula,
#    ya que wget utiliza '-O' (mayúscula) para especificar el archivo de salida.
for arg in "$@"; do
    if [[ "$arg" == "-o" ]]; then
        echo "Error: La opción '-o' (minúscula) no es válida. Use '-O' (mayúscula) para especificar la salida." >&2
        exit 1
    fi
done

# 6. CONSTRUCCIÓN DE LA URL DE DESCARGA
#    Se arma la URL utilizando la versión obtenida y la arquitectura x64.
DOWNLOAD_URL="https://dl.google.com/widevine-cdm/${VERSION}-linux-x64.zip"

# 7. COMPROBACIÓN DE CONEXIÓN CON EL SERVIDOR DE WIDEVINE
#    Se utiliza 'wget --spider' con timeout para verificar que la URL de descarga es accesible.
if ! wget --spider --timeout=10 "$DOWNLOAD_URL" >/dev/null 2>&1; then
    echo "Error: No se pudo conectar al servidor de Widevine en $DOWNLOAD_URL." >&2
    exit 1
fi

# 8. VERIFICACIÓN DE LA EXISTENCIA DEL ARCHIVO DE DESTINO
#    Se comprueba si el archivo que se va a descargar ya existe en el directorio actual.
FILENAME=$(basename "$DOWNLOAD_URL")
FORCE_OVERWRITE=false

#    Verificar si el usuario quiere sobrescribir el archivo existente con '-f' o '--force'
for arg in "$@"; do
    if [[ "$arg" == "-f" || "$arg" == "--force" ]]; then
        FORCE_OVERWRITE=true
    fi
done

if [ -f "$FILENAME" ] && ! $FORCE_OVERWRITE; then
    echo "Error: El archivo '$FILENAME' ya existe. Use '-f' o '--force' para sobrescribirlo." >&2
    exit 1
fi

# 9. MOSTRAR LA VERSIÓN Y REALIZAR LA DESCARGA
#    Se informa al usuario sobre la versión que se va a descargar y se inicia la descarga con timeout.
echo "Descargando Widevine versión $VERSION para x86_64..."
echo "URL de descarga: $DOWNLOAD_URL"

if ! wget --timeout=10 "$@" "$DOWNLOAD_URL"; then
    echo "Error: Falló la descarga desde $DOWNLOAD_URL." >&2
    exit 1
fi

