---
name: pink-crystal-workbuddy-skin
description: "This skill should be used when the user wants to install, replace, tune, repair, verify, or roll back a WorkBuddy desktop theme, especially when the user supplies one image and expects a complete frosted-glass theme. It normalizes the image, preserves all known sidebar/input/message/menu/model-selector fixes, patches WorkBuddy's custom app.asar without full extraction, updates integrity metadata, backs up and signs the macOS app, restarts it fully, and supports rollback. It also supports the existing dynamic/static assets and Windows scripts."
agent_created: true
slug: pink-crystal-workbuddy-skin
version: 4.0.0
displayName: "WorkBuddy 换肤"
display_name: "WorkBuddy 换肤"
display_name_en: "WorkBuddy Skin"
description_zh: "提供一张图片即可完成 WorkBuddy 全量换肤：自动处理背景、保留毛玻璃和全部组件修复、备份与定点修改 app.asar、完整性校验、macOS 重签与彻底重启，并支持回滚。"
description_en: "Apply a complete WorkBuddy frosted-glass theme from one image, preserving component fixes while safely patching, verifying, signing, restarting, and supporting rollback."
visibility: "public"
---

# Pink Crystal · 深空樱雾 — WorkBuddy 桌面端主题定制服务

为 **WorkBuddy 桌面客户端（Electron 应用）** 提供可重复执行的完整视觉主题流程。收到一张用户图片后，执行图片规范化、静态背景替换、皮肤重建、自定义 ASAR 定点修改、完整性校验、备份、macOS 重签、彻底重启和回滚提示；不得依赖当前对话记忆，也不得重新猜测已确认的组件选择器。

默认保留当前经过实机修复的完整界面：清晰背景、透明工作区与侧栏、白色半透明毛玻璃输入框/菜单/tooltip、深色菜单文字、透明任务 hover/selected、以及 `qsclh`、`zugj5`、`162g9`、`1slp5` 模型选择器修复。仅替换背景图片，除非用户明确要求调整亮度、透明度、强调色或模糊强度。

主题同时保留两种构建产物：

| 产物 | 背景 | 包体 | 适用场景 |
|:---|:---|:---|:---|
| **动态版 `dynamic`** | animated WebP（动画帧序列） | 较大（base64 ~9.4 MB） | 追求灵动氛围、整机性能充裕 |
| **静态版 `static`** | 单帧 JPEG 静态图（无动画） | 轻量（base64 ~0.27 MB） | 低开销、快速加载、无需动画 |

两种产物**共享同一套最终界面规格**（毛玻璃参数、控件透明度、侧栏无边），仅背景介质不同。

> **💡 个性化换装服务声明（请先读）**
> 本 skill 是一套**通用个性化定制（换装）服务框架**，**不指定、不绑定任何特定图片或视频作为唯一素材**。
> 仓库内随附的「星空」背景仅为**示例（demo）资产**，用于演示效果与技术验证。
> - **企业用户**：可基于自身企业文化、品牌 LOGO、品牌主色及已获合法授权的图片，派生「企业需求版本」——重新设定强调色 `--wb-accent`、替换背景资产即可。
> - **个人用户**：可根据个人喜好，指定自己拥有或已获授权的任意图片 / 视频作为皮肤背景。
> - **权责说明**：任何被替换的图片 / 视频，其版权与合规责任由使用者自行承担；示例资产按「现状」提供仅供技术演示，分发前请替换为自有 / 已授权素材。

---

## ⚠️ 关键技术机制（踩坑沉淀，必读）

**WorkBuddy 的换肤变量体系是 `--cb-*`，不是 VSCode 的 `--vscode-*`！**

- 正确作用域选择器：`body[data-application-name=workbuddy]`
- 正确变量命名空间：`--cb-bg-primary`、`--cb-panel-bg-primary`、`--cb-input-background`、`--cb-vscode-editor-background` 等
- `app.asar` 中 `--cb-bg-primary` 被引用逾 120 处——这才是 WorkBuddy 真正读取的换肤变量。

若改用 VSCode 的 `--vscode-*` + `.monaco-workbench .part.*` 去覆盖背景（早期版本踩过的坑），
面板会**始终维持 WorkBuddy 原生灰色**，所有「透明 / 去灰」全部打偏 → 灰蒙蒙。

---

## 🎯 最终界面规格基线（唯一权威）

> 经 2026-07-19 最终确认：星空示例背景 + 毛玻璃套装 + **侧栏完全无边框（border:none，彻底无竖线）**。
> 后续微调一律改 `assets/{mode}/skin.template.css` 后重建，**不要直接手改 skin.css**（会被重建覆盖）。

### 配色体系

| 角色 | 色值 | 用途 |
|:---|:---|:---|
| 深空底色 | `#10081a` | 所有毛玻璃磨砂底（透明化后透出） |
| 热粉强调 | `#ff4d9c` | 按钮 / 聚焦环 / 选中态 / 边框 |
| 浅粉辅助 | `#ffb6d0` | hover 态 / 次级文字 |
| 白色文字 | `#ffffff` | 主文字 |
| 半透文字 | `rgba(255,255,255,0.78)` | 次级文字 |

### 各控件毛玻璃规格

