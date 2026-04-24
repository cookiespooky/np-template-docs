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
