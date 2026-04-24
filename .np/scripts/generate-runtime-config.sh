#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
CFG="${1:-$ROOT/.np/config.yaml}"
OUT_FILE="${2:-$ROOT/.np/theme/assets/runtime-config.js}"

mkdir -p "$(dirname "$OUT_FILE")"

extract_bool() {
  awk -F': ' '/^[[:space:]]*enabled:[[:space:]]*/ {gsub(/#.*/,"",$2); gsub(/\r/,"",$2); gsub(/[[:space:]]/,"",$2); print tolower($2); exit}' "$CFG"
}

extract_provider() {
  awk -F': ' '/^[[:space:]]*provider:[[:space:]]*/ {gsub(/#.*/,"",$2); gsub(/\r/,"",$2); gsub(/^[[:space:]]+|[[:space:]]+$/,"",$2); gsub(/^"|"$/, "", $2); print $2; exit}' "$CFG"
}

extract_counter() {
  awk -F': ' '/^[[:space:]]*yandex_counter_id:[[:space:]]*/ {gsub(/#.*/,"",$2); gsub(/\r/,"",$2); gsub(/^[[:space:]]+|[[:space:]]+$/,"",$2); gsub(/^"|"$/, "", $2); print $2; exit}' "$CFG"
}

enabled_raw="$(extract_bool || true)"
provider="$(extract_provider || true)"
counter_id="$(extract_counter || true)"

enabled_js="false"
if [[ "$enabled_raw" == "true" || "$enabled_raw" == "yes" || "$enabled_raw" == "1" ]]; then
  enabled_js="true"
fi

cat > "$OUT_FILE" <<RUNTIME
(function () {
  window.__npRuntimeConfig = {
    analytics: {
      enabled: ${enabled_js},
      provider: "${provider}",
      yandexCounterId: "${counter_id}"
    }
  };
})();
RUNTIME

echo "runtime config generated: $OUT_FILE"