| 控件 | 不透明度 | 「透明度」口径 | blur | saturate | 底色 |
|:---|:---|:---|:---|:---|:---|
| **输入框** `.atm-modal-chat-input` | **0.30** | **70% 透明** | `16px` | `1.2` | `rgba(16,8,26,0.30)` |
| 侧边栏 `[data-view-id=sidebar]` | 0.30 | 70% 透明 | `20px` | `1.12` | `rgba(16,8,26,0.30)` |
| 详情面板 `[data-view-id=detail-panel]` | 0.50 | 50% 透明 | `18px` | `1.08` | `rgba(16,8,26,0.50)` |
| 下拉框 / 弹出 `[role=listbox]/[role=menu]/monaco-menu` | 0.45 | 55% 透明 | `12px` | `1.15` | `rgba(16,8,26,0.45)` |
| 对话气泡区 `[data-view-id=main-content]` | 透明 | — | — | — | `transparent` |

> 🔴 **透明度语义铁律**：用户口述「毛玻璃**透明度 70%**」= **70% 透明 = 不透明度 0.30**。
> 历史上曾误做成 `rgba(16,8,26,0.70)`（70% 不透明），导致输入框近黑、像没变。
> 本 skill 基线一律用 **0.30**（输入框 / 侧栏）、0.50（详情）、0.45（下拉）。改值前务必确认用户指的是「透明度」还是「不透明度」。

### 背景图定位（四件套，缺一不可）

```css
#root{
  color:var(--wb-text) !important;
  background:linear-gradient(rgba(0,0,0,0.35),rgba(0,0,0,0.35)),
             url("data:image/<webp|jpeg>;base64,【背景base64】") !important;
  background-size:cover !important;             /* 铺满全屏 */
  background-position:center center !important; /* 居中 */
  background-repeat:no-repeat !important;      /* 不平铺 */
  background-attachment:fixed !important;      /* 不随滚动偏移 */
}
```

### 侧栏边框（最终界面：完全无边框 border:none）

```css
[data-view-id=sidebar]{
  background:rgba(16,8,26,0.30) !important;
  border:none !important;         /* 最终确认：侧栏完全无边框，彻底无竖线 */
  backdrop-filter:blur(20px) saturate(1.12) !important;
}
```

---

## 🔧 真实选择器与双遮蔽（输入框改不动的真凶）

WorkBuddy 组件常在**自身作用域**内重定义 `--cb-*`，**遮蔽** body 级同名变量，导致 body 级覆盖失效。

### 输入框双遮蔽源（必须同时覆盖）

输入框可见元素来自 CSS Module 作用域：
- `[class*="_mainArea_"]` → 背景读 `var(--atm-surface)`
- `[class*="_content_"]` → 背景读 `var(--atm-chat-content-bg)`

只覆盖 `--atm-surface` 一个会漏掉第二个，输入框仍是旧色。必须**两个都覆盖**，并用元素选择器直打兜底：

```css
body[data-application-name=workbuddy] .atm-modal-chat-input [class*="_mainArea_"],
body[data-application-name=workbuddy] .atm-modal-chat-input [class*="_content_"],
body[data-application-name=workbuddy] .atm-modal-chat-input textarea,
body[data-application-name=workbuddy] .atm-modal-chat-input [contenteditable]{
  --atm-surface:rgba(16,8,26,0.30) !important;
  --atm-chat-content-bg:rgba(16,8,26,0.30) !important;
  background:rgba(16,8,26,0.30) !important;  /* 直打兜底，绕过变量解析 */
  backdrop-filter:blur(16px) saturate(1.2) !important;
  border:1px solid rgba(255,77,156,0.35) !important;
  border-radius:12px !important;
}
```

---

## 单图全量换肤（默认入口）

当用户提供一张图片并要求替换 WorkBuddy 主题时，直接执行以下流程，不再询问动态/静态模式：

1. 读取图片确认内容、方向、清晰度和主体位置。默认保持原图构图，不擅自裁剪主体。
2. 运行 `tools/set_background.py <图片绝对路径>`，用 macOS `sips` 规范化为最长边不超过 2560px、质量 90 的 JPEG，并写入 `assets/static/bg.b64.txt`。
3. 运行 `tools/build_skin.py static`，从权威模板重建 `assets/static/skin.css`。禁止直接编辑生成后的 `skin.css`。
4. 运行 `macos/scripts/apply_image.sh --image <图片绝对路径>` 完成全流程。脚本默认以当前 `app.asar` 为基线，幂等剥离旧皮肤后重新注入；也可用 `--baseline <asar>` 指定干净基线。
5. 确认脚本输出包含 `Integrity: OK`、代码签名校验通过、新备份路径和回滚命令。
6. 用 `pgrep -fl WorkBuddy` 确认新的 Renderer 从当前 `app.asar` 加载。仅 `open -a WorkBuddy` 不算完整重启。
7. 让用户检查背景主体、输入框、左侧任务 hover、tooltip、用户菜单和模型选择器。出现新版本类名变化时，先读取真实 CSS/DOM，再更新模板和 `tools/patch_asar.py`，禁止猜选择器。

标准命令：

```bash
bash "$HOME/.workbuddy/skills/pink-crystal-workbuddy-skin/macos/scripts/apply_image.sh" \
  --image "/absolute/path/to/background.png"
```

只需替换背景时，保留现有全部样式参数和组件修复。仅当用户明确提出视觉调整时，修改 `assets/static/skin.template.css`：

