#!/bin/bash

# 1. VERIFICAR LA INSTALACIÓN DE UNGOOGLED-CHROMIUM
if ! command -v ungoogled-chromium &>/dev/null; then
    >&2 echo "Error: el comando 'ungoogled-chromium' no se encontró en el PATH."
    >&2 echo "Puedes instalarlo desde el PPA de XtraDeb (Debian o Ubuntu):"
    >&2 echo "sudo apt update && sudo apt upgrade -y && sudo add-apt-repository ppa:xtradeb/apps -y && sudo apt update && sudo apt install ungoogled-chromium -y"
    exit 1
fi

# 2. DETERMINAR EL DIRECTORIO DE LA BIBLIOTECA
CHROMIUM_DIR="/usr/lib/ungoogled-chromium"
if [ ! -d "$CHROMIUM_DIR" ]; then
    >&2 echo "Error: No se encontró el directorio de la biblioteca: $CHROMIUM_DIR"
    exit 1
fi

# 3. COMPROBAR LA EXISTENCIA DEL DIRECTORIO DE CONFIGURACIÓN
CONFIG_DIR="$HOME/.config/chromium"
if [ ! -d "$CONFIG_DIR" ]; then
    >&2 echo "Advertencia: No se encontró el directorio de configuración: $CONFIG_DIR"
fi

# 4. IMPRIMIR LA RUTA DE LA BIBLIOTECA
echo "El directorio de la biblioteca de ungoogled-chromium es: $CHROMIUM_DIR"

