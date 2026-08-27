#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")/.."

if ! command -v fvm >/dev/null 2>&1; then
  fvm_path="${LOCALAPPDATA:-}/Pub/Cache/bin/fvm.bat"
  if [[ -f "$fvm_path" ]]; then
    fvm() { "$fvm_path" "$@"; }
  fi
fi

if ! command -v fvm >/dev/null 2>&1; then
  echo "FVM no esta instalado; no se pueden ejecutar los checks del proyecto." >&2
  exit 1
fi

if [[ ! -f .fvmrc ]]; then
  echo "Falta .fvmrc; fija una version de Flutter con FVM antes de verificar." >&2
  exit 1
fi

fvm dart format --output=none --set-exit-if-changed lib test
fvm flutter analyze
fvm flutter test
