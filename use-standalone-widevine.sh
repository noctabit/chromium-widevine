#!/bin/bash

########################################
# Sección 1: Encontrar el directorio de Chromium
########################################
# Ejecuta el script find-ungoogled-chromium.sh para determinar la ruta de Ungoogled Chromium.
CHROMIUM_DIR="$(/bin/sh ./find-ungoogled-chromium.sh)"
if [ -z "$CHROMIUM_DIR" ]; then
    # Si no se encuentra Ungoogled Chromium, termina el script con un error.
    exit 1
fi

########################################
# Sección 2: Descargar el archivo Widevine
########################################
# Ejecuta el script fetch-latest-widevine.sh para obtener el archivo widevine.zip.
./fetch-latest-widevine.sh -o ./widevine.zip

# Estructura de directorio esperada:
#	  widevine.zip
#	  ├── LICENSE.txt
#	  ├── manifest.json
#	  └── libwidevinecdm.so

########################################
# Sección 3: Extraer y organizar Widevine en el directorio de Chromium
########################################
# Extraer Widevine y recrear esta estructura de directorio bajo el directorio de Ungoogled Chromium:
#	  /usr/lib/chromium/WidevineCdm
#	  ├── LICENSE
#	  ├── manifest.json
#	  └── _platform_specific
#		  └── linux_x64

# Elimina recursivamente la carpeta WidevineCdm actual si existe
sudo rm -rf "$CHROMIUM_DIR/WidevineCdm"

# Crea el directorio destino con los permisos necesarios.
sudo mkdir -p "$CHROMIUM_DIR/WidevineCdm/_platform_specific/linux_x64"

# Extrae LICENSE.txt y lo coloca en el directorio de destino.
unzip -p widevine.zip LICENSE.txt | sudo dd status=none of="${CHROMIUM_DIR}/WidevineCdm/LICENSE.txt"

# Extrae manifest.json y lo coloca en el directorio de destino.
unzip -p widevine.zip manifest.json | sudo dd status=none of="${CHROMIUM_DIR}/WidevineCdm/manifest.json"

# Extrae libwidevinecdm.so y lo coloca en el subdirectorio linux_x64.
unzip -p widevine.zip libwidevinecdm.so | sudo dd status=none of="${CHROMIUM_DIR}/WidevineCdm/_platform_specific/linux_x64/libwidevinecdm.so"

# Ajusta los permisos: 0755 para directorios y 0644 para archivos.
find "$CHROMIUM_DIR/WidevineCdm" -type d -exec sudo chmod 0755 '{}' \;
find "$CHROMIUM_DIR/WidevineCdm" -type f -exec sudo chmod 0644 '{}' \;

########################################
# Sección 4: Limpieza
########################################
# Elimina el archivo widevine.zip descargado.
rm -f ./widevine.zip


