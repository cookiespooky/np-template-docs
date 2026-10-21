#!/usr/bin/env bash
# Локальный предпросмотр: собирает сайт и открывает его на http://127.0.0.1:8080/.
# Пересоберите (запустите снова) после правки заметок.
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
cd "$ROOT"
PORT="${PORT:-8080}"
if [[ "$PORT" != "8080" ]]; then
  # Ссылки в собранных страницах абсолютные: адрес сборки должен совпасть с адресом сервера.
  export NOTEPUB_BASE_URL="http://127.0.0.1:${PORT}/"
fi

./.np/scripts/build.sh
echo
echo "Сайт: http://127.0.0.1:${PORT}/  (Ctrl+C — остановить)"
exec python3 -m http.server "$PORT" --bind 127.0.0.1 --directory ./.np/dist
