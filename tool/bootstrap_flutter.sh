#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")/.."

if ! command -v flutter >/dev/null 2>&1; then
  cat >&2 <<'EOF'
Flutter no está instalado.

Instala el SDK estable siguiendo https://docs.flutter.dev/get-started/install
y vuelve a ejecutar este script. No se descarga automáticamente para evitar una
instalación no reproducible o fuera de las políticas del equipo.
EOF
  exit 1
fi

if [[ "${UPDATE_FLUTTER:-0}" == "1" ]]; then
  flutter channel stable
  flutter upgrade
fi

if [[ ! -d android ]]; then
  flutter create \
    --platforms=android \
    --org com.memogranja \
    --project-name memo_granja \
    .
fi

flutter --version | sed -n '1p' > .tool-versions.local
flutter pub get
./tool/check.sh
