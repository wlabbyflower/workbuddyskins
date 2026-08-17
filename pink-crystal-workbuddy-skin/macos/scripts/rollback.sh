#!/bin/bash
###############################################################################
# Pink Crystal 换肤回滚 —— 恢复到指定（或最新）备份的 app.asar 并重签
# 用法：
#   bash rollback.sh                 # 自动选最新一个 App_app.asar.bak.* 备份
#   bash rollback.sh /path/to/App_app.asar.bak.YYYYmmdd_HHMMSS
#
# 关键修复：WorkBuddy 实际无 entitlements，提取失败/为空时不能传 --entitlements，
#          否则 codesign 报 "The entitlements file is empty"，回滚直接死。
###############################################################################
set -euo pipefail
APP="/Applications/WorkBuddy.app"
ASAR="$APP/Contents/Resources/app.asar"
log(){ printf "\033[1;35m[rollback]\033[0m %s\n" "$*"; }
die(){ printf "\033[1;31m[FAIL]\033[0m %s\n" "$*" >&2; exit 1; }

BAK="${1:-}"
if [ -z "$BAK" ]; then
  BAK="$(ls -1t "$HOME"/WorkBuddy/App_app.asar.bak.* 2>/dev/null | head -1 || true)"
  [ -n "$BAK" ] || die "未指定备份且未找到 ~/WorkBuddy/App_app.asar.bak.* "
  log "自动选用最新备份：$BAK"
fi
[ -f "$BAK" ] || die "备份不存在：$BAK"

# entitlements 可空
codesign -d --entitlements :- "$APP" > /tmp/wb_ent.plist 2>/dev/null || true
ENT_FLAG=""
if [ -s /tmp/wb_ent.plist ]; then ENT_FLAG="--entitlements /tmp/wb_ent.plist"; fi

log "退出 WorkBuddy..."
osascript -e 'tell application "WorkBuddy" to quit' 2>/dev/null || true
sleep 2; pkill -f "WorkBuddy.app/Contents/MacOS" 2>/dev/null || true; sleep 1

log "恢复 asar..."
cp "$BAK" "$ASAR" || die "恢复失败"
log "重签（ENT_FLAG=${ENT_FLAG:-<ad-hoc>}）..."
codesign --force --deep --sign - $ENT_FLAG "$APP" || die "重签失败"
xattr -cr "$APP" || true
codesign --verify --verbose=2 "$APP" >/dev/null 2>&1 || die "签名校验失败"
log "✅ 已回滚并重签。重开 WorkBuddy..."
open "$APP"
