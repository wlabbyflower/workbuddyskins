# workbuddyskins

一个用于收集和维护 **WorkBuddy 桌面端换肤 Skill** 的仓库。

当前提供 `pink-crystal-workbuddy-skin`：只需提供一张图片，即可为 WorkBuddy 应用完整的主题，并保留毛玻璃、透明侧栏、输入框、菜单、提示框和模型选择器等界面细节。Skill 会自动完成背景处理、`app.asar` 定点修改、原文件备份、完整性校验、macOS 签名、应用重启及回滚。

## 当前 Skill

### Pink Crystal WorkBuddy Skin

- Skill 版本：`4.0.0`
- 支持平台：macOS、Windows
- 支持静态图片背景和动态 WebP 背景
- 内置深空樱雾示例主题
- 支持使用自有图片快速生成个性化主题
- 修改前自动备份，支持一键回滚
- WorkBuddy 升级后可重新应用

完整使用规则和技术说明请阅读 [`pink-crystal-workbuddy-skin/SKILL.md`](./pink-crystal-workbuddy-skin/SKILL.md)。

## 安装

将 Skill 目录复制到 WorkBuddy 的 Skills 目录：

```bash
git clone git@github.com:wlabbyflower/workbuddyskins.git
mkdir -p "$HOME/.workbuddy/skills"
cp -R workbuddyskins/pink-crystal-workbuddy-skin "$HOME/.workbuddy/skills/"
```

也可以下载仓库中的 [`pink-crystal-workbuddy-skin.zip`](./pink-crystal-workbuddy-skin.zip)，解压后将目录放入：

```text
~/.workbuddy/skills/pink-crystal-workbuddy-skin
```

## 使用

安装后，可在 WorkBuddy 中向 Agent 提出类似需求：

```text
用这张图片替换我的 WorkBuddy 主题，保留现在全部毛玻璃和细节修复。
```

```text
把这张新图片应用成 WorkBuddy 背景，并完整重建、签名、重启和验证。
```

Agent 会依据 `SKILL.md` 检查运行环境，并执行对应平台的脚本。

直接在对话框里上传一张图片，然后输入：

```text
@skill:"WorkBuddy 换肤" 用这张图片替换我的 WorkBuddy 主题，保留现在全部毛玻璃和细节修复。
```

也可以输入更简短的版本：

```text
@skill:"WorkBuddy 换肤" 用这张图片给 WorkBuddy 换肤。
```

技能会自动执行：

1. 读取并处理图片。
2. 替换主题背景。
3. 保留输入框、侧栏、菜单和模型选择器等全部修复。
4. 备份并修改 `app.asar`。
5. 校验完整性、重新签名并彻底重启 WorkBuddy。
6. 返回备份路径和回滚方法。

<img width="3840" height="1982" alt="image" src="https://github.com/user-attachments/assets/ac8d3916-1e09-4ae8-a3ad-b14b1d778898" />


### macOS

使用一张图片生成并应用静态主题：

```bash
bash "$HOME/.workbuddy/skills/pink-crystal-workbuddy-skin/macos/scripts/apply_image.sh" \
  --image "/absolute/path/to/background.png"
```

应用内置动态主题：

```bash
bash "$HOME/.workbuddy/skills/pink-crystal-workbuddy-skin/macos/scripts/apply.sh" \
  --mode dynamic
```

回滚到修改前的版本：

```bash
bash "$HOME/.workbuddy/skills/pink-crystal-workbuddy-skin/macos/scripts/rollback.sh"
```

### Windows

```cmd
windows\scripts\apply.bat
windows\scripts\apply.bat static
windows\scripts\rollback.bat
```

如果 WorkBuddy 安装在自定义位置，请先设置 `WB_PATH`：

```cmd
set "WB_PATH=D:\your\path\WorkBuddy"
windows\scripts\apply.bat
```

## 使用要求

- 已安装 WorkBuddy 桌面客户端
- 已安装 Node.js
- macOS 默认安装位置为 `/Applications/WorkBuddy.app`
- Windows 需要对 WorkBuddy 安装目录具有写入权限
- 应用主题前建议先保存正在进行的工作，脚本会完全退出并重启 WorkBuddy
- 该主题按深色模式设计，请在 WorkBuddy 中使用深色 Color Theme

## 仓库结构

```text
workbuddyskins/
├── pink-crystal-workbuddy-skin/
│   ├── assets/       # 动态与静态主题资源
│   ├── docs/         # 设计规范
│   ├── macos/        # macOS 应用与回滚脚本
│   ├── tools/        # 背景处理、构建与 ASAR 修改工具
│   ├── windows/      # Windows 应用与回滚脚本
│   ├── DISCLAIMER.md
│   └── SKILL.md
└── pink-crystal-workbuddy-skin.zip
```

## 注意事项

本 Skill 通过修改 WorkBuddy 客户端的 `app.asar` 实现本地换肤。脚本会在修改前自动创建备份，但 WorkBuddy 更新或重装后主题可能失效，需要重新应用。

仓库中的背景仅用于演示。使用或分发自定义主题时，请确保你对所使用的图片、视频、品牌标识及其他素材拥有合法权利，并遵守 WorkBuddy 的相关使用条款。详细说明见 [`DISCLAIMER.md`](./pink-crystal-workbuddy-skin/DISCLAIMER.md)。

## 贡献

欢迎提交新的 WorkBuddy 皮肤、兼容性修复和使用文档。新增皮肤时，请提供独立的 Skill 目录、`SKILL.md`、安装与回滚脚本，以及必要的素材授权说明。