- 背景亮暗：调整 `#root` 的遮罩 alpha。
- 毛玻璃深浅：调整目标组件的 RGBA alpha。
- 清晰度：保持主工作区 `backdrop-filter:none`，仅对输入框和弹层使用 blur。
- 菜单文字：白色毛玻璃表面默认使用 `rgba(0,0,0,0.85)` 主文字、`rgba(0,0,0,0.60)` 次文字。
- 中国用户截图中的模型倍率：直接检查 `._modelCredits_162g9_126`，不要误当成旧版 `qsclh` description。

## 📦 一键安装（兼容入口）

### 执行流程

用户触发本 Skill 后，按以下步骤交互：

1. **前置检查**：确认安装路径、管理员权限、Node.js、app.asar 可读写（详见下方「安装前置检查」）。任一不满足则停止并告知用户。
2. **询问用户意图**：
   - A. 直接安装内置主题（深空樱雾，粉色系）
   - B. 自定义背景图和品牌配色后再安装
3. **如果选 A（直接安装）**：询问动态版还是静态版，然后执行安装。
4. **如果选 B（自定义）**：
   - 引导用户提供背景素材（图片或视频路径）和品牌主色（Hex 值）
   - 将素材转为 base64 写入 `assets/{mode}/bg.b64.txt`
   - 将品牌主色写入 `assets/{mode}/skin.template.css` 的 `--wb-accent` 及相关 RGBA 值
   - 执行 `python3 tools/build_skin.py <mode>` 重建 skin.css
   - 询问动态版还是静态版，然后执行安装
5. **深色模式提醒**：本主题为深色皮肤（深空底色 `#10081a` + 白色文字），需切换 WorkBuddy 到深色模式才能正确显示。安装前提醒用户：在 WorkBuddy 中按 `Cmd/Ctrl+Shift+P` → 输入 `Color Theme` → 选择深色主题（如 Default Dark Modern）。浅色模式下白字无法在深色背景上凸显，会导致看不清。
6. **执行安装**：运行 apply 脚本，备份原 app.asar，注入主题，重启 WorkBuddy。
7. **告知回滚方式**：安装完成后告知用户备份路径和 rollback 脚本位置。

### 安装前置检查（必做）

执行换肤前，先确认以下四项，任一不满足则停止并告知用户：

1. **WorkBuddy 安装路径**：不限于默认目录，需实际定位到 `WorkBuddy.exe`（Windows）或 `WorkBuddy.app`（macOS）所在位置。可检查的路径包括但不限于：
   - Windows：`%LOCALAPPDATA%\Programs\WorkBuddy`、`%ProgramFiles%\WorkBuddy`、`%ProgramFiles(x86)%\WorkBuddy`、`D:\Program Files\WorkBuddy` 及其他自定义盘符
   - macOS：`/Applications/WorkBuddy.app`
   - 若以上均未找到，询问用户 WorkBuddy 的实际安装路径
2. **管理员权限**：Windows 需管理员命令提示符；macOS 需有 `codesign` 权限。权限不足时提示用户切换终端。
3. **Node.js 已安装**：执行 `node --version` 确认可用；未安装时提示从 https://nodejs.org 下载 LTS 版本。
4. **目标 app.asar 可读写**：确认 `<安装路径>\resources\app.asar`（Windows）或 `<安装路径>/Contents/Resources/app.asar`（macOS）存在且当前用户可写入。

### 执行安装

> 脚本会退出 WorkBuddy 以替换 `app.asar`。执行前必须确认已生成备份，并在失败时自动恢复。

#### macOS
```bash
# 推荐：一张图片完成规范化、构建、定点注入、签名和重启
bash ./macos/scripts/apply_image.sh --image "/absolute/path/to/image.png"

# 直接应用已内置的动态或静态资产时使用
bash ./macos/scripts/apply.sh --mode dynamic
```

本机 WorkBuddy 自定义 ASAR 禁止整包 extract/repack；`apply_image.sh` 和 `apply.sh` 均必须通过 `tools/patch_asar.py` 定点修改。

#### Windows
```cmd
windows\scripts\apply.bat            # 动态（默认）
windows\scripts\apply.bat static     # 静态
```
> Windows 无需 `codesign` / `xattr`，部署比 macOS 更简洁。需本机已装 Node.js（asar 依赖）。

若 WorkBuddy 未安装在默认路径，将实际安装路径作为环境变量传入：
```cmd
set "WB_PATH=D:\your\path\WorkBuddy"
windows\scripts\apply.bat
```

**幂等保障**：apply 脚本每次先剥离旧皮肤块（前缀匹配 `/* WORKBUDDY_SKIN` + `lastIndexOf(END SKIN)`，
兼容 `pink-crystal` / `pink-crystal-frost` / `pink-crystal-frost-static` 三种标记），再重注入，
**绝不累积叠加**。执行前自动时间戳备份原 `app.asar`。

---

## 🔄 还原 / 回滚

```bash
# macOS
bash ./macos/scripts/rollback.sh                 # 自动选最新备份
bash ./macos/scripts/rollback.sh /path/to/App_app.asar.bak.YYYYmmdd_HHMMSS

# Windows
windows\scripts\rollback.bat                      # 自动选最新备份
```

