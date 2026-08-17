#!/bin/bash
# 双击运行版：调用同目录 apply.sh（默认动态皮肤）。可在 Terminal 弹窗查看进度。
cd "$(dirname "$0")"
bash ./apply.sh "$@"
echo
echo "按回车键关闭本窗口..."
read -r _
