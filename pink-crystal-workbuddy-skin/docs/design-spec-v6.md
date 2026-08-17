# Pink Crystal · 深空樱雾 — 毛玻璃套装 v6 设计规格

> 2026-07-19 Christina 定：输入框=毛玻璃70%透明度，控件统一匹配皮肤色
> 基于现有 pink-crystal-dynamic v5 动画皮肤升级

## 一、核心变更（v5 → v6）

| 维度 | v5 (当前) | v6 (毛玻璃套装) |
|:---|:---|:---|
| 输入框背景 | transparent (零磨砂) | rgba(16,8,26,0.70) + blur 16px |
| 输入框边框 | 无 | 1px solid rgba(255,77,156,0.35) + 聚焦光晕 |
| 输入框变量遮蔽 | 仅覆盖 --cb-input-background | 同时覆盖 --atm-surface（遮蔽源） |
| 侧边栏 | rgba(0,0,0,0.18) 无blur | rgba(16,8,26,0.85) + blur 20px |
| 详情面板 | rgba(0,0,0,0.30) 无blur | rgba(16,8,26,0.80) + blur 18px |
| 下拉框 | 仅变量覆盖 | 独立毛玻璃规则 + 边框 |
| Checkbox/Switch | 无 | accent pink 选中态 |
| Tooltip | 无 | 深空90%底 + 粉边框 |

## 二、控件毛玻璃规格

| 控件 | 透明度 | blur | saturate | 底色 |
|:---|:---|:---|:---|:---|
| 输入框 (.atm-modal-chat-input) | 70% | 16px | 1.2 | rgba(16,8,26,0.70) |
| 侧边栏 [data-view-id=sidebar] | 85% | 20px | 1.12 | rgba(16,8,26,0.85) |
| 详情面板 [data-view-id=detail-panel] | 80% | 18px | 1.08 | rgba(16,8,26,0.80) |
| 对话气泡区 | 透明 | — | — | transparent |
| 按钮正常态 | 实色 | — | — | #ff4d9c |
| 按钮 hover | 85% 热粉 | — | — | rgba(255,77,156,0.85) |
| 下拉框/弹出层 | 75% | 12px | 1.15 | rgba(16,8,26,0.75) |

## 三、配色体系

| 角色 | 色值 | 用途 |
|:---|:---|:---|
| 深空底色 | #10081a | 毛玻璃底色 |
| 热粉强调 | #ff4d9c | 按钮/聚焦环/选中态 |
| 浅粉辅助 | #ffb6d0 | hover态/次级文字 |
| 白色文字 | #ffffff | 主文字 |
| 半透文字 | rgba(255,255,255,0.78) | 次级文字 |

## 四、技术要点

1. .atm-modal-chat-input 局部遮蔽：同时覆盖 --cb-input-background 和 --atm-surface
2. 后代下放：.atm-modal-chat-input * 也需覆盖变量
3. textarea/contenteditable 需单独声明
4. 全屏动画背景 #root 的 WebP 不变
5. 皮肤 CSS 追加进主样式文件末尾（无 crossorigin）
6. 改 asar 后重签 + xattr -cr

## 五、执行流程

1. 备份当前 asar → 时间戳备份
2. 解包 asar → /tmp/wb_extract
3. 剥离旧 skin 块 (WORKBUDDY_SKIN:pink-crystal-dynamic → END SKIN)
4. 写入新 v6 CSS（保留动画 WebP base64）
5. 追加进主样式文件末尾
6. 重打包 → 替换 → 重签 → 去隔离
7. 验证 grep -a -c "pink-crystal-frost"