- 备份点：`~/WorkBuddy/App_app.asar.bak.*`（macOS）/ `%USERPROFILE%\WorkBuddy\App_app.asar.bak.*`（Windows）
- 重装 / 升级 WorkBuddy 会还原 `app.asar`，主题丢失，重跑 apply 即可（约 1 分钟）。

---

## 🛠 手动降级 SOP（脚本不可用时的保底）

apply 脚本已封装全流程；若脚本环境异常，按此 7 步手动重装（系统终端）：

```bash
ASAR="/Applications/WorkBuddy.app/Contents/Resources/app.asar"   # macOS 路径；Windows 见 apply.bat
WORK="/tmp/wb_pink_$(date +%s)"
SKILL=~/.workbuddy/skills/pink-crystal-workbuddy-skin
NODE=$(ls ~/.workbuddy/binaries/node/versions/*/bin/node | head -1)
ASARBIN=$(ls ~/.workbuddy/binaries/node/workspace/node_modules/.bin/asar 2>/dev/null || echo "")

# 0. 确保 skin.css 就位（若丢失：python3 $SKILL/tools/build_skin.py <mode>）
# 1. 备份
cp "$ASAR" ~/WorkBuddy/App_app.asar.bak.$(date +%Y%m%d_%H%M%S)
# 2. 解包
unset NODE_OPTIONS
if [ -n "$ASARBIN" ]; then "$ASARBIN" extract "$ASAR" "$WORK";
else npx --yes @electron/asar extract "$ASAR" "$WORK"; fi
# 3. 剥离旧块（幂等）
MAIN=$(ls "$WORK"/renderer/assets/index-*.css | head -1)
"$NODE" -e 'const fs=require("fs");const f=process.argv[1];let s=fs.readFileSync(f,"utf8");const a=s.indexOf("/* WORKBUDDY_SKIN");const e=s.lastIndexOf("/* END SKIN */");if(a>=0&&e>a){s=s.slice(0,a)+s.slice(e+"/* END SKIN */".length);fs.writeFileSync(f,s);}' "$MAIN"
# 4. 注入
cat "$SKILL/assets/dynamic/skin.css" >> "$MAIN"
# 5. 重打包
if [ -n "$ASARBIN" ]; then "$ASARBIN" pack "$WORK" /tmp/new_app.asar;
else npx --yes @electron/asar pack "$WORK" /tmp/new_app.asar; fi
# 6. 退出 + 原子替换
osascript -e 'tell application "WorkBuddy" to quit' 2>/dev/null || true   # Windows 用 taskkill /IM WorkBuddy.exe /F
sleep 3; pkill -f "WorkBuddy.app/Contents/MacOS" 2>/dev/null || true; sleep 2
mv /tmp/new_app.asar "$ASAR"
# 7. 重签 + 去隔离（仅 macOS；WorkBuddy 无 entitlements，纯 ad-hoc）
codesign --force --deep --sign - "/Applications/WorkBuddy.app"   # Windows 跳过此步
xattr -c "$ASAR"; xattr -c "/Applications/WorkBuddy.app/Contents/MacOS/Electron"
```

---

## 🖼 背景资产（可替换示例，非锁定）

> 🔴 **背景资产 = 一段 base64 内嵌于 `#root` 背景的媒体**，与「个性化服务」声明一致：
> **不绑定任何特定图/视频**。当前随附示例为「星空」动画（动态版）与「星空静态帧」（静态版），
> 均由用户自有素材经 VideoGen / ffmpeg 生成，**仅为演示**。
> 任何合法 WebP（动态）/ JPEG（静态）背景均可替换，不存在「前缀固定不可换」。

为防 `skin.css` 单文件丢失导致背景无法复原，采用**模板 + 独立 base64 分离存储**：

```
assets/
├── dynamic/
│   ├── skin.css            # 完整动态皮肤（注入目标）
│   ├── skin.template.css   # 模板（base64 处为占位符 __PINK_CRYSTAL_BG_B64__）
│   └── bg.b64.txt          # 动态背景 base64 存档（animated WebP）
└── static/
    ├── skin.css            # 完整静态皮肤（注入目标）
    ├── skin.template.css   # 模板（同占位符）
    └── bg.b64.txt          # 静态背景 base64 存档（JPEG 单帧）
tools/
├── build_skin.py           # 读 template + b64 → 重建 skin.css（双模式，带规则校验）
└── extract_bg.py           # 应急：从 asar 抽 base64 写回 bg.b64.txt（校验媒体头）
docs/
├── design-spec-v6.md          # 原始设计规格（v6，毛玻璃套装初版）
└── design-spec-v6.1.md        # 设计规格修正版（v6.1：澄清「70%透明=0.30不透明」+ 输入框双源遮蔽）
```

