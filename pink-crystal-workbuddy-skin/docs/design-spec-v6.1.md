# Pink Crystal · 深空樱雾 v6.1 毛玻璃套装（修正版）

> **关键修正**：用户要的是「毛玻璃**透明度 70%**」= 70% 透明 = **不透明度 0.30**。
> v6 误做成 `0.70`（70% 不透明），导致输入框近黑、像没变。v6.1 改为 `0.30`。

## 控件毛玻璃规格（透明度语义）

| 控件 | 不透明度 | 透明度 | blur | 底色 |
|:---|:---|:---|:---|:---|
| **输入框** `.atm-modal-chat-input [class*="_mainArea_"]` / `[class*="_content_"]` | **0.30** | 70% | 16px | `rgba(16,8,26,0.30)` |
| 侧边栏 `[data-view-id=sidebar]` | **0.30** | 70% | 20px | `rgba(16,8,26,0.30)` |
| 详情面板 `[data-view-id=detail-panel]` | 0.50 | 50% | 18px | `rgba(16,8,26,0.50)` |
| 下拉框/弹出层 | 0.45 | 55% | 12px | `rgba(16,8,26,0.45)` |
| 对话区 | 透明 | 100% | — | `transparent` |

## 输入框生效要点（v6.1 修复）

输入框真实可见元素是 **CSS Module** 类：
- `[class*="_mainArea_"]` → 背景 `var(--atm-surface)`（遮蔽源 1）
- `[class*="_content_"]` → 背景 `var(--atm-chat-content-bg)`（遮蔽源 2）

v6 只覆盖 `--atm-surface` 漏了 `--atm-chat-content-bg`。v6.1 双源都覆盖，并**直接元素选择器打中**确保生效：

```css
/* 变量双源覆盖 */
body[data-application-name=workbuddy] .atm-modal-chat-input,
body[data-application-name=workbuddy] .atm-modal-chat-input *{
  --atm-surface:rgba(16,8,26,0.30) !important;
  --atm-chat-content-bg:rgba(16,8,26,0.30) !important;
  --cb-input-background:rgba(16,8,26,0.30) !important;
}
/* 直接打中可见输入体（绕过变量解析） */
body[data-application-name=workbuddy] .atm-modal-chat-input [class*="_mainArea_"],
body[data-application-name=workbuddy] .atm-modal-chat-input [class*="_content_"],
body[data-application-name=workbuddy] .atm-modal-chat-input textarea,
body[data-application-name=workbuddy] .atm-modal-chat-input [contenteditable]{
  background:rgba(16,8,26,0.30) !important;
  backdrop-filter:blur(16px) saturate(1.2) !important;
  border:1px solid rgba(255,77,156,0.35) !important;
  border-radius:12px !important;
}
```

## 配色
- 深空底色 `#10081a`（磨砂底）· 热粉 `#ff4d9c`（交互强调）· 浅粉 `#ffb6d0` · 白字 `#fff`

## 已知注意
- 侧边栏 0.30（70% 透明）若觉文字费眼，可回调到 0.45~0.55；输入框 0.30 是你要的 70% 透明，勿动。
- 动画 WebP 背景 base64 原样保留。
- 回滚点：`~/WorkBuddy/App_app.asar.bak.{时间戳}`
