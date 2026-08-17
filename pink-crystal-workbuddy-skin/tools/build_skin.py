#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Pink Crystal · 重建 skin.css（双模式：dynamic / static）
========================================================
从「模板 + 独立 base64」复原完整皮肤 CSS，确保皮肤永远可重建、背景图永不丢。

  动态版(dynamic)：背景为 animated WebP（动画），包体较大。
  静态版(static)  ：背景为单帧 JPEG 静态图（无动画），包体小、加载快。

用法：
    python3 tools/build_skin.py            # 默认重建 dynamic
    python3 tools/build_skin.py dynamic    # 重建 dynamic
    python3 tools/build_skin.py static     # 重建 static

输入（按模式切换目录）：
    assets/<mode>/skin.template.css   （v6.2 全部规则，base64 处为占位符）
    assets/<mode>/bg.b64.txt          （纯 base64 文本）
输出：
    assets/<mode>/skin.css            （完整可注入皮肤）
"""
import os
import sys

SKILL = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
PLACEHOLDER = "__PINK_CRYSTAL_BG_B64__"

# 两种模式共享的「最终界面」硬规则（v6.2 毛玻璃 + 侧栏无边）
COMMON_REQUIRED = [
    "background-size:cover",
    "background-position:center center",
    "background-repeat:no-repeat",
    "background-attachment:fixed",
    "rgba(16,8,26,0.",   # 深色毛玻璃底（alpha 可调，不锁死具体值）
    "--atm-surface:",
    "--atm-chat-content-bg:",
    "border:none",        # 最终界面：侧栏完全无边框（彻底无竖线）
]

# 模式专属：背景数据类型校验
MODE_BG = {
    "dynamic": ("data:image/webp;base64,", "animated WebP"),
    "static":  ("data:image/jpeg;base64,", "静态 JPEG"),
}


def main():
    mode = (sys.argv[1] if len(sys.argv) > 1 else "dynamic").lower()
    if mode not in MODE_BG:
        raise SystemExit(f"❌ 未知模式：{mode}（仅支持 dynamic / static）")

    tpl = os.path.join(SKILL, "assets", mode, "skin.template.css")
    b64 = os.path.join(SKILL, "assets", mode, "bg.b64.txt")
    out = os.path.join(SKILL, "assets", mode, "skin.css")

    for p in (tpl, b64):
        if not os.path.isfile(p):
            raise SystemExit(f"❌ 缺少文件：{p}")

    with open(b64, "r") as f:
        b64data = f.read().strip()
    if not b64data:
        raise SystemExit("❌ bg.b64.txt 为空")

    with open(tpl, "r") as f:
        tpldata = f.read()
    if PLACEHOLDER not in tpldata:
        raise SystemExit(f"❌ 模板中未找到占位符 {PLACEHOLDER}")

    outdata = tpldata.replace(PLACEHOLDER, b64data)

    # 安全校验：重建产物必须保留最终界面全部规则
    missing = [k for k in COMMON_REQUIRED if k not in outdata]
    if missing:
        raise SystemExit(f"❌ 重建产物缺失关键规则：{missing}")

    # 模式专属：背景数据类型
    bg_marker, bg_label = MODE_BG[mode]
    if bg_marker not in outdata:
        raise SystemExit(f"❌ 重建产物未含 {bg_label} 背景（期望 {bg_marker}）")

    with open(out, "w") as f:
        f.write(outdata)

    print(f"✅ 已重建 {mode}/skin.css（{len(outdata):,} 字符，base64 {len(b64data):,} 字符）")
    print(f"   背景类型：{bg_label}")
    print(f"   路径：{out}")


if __name__ == "__main__":
    main()