- **正常安装**：apply 直接用 `assets/{mode}/skin.css`，无需 build。
- **skin.css 丢了**：`python3 tools/extract_bg.py`（从 asar 抽）→ `python3 tools/build_skin.py <mode>` 重建。
- **改样式**：编辑 `assets/{mode}/skin.template.css` → `python3 tools/build_skin.py <mode>` → 重跑 apply。
- **换背景资产（个性化核心流程）**：
  1. 准备自有 / 已授权素材（图片或视频）；
  2. 视频 → animated WebP：`ffmpeg -i in.mp4 -vf "fps=15,scale=1280:-2" -c:v libwebp_anim -lossless 0 -q:v 60 -loop 0 out.webp`（静态版则用 `ffmpeg -i in.mp4 -ss 2 -frames:v 1 -vf scale=1280:-2 out.jpg`）；
  3. 把媒体 base64 写入 `assets/{mode}/bg.b64.txt`（覆盖示例资产）；
  4. 如需调整文字可读性，改 `skin.template.css` 中 `linear-gradient(rgba(0,0,0,0.35),...)` 的遮罩强度；
  5. `python3 tools/build_skin.py <mode>` → 重跑 apply 部署。
  - ⚠️ 视频生成模型不支持 `aspect_ratio` 手动比例（HTTP400），image-to-video 时必须省略该字段让其自动沿用原图比例。
  - ⚠️ 企业版重新着色：将 `--wb-accent`（默认 `#ff4d9c`）改为企业品牌主色即可批量替换所有粉色调。

---

## 📋 已知坑（全量，已在脚本/模板中固化）

1. **灰蒙蒙真根因**：用 `--vscode-*` 变量改背景无效（WorkBuddy 不读它）。必须用 `--cb-*` + `body[data-application-name=work]`.
2. **局部变量遮蔽**：组件在自身作用域重定义 `--cb-*`（如 `--cb-input-background: var(--atm-surface)`），遮蔽 body 级变量。必须挖出真实 class（`atm-*` 命名空间），用同名选择器 `!important` 同时覆盖变量与 `background`，并对后代下放。
3. **双遮蔽源**：输入框背景同时读 `--atm-surface` 与 `--atm-chat-content-bg`，漏一个仍是旧色。两者都必须覆盖。
4. **透明度方向做反**：「透明度 70%」= 不透明度 0.30，不是 0.70。做反会变近黑实心块。
5. **背景定位缺失**：`#root` 仅 `url(...)` 会按原像素左上角平铺、未铺满未居中 = 看着乱。必须补 `cover / center / no-repeat / fixed`。
6. **背景可替换（软校验）**：任何合法媒体背景均可换。抽取/校验只认媒体头（WebP: `RIFF/WEBP`；JPEG: `FFD8`），不限定具体图。换图流程见上方「背景资产」章节。
7. **独立 CSS `<link>` 不可用**：asar 协议下 `<link crossorigin>` 因 CORS 静默失败。必须内联注入主样式文件末尾。
8. **重签名（仅 macOS）**：改 asar 后必须 `codesign --force --deep --sign -`。WorkBuddy **无 entitlements**，传空 plist 会报 `empty` → 仅当 plist 非空才传 `--entitlements`，否则纯 ad-hoc 签名。Windows 无此步骤。
9. **剥离旧块用前缀匹配** `/* WORKBUDDY_SKIN` + `lastIndexOf(END SKIN)`，否则遇不同标记会剥离失败、块累积。
10. **沙箱 NODE_OPTIONS**：`NODE_OPTIONS=--use-system-ca` 会让 `node -e` 崩 → 脚本开头 `unset NODE_OPTIONS`。
11. **asar 定位（跨平台）**：macOS 优先用 `~/.workbuddy/binaries/node/workspace/node_modules/.bin/asar`，失败回退 npx；Windows 优先本地 `node_modules/.bin/asar` 或全局 `asar`，再回退 `npx --yes @electron/asar`。受限网络下 npx 可能卡死，离线环境请先 `npm install -g @electron/asar`。
12. **重启必须真杀进程，不能只 `open -a`**（本机踩坑 5 轮白字白块的根本原因）：`open -a WorkBuddy` 只是把**已运行**的 GUI 带到前台，**不会重新加载 `app.asar`**——渲染进程一直持有旧（白字）文件在内存里，表现为"改了但没生效/重启也没用"。正确做法：先 `pkill -f "WorkBuddy.app"` 杀掉全部 Electron 进程（含 Helper/daemon），再 `open -a WorkBuddy`；**验证时务必确认新主进程 PID 的启动时间晚于本次部署时间**（`ps -eo pid,lstart,command | grep MacOS/Electron`），否则只是旧进程被聚焦、样式没变。替换用 `cp` 覆盖后同样要先杀进程再启动。
13. **`extract_bg.py` 缺 `import base64` 误报**：`_is_webp()` 调 `base64.b64decode` 但文件头只 `import os, re, sys`，`NameError` 被 `except` 吞掉 → 校验恒返 False → 误报「不是合法媒体」。修复：补 `import base64`（已固化）。凡是脚本靠 `except` 兜底校验的，务必先确认被调函数所属模块已 import。

---

## 🩹 本机实测补充（wlabby 的 macOS WorkBuddy，2026-08-17）

直接跑 `macos/scripts/apply.sh` 在本机**会失败**，根因是本机 `app.asar` 的特殊格式：

