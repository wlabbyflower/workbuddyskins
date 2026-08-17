#!/bin/bash
set -euo pipefail

APP="${WB_APP:-/Applications/WorkBuddy.app}"
ASAR="$APP/Contents/Resources/app.asar"
SKILLDIR="$(cd "$(dirname "$0")/../.." && pwd)"
PYTHON="${WB_PYTHON:-$HOME/.workbuddy/binaries/python/versions/3.13.12/bin/python3}"
MODE="dynamic"
BASELINE=""
NO_OPEN=0

usage() {
  echo "Usage: bash apply.sh [--mode static|dynamic] [--baseline /path/to/app.asar] [--no-open]"
}

die() {
  echo "[WorkBuddy Skin] ERROR: $*" >&2
  exit 1
}

while [ $# -gt 0 ]; do
  case "$1" in
    --mode|-m) MODE="${2:-}"; shift 2 ;;
    --baseline|-b) BASELINE="${2:-}"; shift 2 ;;
    --no-open) NO_OPEN=1; shift ;;
    --help|-h) usage; exit 0 ;;
    *) die "Unknown option: $1" ;;
  esac
done

case "$MODE" in
  static|dynamic) ;;
  *) die "--mode must be static or dynamic" ;;
esac

[ -d "$APP" ] || die "WorkBuddy app not found: $APP"
[ -f "$ASAR" ] || die "app.asar not found: $ASAR"
[ -x "$PYTHON" ] || PYTHON="$(command -v python3 || true)"
[ -n "$PYTHON" ] && [ -x "$PYTHON" ] || die "Python 3 not found"
[ -n "$BASELINE" ] || BASELINE="$ASAR"
[ -f "$BASELINE" ] || die "ASAR baseline not found: $BASELINE"

STAMP="$(date +%Y%m%d_%H%M%S)"
BACKUP_DIR="$HOME/WorkBuddy"
BACKUP="$BACKUP_DIR/App_app.asar.bak.$STAMP"
NEW_ASAR="/tmp/workbuddy-skin-$STAMP.asar"
SKIN_CSS="$SKILLDIR/assets/$MODE/skin.css"
mkdir -p "$BACKUP_DIR"

cleanup() {
  rm -f "$NEW_ASAR"
}
trap cleanup EXIT

echo "[WorkBuddy Skin] 1/6 Build $MODE skin"
"$PYTHON" "$SKILLDIR/tools/build_skin.py" "$MODE"
[ -f "$SKIN_CSS" ] || die "Built skin not found: $SKIN_CSS"

echo "[WorkBuddy Skin] 2/6 Patch ASAR"
"$PYTHON" "$SKILLDIR/tools/patch_asar.py" --input "$BASELINE" --skin "$SKIN_CSS" --output "$NEW_ASAR"

echo "[WorkBuddy Skin] 3/6 Back up current ASAR"
cp "$ASAR" "$BACKUP"
cmp -s "$ASAR" "$BACKUP" || die "Backup verification failed"

echo "[WorkBuddy Skin] 4/6 Stop WorkBuddy and deploy"
pkill -f "/Applications/WorkBuddy.app" 2>/dev/null || true
cp "$NEW_ASAR" "$ASAR"
cmp -s "$NEW_ASAR" "$ASAR" || { cp "$BACKUP" "$ASAR"; die "Deploy verification failed; restored backup"; }

echo "[WorkBuddy Skin] 5/6 Sign and verify"
if ! codesign --force --deep --sign - "$APP"; then
  cp "$BACKUP" "$ASAR"
  codesign --force --deep --sign - "$APP" || true
  die "Signing failed; restored backup"
fi
xattr -cr "$APP"
if ! codesign --verify --deep --strict --verbose=2 "$APP" >/dev/null 2>&1; then
  cp "$BACKUP" "$ASAR"
  codesign --force --deep --sign - "$APP" || true
  die "Signature verification failed; restored backup"
fi

echo "[WorkBuddy Skin] 6/6 Restart"
if [ "$NO_OPEN" -eq 0 ]; then
  open -a WorkBuddy
fi

trap - EXIT
cleanup
echo "[WorkBuddy Skin] Done"
echo "Backup: $BACKUP"
echo "Rollback: bash \"$SKILLDIR/macos/scripts/rollback.sh\" \"$BACKUP\""
