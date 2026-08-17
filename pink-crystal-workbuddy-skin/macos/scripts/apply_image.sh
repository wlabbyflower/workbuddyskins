#!/bin/bash
set -euo pipefail

APP="${WB_APP:-/Applications/WorkBuddy.app}"
ASAR="$APP/Contents/Resources/app.asar"
SKILLDIR="$(cd "$(dirname "$0")/../.." && pwd)"
PYTHON="${WB_PYTHON:-$HOME/.workbuddy/binaries/python/versions/3.13.12/bin/python3}"
IMAGE=""
BASELINE=""
NO_OPEN=0

usage() {
  echo "Usage: bash apply_image.sh --image /absolute/path/to/image [--baseline /path/to/clean.asar] [--no-open]"
}

die() {
  echo "[WorkBuddy Skin] ERROR: $*" >&2
  exit 1
}

while [ $# -gt 0 ]; do
  case "$1" in
    --image|-i) IMAGE="${2:-}"; shift 2 ;;
    --baseline|-b) BASELINE="${2:-}"; shift 2 ;;
    --no-open) NO_OPEN=1; shift ;;
    --help|-h) usage; exit 0 ;;
    *) die "Unknown option: $1" ;;
  esac
done

[ -n "$IMAGE" ] || { usage; die "--image is required"; }
[ -f "$IMAGE" ] || die "Image not found: $IMAGE"
[ -d "$APP" ] || die "WorkBuddy app not found: $APP"
[ -f "$ASAR" ] || die "app.asar not found: $ASAR"
[ -x "$PYTHON" ] || PYTHON="$(command -v python3 || true)"
[ -n "$PYTHON" ] && [ -x "$PYTHON" ] || die "Python 3 not found"

STAMP="$(date +%Y%m%d_%H%M%S)"
BACKUP_DIR="$HOME/WorkBuddy"
BACKUP="$BACKUP_DIR/App_app.asar.bak.$STAMP"
NEW_ASAR="/tmp/workbuddy-skin-$STAMP.asar"
mkdir -p "$BACKUP_DIR"

if [ -z "$BASELINE" ]; then
  BASELINE="$ASAR"
fi
[ -f "$BASELINE" ] || die "ASAR baseline not found: $BASELINE"

cleanup() {
  rm -f "$NEW_ASAR"
}
trap cleanup EXIT

echo "[WorkBuddy Skin] 1/7 Normalize background image"
"$PYTHON" "$SKILLDIR/tools/set_background.py" "$IMAGE"

echo "[WorkBuddy Skin] 2/7 Build static skin"
"$PYTHON" "$SKILLDIR/tools/build_skin.py" static

echo "[WorkBuddy Skin] 3/7 Patch ASAR from clean baseline"
"$PYTHON" "$SKILLDIR/tools/patch_asar.py" \
  --input "$BASELINE" \
  --skin "$SKILLDIR/assets/static/skin.css" \
  --output "$NEW_ASAR"

echo "[WorkBuddy Skin] 4/7 Back up current ASAR"
cp "$ASAR" "$BACKUP"
cmp -s "$ASAR" "$BACKUP" || die "Backup verification failed"

echo "[WorkBuddy Skin] 5/7 Stop WorkBuddy and deploy"
pkill -f "/Applications/WorkBuddy.app" 2>/dev/null || true
cp "$NEW_ASAR" "$ASAR"
cmp -s "$NEW_ASAR" "$ASAR" || { cp "$BACKUP" "$ASAR"; die "Deploy verification failed; restored backup"; }

echo "[WorkBuddy Skin] 6/7 Sign and verify"
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

echo "[WorkBuddy Skin] 7/7 Restart"
if [ "$NO_OPEN" -eq 0 ]; then
  open -a WorkBuddy
fi

trap - EXIT
cleanup
echo "[WorkBuddy Skin] Done"
echo "Backup: $BACKUP"
echo "Rollback: bash \"$SKILLDIR/macos/scripts/rollback.sh\" \"$BACKUP\""