1. **`asar extract` 直接 ENOENT 崩溃**：本机 asar 在 `app.asar.unpacked` 里引用了跨平台二进制（win32/linux/arm64 的 ripgrep、qimei、nunjucks 等），这些变体在 macOS 上不存在 → `@electron/asar` extract 因找不到文件报错。**不要整包 extract/repack**：会把必须保持 unpack 的原生二进制错误地内联进 asar，导致搜索/原生模块等功能损坏。
2. **自定义 16 字节头部**：本机 asar 不是标准 8 字节头（4 字节 size + 4 字节 0），而是 **16 字节前缀 + JSON + 2 字节 padding**。JSON 长度在 `@12`（uint32 `jsonLen`），数据区起点 `dataStart = 16 + jsonLen + 2`。`@electron/asar` 自带的 read（读 8 字节、取首 uint32 当 size）**读不了**本机 asar。
3. **每文件带 `integrity`**：`{algorithm:"SHA256", hash:<hex>, blockSize:4194304, blocks:[<hex>]}`，`offset` 是**字符串**。单块（<4MB）文件 `blocks[0]===hash`。改内容后必须重算 SHA256 并回写 `hash` 与 `blocks[0]`，否则完整性校验拒绝加载。

**可用且已验证的安全改法（外科手术式 patch，只动 `renderer/assets/index-*.css`）**：
- 从 `@12` 读 `jsonLen`，`JSON.parse(buf.toString('utf8',16,16+jsonLen))`；`dataStart = 16+jsonLen+2`；用 `SHA256(内容)===integrity.hash` 反推确认 `dataStart`。
- 新内容 = 原内容 + 皮肤 CSS；重算 SHA256 写回 `integrity.hash`/`blocks[0]`；`size += skinLen`；把 **`offset` 为字符串、`>idxOffset`、且非 `unpacked`** 的文件 `offset` 各 `+skinLen`（`String(Number(offset)+skinLen)`）。unpacked 文件不参与移位。
- **关键技巧**：上述被改数值（size 151390→~85万、后续 offset +~70万）位数不变 → 重新 `JSON.stringify(header)` 字节长度与原 `jsonLen` **完全相同**，于是 16 字节前缀 + 2 字节 padding 原样保留，无需逆向头部格式。落盘前断言 `newJson.length === jsonLen`。
- 落盘：`prefix(16) + newJson + pad2(2) + dataRegion(skin 插入到 index.css 末尾)`。
- 替换后必须 `codesign --force --deep --sign - /Applications/WorkBuddy.app` 且 `xattr -cr`，否则签名失效无法启动。
- 替换用 `mv`（原子改名，运行中进程持旧 inode，安全）；随后重启客户端加载新 asar。
- 备份在 `~/WorkBuddy/App_app.asar.bak.*`；回滚用 `macos/scripts/rollback.sh`（或手动 `cp` 备份覆盖 `app.asar` 后重签）。

4. **变量不只定义在 index.css**：`renderer/assets/` 下有几十个 chunk css（Vite 分包）。核心换肤变量 `--wb-*` 的设计 token **定义在 `renderer/assets/cb-bridge-BGn0PDcg.css`**（107 KB），不在 index.css。改样式时要用脚本跨全部 css 反查变量**定义源**，别只 grep index.css。
5. **侧栏「白底黑字」真根因**（浅色主题下）：
   - 侧栏背景 `.teams-container [data-view-id="sidebar"]{ background: var(--wb-home-bg-primary) }`，浅色 `.teams-container.is-mac{ --wb-home-bg-primary:#f2f2f2; --wb-home-bg-secondary:#ffffff }`，深色 `[data-theme="dark"] .teams-container.is-mac{ --wb-home-bg-primary:#1f1f1f; --wb-home-bg-secondary:#141414 }`。
   - 列表文字 `--wb-color-text-primary: var(--wb-palette-black-100)`（浅色=纯黑 `#000000`）、`--wb-color-text-secondary: var(--wb-palette-black-70)`、`--wb-color-text-tertiary: var(--wb-palette-black-50)`。
   - 选中项 `--wb-bg-item-selected:#f4f5f5`、hover `--wb-bg-hover: color-mix(in srgb, black 5%, transparent)`、active `--wb-bg-active: black 8%`。
   - **修法**：在皮肤里用 `.teams-container.is-mac{ --wb-home-bg-primary: rgba(16,8,26,0.26) !important; --wb-home-bg-secondary: transparent !important }` + `[data-view-id=sidebar], [data-view-id=sidebar] *{ --wb-color-text-*:白系; --wb-bg-primary/content/card:transparent; --wb-bg-hover/active/item-selected:粉色 rgba(255,77,156,x) }` 双管齐下。变量覆盖必须命中**组件自身作用域**（`.teams-container.is-mac` 等），只写在 `body[data-application-name=workbuddy]` 会被遮蔽。
