#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Pink Crystal · 应急提取背景图 base64
====================================
当 assets/dynamic/bg.b64.txt 丢失/损坏时，从「已知良好的 asar」里把 #root 背景
WebP 的 base64 重新抽出来写回。可抽取来源（任选其一）：
  - 当前已部署：/Applications/WorkBuddy.app/Contents/Resources/app.asar
  - 历史备份：~/WorkBuddy/App_app.asar.bak.*（选最新的那个）

⚠️ 抽取到的是一个「WebP 动图」的 base64（当前背景 = 山海经动画，由用户 MP4 经
   ffmpeg libwebp_anim 转换而来；历史上也曾是粉发丝 WebP）。只要抽出来的是合法
   WebP（RIFF/WEBP 头），且与当前 assets/dynamic/skin.css 同源即可。抽错来源
   （非 Pink Crystal 皮肤）会被 WebP 头校验拦截。

用法：
    python3 tools/extract_bg.py                      # 默认抽当前已部署 asar
    python3 tools/extract_bg.py /path/to/backup.asar # 指定来源
抽完后再跑：python3 tools/build_skin.py 重建 skin.css
"""
import base64
import os
import re
import sys

SKILL = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
B64 = os.path.join(SKILL, "assets/dynamic/bg.b64.txt")
EXPECT_PREFIX = b"RIFF"  # WebP 文件头（base64 解码后）；任何合法 WebP 背景均可，不限定具体图

def _is_webp(b64: str) -> bool:
    """校验抽出的 base64 解码后是合法 WebP（RIFF....WEBP 头）。"""
    try:
        raw = base64.b64decode(b64[:36])  # 36 是 4 的倍数，解码得 27 字节，含 RIFF + WEBP
    except Exception:
        return False
    return raw[:4] == b"RIFF" and b"WEBP" in raw[:20]

def main():
    asar = sys.argv[1] if len(sys.argv) > 1 else \
        "/Applications/WorkBuddy.app/Contents/Resources/app.asar"
    if not os.path.isfile(asar):
        raise SystemExit(f"❌ asar 不存在：{asar}")

    with open(asar, "r", errors="ignore") as f:
        content = f.read()

    # 优先在 Pink Crystal 皮肤块内定位背景 webp（避免误抽 app 自带静态图标 webp）
    b64 = None
    s = content.find("/* WORKBUDDY_SKIN")
    if s != -1:
        e = content.find("/* END SKIN */", s)
        if e != -1:
            block = content[s:e + len("/* END SKIN */")]
            m = re.search(r"data:image/webp;base64,([A-Za-z0-9+/=]+)", block)
            if m:
                b64 = m.group(1)
    # 回退：全局第一个 webp
    if b64 is None:
        m = re.search(r"data:image/webp;base64,([A-Za-z0-9+/=]+)", content)
        if not m:
            raise SystemExit(f"❌ 在 {asar} 中未找到 webp base64（可能不是 Pink Crystal 皮肤）")
        b64 = m.group(1)

    if not _is_webp(b64):
        print(f"⚠️  警告：抽出的 base64 解码后不是合法 WebP（RIFF/WEBP 头不符）。")
        print("    这不是 Pink Crystal 动画背景！请勿写入，先确认 asar 来源正确。")
        raise SystemExit(1)

    with open(B64, "w") as f:
        f.write(b64)

    print(f"✅ 已提取 webp base64（{len(b64):,} 字符）写入：{B64}")
    print(f"   WebP 头校验通过：{b64[:12]}…")
    print("   下一步重建皮肤：python3 tools/build_skin.py")

if __name__ == "__main__":
    main()
