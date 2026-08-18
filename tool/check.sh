#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")/.."

if ! command -v flutter >/dev/null 2>&1; then
  echo "Flutter no está instalado; no se pueden ejecutar los checks del proyecto." >&2
  exit 1
fi

dart format --output=none --set-exit-if-changed lib test
flutter analyze
flutter test