6. **`--cb-*` vs `--wb-*` 两套并存**：`--cb-*` 是旧版/别名（用于输入框 `--atm-*`、编辑器等），`--wb-*` 是新版设计 token 体系（侧栏/home 界面大量使用）。浅色主题下侧栏白底问题只能改 `--wb-home-bg-*` + `--wb-color-text-*`，改 `--cb-*` 无效。
7. **左侧任务行 hover/selected 必须命中真实卡片**：通用 `[role=option]`、菜单项或伪元素覆盖可能无法清掉整块深色圆角背景。真实组件是 `.conversation-agent-card`；其 chunk CSS 使用 `--wb-todo-menu-bg-hover` / `--wb-todo-menu-bg-active`，CSS Module 还会通过 `._card_*[role=button]:hover` 读取 `--cb-hover-bg`、选中态读取 `--cb-bg-primary`。修复时需在侧栏或 `.conversation-list` 作用域将这四个变量设为 `transparent !important`，并对 `.conversation-agent-card:hover`、`[class*="selected"]`、`:focus`、`:focus-visible` 同时清除 `background`、`border`、`outline`、`box-shadow`。卡片具备 `tabIndex=0`，所以只处理 hover/selected 会遗漏键盘焦点环。
8. **批量任务父包装层也必须覆盖**：`.conversation-item--batch:has(.conversation-agent-card[class*="selected"])` 会在父层单独读取 `--wb-todo-menu-bg-active` 绘制 active 背景；即使子 `.conversation-agent-card` 已透明，父层仍可能留下整块黑底。需要同时覆盖父层的默认、hover、focus、focus-visible 和 `:has(...selected)` 状态，并清除 `::before` / `::after` 的背景、边框、阴影；另外覆盖 `.conversation-agent-card[class*="menuOpen"]`，避免打开操作菜单时恢复深色背景。
9. **任务列表的 tooltip 提示也是黑底**：截图里覆盖任务文字的黑色圆角浮层是 `.cb-tooltip`（含 `_cardSurface_` 变体），默认 `rgba(0,0,0,0.7)`。皮肤里要把它和 `.cb-tooltip--dark`、`.cb-toolbar-tooltip`、`[role="tooltip"]` 一起改成透明毛玻璃（如 `rgba(16,8,26,0.45)` + `backdrop-filter`），并强制内容白字、箭头粉色，否则 hover/聚焦任务时仍会出现黑色块。
10. **模型选择器必须命中真实 CSS Module 类，`.cr-model-selector__*` 是错的**：该组件实际来自 `renderer/assets/src-ByKu1LcX.css`，类名是哈希 Module 类——菜单容器 `._menu_qsclh_83._modelSelectorMenu_qsclh_110`（子菜单 `._subMenu_qsclh_111._modelSelectorMenu_qsclh_110`），头部 `._header_qsclh_328._modelSelectorHeader_qsclh_338`，模型项 `._modelItem_`、Auto 行 `._autoModeItem_`/`_autoModeLabel_`/`_autoModeMessage_`、选中 `._selected_`。白块根因是 `background-color: var(--cb-dropdown-bg-color, var(--cb-panel-bg-primary))`，而 `--cb-dropdown-bg-color` 最终落到 `--vscode-dropdown-background` 默认 `#fff`；文字走 `--cb-text-primary`/`-chat-input-area-header-font-color` 默认浅灰。修复必须用 `[class*="_modelSelectorMenu_"]` 等真实类注入 `--cb-dropdown-bg-color`/`--cb-panel-bg-primary`=`rgba(255,255,255,0.18)`+`blur(12px)`、`--cb-text-primary`/`--cb-input-foreground`/`--chat-input-area-header-font-color`=`rgba(0,0,0,0.85)`、`--cb-hover-bg`/`--cb-list-item-selected-bg` 白色半透明、`--cb-input-border-color`/`--cb-dropdown-border-color` 白色边框、`--cb-popover-divider` 淡黑；选中勾选保留 `#00b96b` 绿。任何 `.cr-model-selector__*` 或凭空猜测的模块类都不会匹配，会表现为“改了但没生效”。
11. **模型选择器的二级/三级子菜单是独立组件 `ModelSubMenu`（哈希 `1slp5`），不在 `[class*="_modelSelectorMenu_"]` 作用域内**：hover 模型项弹出的「部署的模型 / 消耗速度 / x N 倍数 / 深度思考 / 上下文窗口」面板来自单独 chunk，类名 `_subMenu_1slp5_6`（容器）、`_modelName_1slp5_36`、`_metaLabel_1slp5_99`（「部署的模型」标签）、`_metaValue_1slp5_104`（「x N」倍数）、`_actionLabel_1slp5_130`、`_actionValue_1slp5_135`、`_chevron_1slp5_147`（箭头，源码 `var(--cb-text-primary,#d2d3e0)` 亮回退）、三级面板 `_subMenuPanel_1slp5_6`/`_panelItem_1slp5_6`/`_panelSectionLabel_1slp5_183`。这些类**不含 `_modelSelectorMenu_`**，所以只覆盖主菜单的选择器会漏掉子菜单文字。修复：皮肤模板第 8c 节专门对 `[class*="_subMenu_1slp5_"]` 全类写 `!important` 黑字+白玻璃，并加 chevron 修复与「终极兜底」（对所有文本元素强制黑字、排除图标/勾选/折扣蓝/促销蓝/金色徽章）。**双保险**：patch 脚本同时直接改 `src-ByKu1LcX.css` 源 chunk，把这些 `1slp5` 类的 `color`/`background` 硬编码成黑字+白玻璃，source 与皮肤双重覆盖，未来版本 class 哈希变了也能兜底。
12. **当前模型选择器主菜单也是独立 Portal 组件（根 `zugj5`，模型行 `162g9`），不能假设它位于 `_modelSelectorMenu_` 下**：根容器是 `._popover_zugj5_8`，分组粘性标题是 `._groupLabel_zugj5_80`，Auto 区是 `._autoModeSection_zugj5_200`，列表分隔是 `._modelListAfterDivider_zugj5_53`；模型行是 `._modelItem_162g9_1`，右侧 `1x` / `0.25x` 倍率的真实类是 `._modelCredits_162g9_126`，不是旧版 `._description_qsclh_299`。修复时直接对 `zugj5` 根注入白色毛玻璃与深色变量，将 group label/Auto 区设为透明、2px 白色分隔改为 1px 淡灰，并对 `_modelCredits_162g9_126` 写 `rgba(0,0,0,0.60)!important`；patch 脚本同时直接改 `src-ByKu1LcX.css` 作为双保险。
13. **改完务必真重启并核验新进程**：本机曾因 `open -a` 只聚焦旧进程、渲染进程持旧 asar，导致连续多轮"白字白块改不好"。每次部署先 `pkill -f "/Applications/WorkBuddy.app"`，再替换、重签并 `open -a WorkBuddy`；用 `pgrep -fl WorkBuddy` 确认新 Renderer 的 `--app-path` 指向当前 asar。皮肤核验还要确认 `WORKBUDDY_SKIN` 标记、`_popover_zugj5_8`/`_modelCredits_162g9_126`/`_subMenu_1slp5_` 规则，以及 `codesign --verify --deep --strict` 通过。

