#!/bin/sh
# Uso: ./build.sh <usuario-github>   -> crea nondot-launcher.plasmoid con el ID io.github.<usuario>.nondotlauncher
set -e
[ -n "$1" ] || { echo "Falta el usuario de GitHub"; exit 1; }
sed -i "s/io\.github\.[A-Za-z0-9_-]*\.nondotlauncher/io.github.$1.nondotlauncher/" metadata.json
rm -f ../nondot-launcher.plasmoid
zip -qr ../nondot-launcher.plasmoid metadata.json contents
echo "OK: ../nondot-launcher.plasmoid"
