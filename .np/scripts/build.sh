#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
cd "$ROOT"

BIN="${NOTEPUB_BIN:-notepub}"
CFG="${NOTEPUB_CONFIG:-./.np/config.yaml}"
RULES="${NOTEPUB_RULES:-./.np/rules.yaml}"
ART="./.notepub/artifacts"
OUT="./.np/dist"
CONTENT_DIR="./content"
MEDIA_DIR="./media"

infer_custom_domain_base_url() {
  local cname="${ROOT}/CNAME"
  local domain=""

  if [[ ! -f "$cname" ]]; then
    return 1
  fi

  while IFS= read -r line; do
    line="${line%%#*}"
    line="${line//$'\r'/}"
    line="${line#"${line%%[![:space:]]*}"}"
    line="${line%"${line##*[![:space:]]}"}"
    if [[ -n "$line" ]]; then
      domain="$line"
      break
    fi
  done < "$cname"

  if [[ -z "$domain" ]]; then
    return 1
  fi

  domain="${domain#http://}"
  domain="${domain#https://}"
  domain="${domain%%/*}"
  if [[ -z "$domain" ]]; then
    return 1
  fi

  printf 'https://%s/' "$domain"
}

infer_github_pages_base_url() {
  local repo="${GITHUB_REPOSITORY:-}"
  local owner="${GITHUB_REPOSITORY_OWNER:-}"

  if [[ -z "$repo" ]]; then
    return 1
  fi
  if [[ -z "$owner" ]]; then
    owner="${repo%%/*}"
  fi

  local name="${repo#*/}"
  if [[ "$name" == "${owner}.github.io" ]]; then
    printf 'https://%s.github.io/' "$owner"
  else
    printf 'https://%s.github.io/%s/' "$owner" "$name"
  fi
}

if [[ -z "${NOTEPUB_BASE_URL:-}" && "${GITHUB_ACTIONS:-}" == "true" ]]; then
  if [[ -n "${GITHUB_PAGES_BASE_URL:-}" ]]; then
    export NOTEPUB_BASE_URL="${GITHUB_PAGES_BASE_URL%/}/"
    echo "Using GitHub Pages URL from configure-pages: $NOTEPUB_BASE_URL"
  elif BASE_URL="$(infer_custom_domain_base_url)"; then
    export NOTEPUB_BASE_URL="$BASE_URL"
    echo "Using custom domain URL from CNAME: $NOTEPUB_BASE_URL"
  elif BASE_URL="$(infer_github_pages_base_url)"; then
    export NOTEPUB_BASE_URL="$BASE_URL"
    echo "Using inferred GitHub Pages URL: $NOTEPUB_BASE_URL"
  fi
fi

if [[ -n "${NOTEPUB_BASE_URL:-}" && -z "${NOTEPUB_MEDIA_BASE_URL:-}" ]]; then
  export NOTEPUB_MEDIA_BASE_URL="${NOTEPUB_BASE_URL%/}/media/"
fi

if [[ -z "${NOTEPUB_BIN:-}" && -x "./.np/bin/notepub" ]]; then
  BIN="./.np/bin/notepub"
fi

if ! command -v "$BIN" >/dev/null 2>&1; then
  echo "notepub binary not found: $BIN"
  echo "Set NOTEPUB_BIN, for example:"
  echo "  NOTEPUB_BIN=/path/to/notepub $0"
  exit 1
fi

if [[ -f "./.np/scripts/generate-runtime-config.sh" ]]; then
  echo "[0/8] generate runtime config"
  ./.np/scripts/generate-runtime-config.sh "$CFG"
fi

echo "[1/8] index"
"$BIN" index --config "$CFG" --rules "$RULES"

echo "[2/8] validate links + markdown"
if "$BIN" validate --help 2>&1 | grep -q -- " -links"; then
  "$BIN" validate --config "$CFG" --rules "$RULES" --links
else
  echo "validate --links is not supported by this notepub binary; skipping"
fi

if "$BIN" validate --help 2>&1 | grep -q -- " -markdown"; then
  "$BIN" validate --config "$CFG" --rules "$RULES" --markdown --markdown-format text
else
  echo "validate --markdown is not supported by this notepub binary; skipping"
fi

echo "[3/8] build"
"$BIN" build --config "$CFG" --rules "$RULES" --artifacts "$ART" --dist "$OUT"

echo "[4/8] export content media"
rm -rf "$OUT/media"
mkdir -p "$OUT/media"

if [[ -d "$CONTENT_DIR" ]]; then
  if command -v rsync >/dev/null 2>&1; then
    rsync -a --prune-empty-dirs \
      --exclude '.git/' \
      --exclude '.github/' \
      --exclude '.obsidian/' \
      --exclude '*.md' \
      "$CONTENT_DIR"/ "$OUT/media/"
  else
    find "$CONTENT_DIR" -type f ! -name '*.md' -print0 | while IFS= read -r -d '' f; do
      rel="${f#$CONTENT_DIR/}"
      mkdir -p "$OUT/media/$(dirname "$rel")"
      cp "$f" "$OUT/media/$rel"
    done
  fi
fi

if [[ -d "$MEDIA_DIR" ]]; then
  if command -v rsync >/dev/null 2>&1; then
    rsync -a --prune-empty-dirs \
      --exclude '.git/' \
      --exclude '.github/' \
      --exclude '.obsidian/' \
      --exclude '*.md' \
      "$MEDIA_DIR"/ "$OUT/media/"
  else
    find "$MEDIA_DIR" -type f ! -name '*.md' -print0 | while IFS= read -r -d '' f; do
      rel="${f#$MEDIA_DIR/}"
      mkdir -p "$OUT/media/$(dirname "$rel")"
      cp "$f" "$OUT/media/$rel"
    done
  fi
fi

if [[ -f "./CNAME" ]]; then
  cp ./CNAME "$OUT/CNAME"
fi

echo "[5/8] copy llms files"
if [[ -f "$OUT/assets/llms.txt" ]]; then
  cp "$OUT/assets/llms.txt" "$OUT/llms.txt"
fi
if [[ -f "$OUT/assets/llms-full.txt" ]]; then
  cp "$OUT/assets/llms-full.txt" "$OUT/llms-full.txt"
fi

echo "[6/8] normalize robots"
if [[ -f "$OUT/robots.txt" ]]; then
  awk '!/^LLM: /' "$OUT/robots.txt" > "$OUT/robots.txt.tmp"
  cat "$OUT/robots.txt.tmp" > "$OUT/robots.txt"
  rm -f "$OUT/robots.txt.tmp"
fi

echo "[7/8] mirror dist to ./dist (compat)"
rm -rf ./dist
mkdir -p ./dist
cp -R "$OUT"/. ./dist/

echo "[8/8] done -> $OUT"