---

## 📁 文件清单（v3.1.0 封装后）

```
pink-crystal-workbuddy-skin/
├── SKILL.md                       # 本文件
├── README.md                      # 仓库说明（含个性化服务声明）
├── DISCLAIMER.md                  # 资产版权与个性化权责声明
├── assets/
│   ├── dynamic/
│   │   ├── skin.css               # 完整动态皮肤（animated WebP 背景，注入目标）
│   │   ├── skin.template.css      # 模板（base64 占位符，便于改样式/换色）
│   │   └── bg.b64.txt             # 动态背景 base64 存档（示例：星空 animated WebP）
│   ├── static/
│   │   ├── skin.css               # 完整静态皮肤（JPEG 单帧背景，轻量）
│   │   ├── skin.template.css      # 模板（同占位符）
│   │   └── bg.b64.txt             # 静态背景 base64 存档（示例：星空静态帧 JPEG）
├── tools/
│   ├── set_background.py          # 任意常见图片 → 规范化 JPEG + static/bg.b64.txt
│   ├── build_skin.py              # 模板+base64 → 重建 skin.css（支持 dynamic/static）
│   ├── patch_asar.py              # 自定义 ASAR 定点补丁、offset/integrity 更新与全包校验
│   └── extract_bg.py              # 应急从 asar 抽 base64
├── docs/
│   ├── design-spec-v6.md          # 原始设计规格（v6）
│   └── design-spec-v6.1.md        # 设计规格修正版（v6.1：澄清「70%透明=0.30不透明」+ 输入框双源遮蔽）
├── macos/scripts/
│   ├── apply_image.sh             # 推荐：单图全流程（规范化+构建+定点补丁+备份+签名+重启）
│   ├── apply.sh                   # 静态/动态资产安全定点注入入口（同样禁止整包解压）
│   ├── apply.command              # macOS 双击启动（默认动态入口）
│   └── rollback.sh                # 一键回滚
└── windows/scripts/
    ├── apply.bat                  # 一键安装（双模式，参数 static/dynamic，离线友好）
    ├── inject.js                  # 注入辅助（幂等剥离旧块+注入新块+清理 index.html，规避 cmd 引号问题）
    └── rollback.bat               # 一键回滚
```

## 验收标准

完成单图换肤后逐项确认：

- 背景保持清晰，主体未被错误裁切或全屏 blur。
- 输入框、用户消息、左侧任务 selected/hover、tooltip、用户菜单均符合当前白色半透明毛玻璃方案，不出现黑块、粉红描边或不透明白块。
- 模型主菜单和二三级面板文字为深色；`1x` / `0.25x` 等倍率为深灰；分组粘性标题透明。
- ASAR 补丁输出 `Integrity: OK`，已部署文件与输出文件一致，`codesign --verify --deep --strict` 通过。
- 旧 WorkBuddy 进程已结束，新 Renderer 的 `--app-path` 指向当前 `/Applications/WorkBuddy.app/Contents/Resources/app.asar`。
- 回滚备份存在且与替换前 ASAR 完全一致。

## 安全边界

- 不联网、不上传用户图片、不读取图片以外的个人文件。
- 不使用 `sudo`，不修改 WorkBuddy.app 之外的应用文件。
- 替换前必须备份；备份失败立即停止，签名或部署失败自动恢复。
- 不整包 extract/repack 本机自定义 ASAR，避免损坏 unpacked 原生二进制。
- 不删除历史备份；只在 `/tmp` 清理本次生成的新 ASAR。

## 注意事项

- **应用更新后需重新应用**：WorkBuddy 升级会还原 `app.asar`，主题丢失。重跑 apply 即可。
- **仅修改 app.asar**：不触碰应用本体其他文件。备份保留在用户目录 `WorkBuddy/App_app.asar.bak.*`。
- **动态版包体大**：动画 WebP base64 使 dynamic/skin.css 约 9.4 MB，注入后 asar 增大属正常。
- **静态版轻量**：static/skin.css 仅约 0.27 MB，推荐性能敏感或企业批量分发场景。
- **个性化合规**：分发给第三方前，请替换示例背景资产为企业/个人自有或已授权素材，并确认不侵犯第三方权益。

## 相关

- 通用 asar 换肤方法：`workbuddy-asar-skin`
