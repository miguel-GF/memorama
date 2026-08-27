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
  cat >&2 <<'EOF'
FVM no esta instalado.

Instala FVM y vuelve a ejecutar este script. La version de Flutter se declara
en .fvmrc y nunca se toma del SDK global del PATH.
EOF
  exit 1
fi

if [[ ! -f .fvmrc ]]; then
  echo "Falta .fvmrc; declara una version exacta de Flutter con FVM." >&2
  exit 1
fi

required_flutter_version="$(sed -n 's/.*"flutter"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p' .fvmrc)"
if [[ -z "$required_flutter_version" ]]; then
  echo "No se pudo leer flutter desde .fvmrc." >&2
  exit 1
fi

fvm install "$required_flutter_version"
fvm use "$required_flutter_version" --skip-pub-get

generated_widget_test=0
if [[ ! -e test/widget_test.dart ]]; then
  generated_widget_test=1
fi

if [[ ! -d android ]]; then
  fvm flutter create \
    --platforms=android \
    --org com.memogranja \
    --project-name memo_granja \
    .
fi

if [[ "$generated_widget_test" == "1" && -f test/widget_test.dart ]]; then
  rm -f test/widget_test.dart
fi

fvm flutter --version | sed -n '1p' > .tool-versions.local
fvm flutter pub get
./tool/check.sh
