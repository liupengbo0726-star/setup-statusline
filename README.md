# Setup StatusLine for Claude Code

一键配置 Claude Code 状态栏，实时显示：**模型 | 上下文使用率 | Git 分支 | 工作目录 | 输出样式**，带 ANSI 彩色标记。

```
deepseek-v4-pro[1m] | 12.5% | main | /home/project | default
```

> 每个字段有独立颜色：模型=青色粗体、上下文=绿/黄/红（按用量）、分支=紫色、目录=蓝色、样式=灰色

---

## 快速安装

### 方式一：npx 一键安装（推荐）

```bash
npx setup-claude-statusline
```

自动检测 Windows / macOS / Linux，完成配置后重启 Claude Code 即可。

### 方式二：手动安装（Skill）

```bash
# 1. 克隆到 Claude Code 的 skills 目录
git clone https://github.com/liupengbo/setup-statusline.git ~/.claude/skills/setup-statusline

# 2. 重启 Claude Code，然后运行：
/setup-statusline
```

### 方式三：手动安装（直接脚本）

**Windows (PowerShell):**

```powershell
# 下载脚本
Invoke-WebRequest -Uri "https://raw.githubusercontent.com/liupengbo/setup-statusline/main/scripts/statusline.ps1" -OutFile "$env:USERPROFILE\.claude\statusline.ps1"

# 添加到 settings.json
```

然后在 `~/.claude/settings.json` 中添加：

```json
"statusLine": {
  "type": "command",
  "command": "powershell -NoProfile -ExecutionPolicy Bypass -File \"C:\\Users\\<你的用户名>\\.claude\\statusline.ps1\""
}
```

**Linux / macOS:**

```bash
# 下载脚本
curl -o ~/.claude/statusline.sh https://raw.githubusercontent.com/liupengbo/setup-statusline/main/scripts/statusline.sh
chmod +x ~/.claude/statusline.sh
```

然后在 `~/.claude/settings.json` 中添加：

```json
"statusLine": {
  "type": "command",
  "command": "bash /home/<你的用户名>/.claude/statusline.sh"
}
```

---

## 显示内容说明

| 字段 | 数据来源 | 颜色 | 示例值 |
|---|---|---|---|
| 模型名 | stdin JSON (`model.display_name`) | 青色粗体 | `deepseek-v4-pro[1m]` |
| 上下文 % | stdin JSON（`total_input_tokens / context_window_size`） | 绿/黄/红 | `12.5%` |
| Git 分支 | `git branch --show-current` | 紫色 | `main` |
| 工作目录 | stdin JSON (`workspace.current_dir`) | 蓝色 | `D:\桌面` |
| 输出样式 | stdin JSON (`output_style.name`) | 灰色 | `default` |

### 上下文颜色规则

| 使用率 | 颜色 | 含义 |
|---|---|---|
| ≤ 30% | 绿色 | 充裕 |
| 30% – 70% | 黄色 | 注意 |
| > 70% | 红色 | 告警 |

---

## 依赖

| 平台 | 依赖 |
|---|---|
| Windows | PowerShell 5.1+, Git |
| Linux / macOS | bash, jq, git, bc |

如果缺少 `jq` 或 `bc`（仅 Linux/macOS 需要）：
```bash
# macOS
brew install jq

# Ubuntu/Debian
sudo apt install jq bc

# CentOS/RHEL
sudo yum install jq bc
```

---

## 工作原理

Claude Code 每隔约 300ms 执行你配置的 `statusLine.command`，并通过 **stdin** 传入当前会话的 JSON 元数据：

```json
{
  "model": {"display_name": "deepseek-v4-pro[1m]"},
  "workspace": {"current_dir": "/home/user/project"},
  "output_style": {"name": "default"},
  "context_window": {
    "total_input_tokens": 125000,
    "context_window_size": 1000000
  }
}
```

脚本解析 JSON → 计算百分比 → 获取 Git 分支 → 拼接带颜色的字符串 → 输出到 stdout，Claude Code 将其渲染到底部状态栏。

---

## 故障排查

| 问题 | 解决方案 |
|---|---|
| 状态栏不显示 | 完全退出并重启 Claude Code |
| 显示 "no-branch" | 当前目录不是 Git 仓库 |
| 显示 "no-git" | 未安装 Git |
| `jq: command not found` | 安装 jq（见上方依赖说明） |
| Windows 状态栏不渲染 | 已知问题，尝试用 Git Bash 替代 PowerShell |

---

## 文件结构

```
setup-statusline/
├── SKILL.md                  ← Skill 定义（Claude Code 读取）
├── README.md                 ← 本文件
├── scripts/
│   ├── statusline.ps1        ← Windows PowerShell 脚本
│   └── statusline.sh         ← Linux/macOS Bash 脚本
└── package.json              ← npx 入口
```

---

## License

MIT
