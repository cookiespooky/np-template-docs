#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
cd "$ROOT"

BIN="${NOTEPUB_BIN:-notepub}"
CFG="${NOTEPUB_CONFIG:-./.np/config.yaml}"
RULES="${NOTEPUB_RULES:-./.np/rules.yaml}"
ART="${NOTEPUB_ARTIFACTS_DIR:-./.notepub/artifacts}"
OUT="${NOTEPUB_DIST_DIR:-./.np/dist}"

resolve_content_dir() {
  python3 - "$CFG" <<'PY'
import re
import sys
from pathlib import Path

cfg = Path(sys.argv[1])
if not cfg.exists():
    print(str(Path("./content").resolve()))
    raise SystemExit(0)

lines = cfg.read_text(encoding="utf-8").splitlines()
in_content = False
for line in lines:
    if re.match(r'^content:\s*$', line):
        in_content = True
        continue
    if in_content and re.match(r'^[A-Za-z_][A-Za-z0-9_]*:\s*$', line):
        in_content = False
    if in_content:
        m = re.match(r'^\s{2}local_dir:\s*(.+?)\s*$', line)
        if m:
            value = m.group(1).strip().strip('"').strip("'")
            target = Path(value or "./content")
            if not target.is_absolute():
                target = (cfg.parent / target).resolve()
            print(str(target))
            raise SystemExit(0)

fallback = Path("./content")
if not fallback.is_absolute():
    fallback = (cfg.parent / fallback).resolve()
print(str(fallback))
PY
}

CONTENT_DIR="${NOTEPUB_CONTENT_DIR:-$(resolve_content_dir)}"
MEDIA_DIR="${NOTEPUB_MEDIA_DIR:-./media}"

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

echo "[0/9] prepare settings"
if command -v python3 >/dev/null 2>&1; then
  CFG="$(python3 ./.np/scripts/prepare-settings.py notes "$CFG")"
else
  echo "python3 is required to prepare Notepub template settings"
  exit 1
fi

if [[ -n "${NOTEPUB_BASE_URL:-}" ]]; then
  RESOLVED_CFG="./.np/config.resolved.yaml"
  mkdir -p "$(dirname "$RESOLVED_CFG")"
  awk -v base_url="${NOTEPUB_BASE_URL%/}/" \
      -v media_base_url="${NOTEPUB_MEDIA_BASE_URL%/}/" '
    BEGIN {
      in_site = 0
      seen_site = 0
      seen_base = 0
      seen_media = 0
    }
    function finish_site() {
      if (in_site) {
        if (!seen_base) {
          print "  base_url: \"" base_url "\" # set by build.sh"
        }
        if (!seen_media) {
          print "  media_base_url: \"" media_base_url "\" # set by build.sh"
        }
      }
      in_site = 0
    }
    /^site:[[:space:]]*$/ {
      finish_site()
      in_site = 1
      seen_site = 1
      seen_base = 0
      seen_media = 0
      print
      next
    }
    in_site && /^[A-Za-z_][A-Za-z0-9_]*:/ {
      finish_site()
      print
      next
    }
    in_site && /^[[:space:]]*base_url:/ {
      print "  base_url: \"" base_url "\" # set by build.sh"
      seen_base = 1
      next
    }
    in_site && /^[[:space:]]*media_base_url:/ {
      print "  media_base_url: \"" media_base_url "\" # set by build.sh"
      seen_media = 1
      next
    }
    { print }
    END {
      finish_site()
      if (!seen_site) {
        print ""
        print "site:"
        print "  base_url: \"" base_url "\" # set by build.sh"
        print "  media_base_url: \"" media_base_url "\" # set by build.sh"
      }
    }
  ' "$CFG" > "$RESOLVED_CFG"
  CFG="$RESOLVED_CFG"
  echo "Using resolved build config: $CFG"
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
  echo "[1/9] generate runtime config"
  ./.np/scripts/generate-runtime-config.sh "$CFG"
fi

echo "[2/9] index"
"$BIN" index --config "$CFG" --rules "$RULES"

echo "[3/9] validate links + markdown"
VALIDATE_HELP="$("$BIN" validate --help 2>&1 || true)"
if printf '%s\n' "$VALIDATE_HELP" | grep -q -- "-links"; then
  "$BIN" validate --config "$CFG" --rules "$RULES" --links
else
  echo "validate --links is not supported by this notepub binary; skipping"
fi

if printf '%s\n' "$VALIDATE_HELP" | grep -q -- "-markdown"; then
  "$BIN" validate --config "$CFG" --rules "$RULES" --markdown --markdown-format text
else
  echo "validate --markdown is not supported by this notepub binary; skipping"
fi

echo "[4/9] build"
"$BIN" build --config "$CFG" --rules "$RULES" --artifacts "$ART" --dist "$OUT"

echo "[5/9] export content media"
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

echo "[6/9] prepare icons manifest llms"
python3 ./.np/scripts/prepare-settings.py assets "$CFG" "$OUT"

echo "[7/9] normalize robots"
if [[ -f "$OUT/robots.txt" ]]; then
  awk '!/^LLM: /' "$OUT/robots.txt" > "$OUT/robots.txt.tmp"
  cat "$OUT/robots.txt.tmp" > "$OUT/robots.txt"
  rm -f "$OUT/robots.txt.tmp"
fi

echo "[8/9] mirror dist to ./dist (compat)"
rm -rf ./dist
mkdir -p ./dist
cp -R "$OUT"/. ./dist/

echo "[9/9] done -> $OUT"
