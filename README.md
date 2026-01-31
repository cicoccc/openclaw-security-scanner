# 🛡️ OpenClaw Security Scanner v2.0

<div align="center">

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Version](https://img.shields.io/badge/version-2.0-blue.svg)](https://github.com/cicoccc/openclaw-security-scanner/releases)

[English](#english) | [简体中文](#简体中文)

**OpenClaw/Claude Code Skill | 专业的安全配置扫描工具**

**Professional security scanner for OpenClaw/Clawdbot**

</div>

> **项目别名 | Also known as:**
> 本工具支持所有版本：Moltbot / Clawdbot / OpenClaw
>
> **使用方式 | Usage:**
> ✅ OpenClaw Skill | ✅ Claude Code Skill | ✅ 独立脚本 Standalone Scripts

---

## 简体中文

**OpenClaw 安全配置扫描 Skill** - 一键检查你的 OpenClaw 配置是否安全，防止配置不当导致被黑客监控。

可作为 **OpenClaw Skill** 或 **Claude Code Skill** 在对话中直接调用，也可作为独立脚本使用。

### 😱 为什么需要这个工具？

最近的安全报告显示，全球有近千台 OpenClaw 服务器因配置不当处于"裸奔"状态：

- ❌ Gateway 绑定到所有地址（外网可直接访问）
- ❌ 没有任何认证保护
- ❌ 敏感文件权限过松
- ❌ API Keys 明文暴露

**一个配置错误，可能导致：**
- 🔓 你的聊天记录被他人查看
- 🔑 API Keys 被盗用，产生巨额费用
- 💻 服务器被完全控制
- 📱 社交账号被接管

### ✨ 功能特性

- 🔍 **智能检测** - 覆盖 16 项常见安全风险
- 🎯 **风险评分** - 直观的 0-100 分评分系统
- 🔧 **一键修复** - 自动修复发现的安全问题
- 📄 **详细报告** - 生成可分享的 Markdown 格式报告
- 💬 **小白友好** - 用人话解释问题，不需要技术背景
- 🚀 **开箱即用** - 无需安装额外依赖

### 🚀 快速开始

#### 方式一：作为 OpenClaw Skill 使用（推荐）

**在 Claude Code 中使用：**

1. 克隆仓库到本地：
```bash
git clone https://github.com/cicoccc/openclaw-security-scanner.git ~/openclaw-security-scanner
```

2. 在 Claude Code 对话中直接调用：
```
请帮我运行 OpenClaw 安全扫描
```

Claude Code 会自动识别这个 Skill 并执行安全检查。

**在 OpenClaw 中使用：**

克隆后，OpenClaw 可以通过 Skill 系统自动发现和调用：
```bash
git clone https://github.com/cicoccc/openclaw-security-scanner.git ~/.openclaw/skills/security-scanner
```

然后在对话中说：
```
检查我的 OpenClaw 安全配置
```

#### 方式二：作为独立脚本使用

```bash
# 1. 克隆仓库
git clone https://github.com/cicoccc/openclaw-security-scanner.git
cd openclaw-security-scanner

# 2. 运行安全检查
./scripts/security_check.sh

# 3. 如果发现问题，运行自动修复
./scripts/security_fix.sh

# 4. 生成详细报告（可选）
./scripts/security_report.sh
```

### 📖 检查项目说明

#### 🔴 主机安全 (Host Compromise)
- Gateway 绑定配置
- 端口监听状态
- 认证配置
- Docker 隔离检查
- 版本检查

#### 🟡 自动化控制 (Agency Control)
- 工具权限审计
- Hooks 安全检查
- 浏览器控制审计
- 频道访问策略

#### 🔵 凭证保护 (Credential Leakage)
- **明文 API Keys 扫描**（最重要！）
- Credentials 目录权限
- 配置文件权限
- 会话历史文件权限
- 日志文件权限
- 插件白名单
- Tailscale 配置

### 📊 评分说明

- **90-100 分**: ✨ 优秀 - 配置非常安全
- **70-89 分**: 👍 良好 - 有小问题需要优化
- **50-69 分**: ⚠️ 需要改进 - 存在中等风险
- **0-49 分**: 🚨 危险 - 请立即修复！

### 💡 常见问题

**Q: 这个工具安全吗？会不会上传我的数据？**

A: 完全安全！所有检查都在本地进行，不会上传任何数据。代码开源，可以自行审查。

**Q: 检查脚本会修改我的配置吗？**

A: 不会。`security_check.sh` 只检查不修改。只有运行 `security_fix.sh` 并手动确认后才会修改配置。

**Q: 我已经用了官方的 `openclaw security audit`，还需要这个吗？**

A: 两个工具可以互补：
- 官方工具：专业、全面、技术性强
- 本工具：简单、直观、自动修复

**Q: 多久运行一次检查？**

A: 建议：
- 首次部署后立即检查
- 每次修改配置后检查
- 每周定期检查一次

### 🛠️ 手动修复指南

如果不想用自动修复，也可以手动操作：

#### 修复 Gateway 绑定
```bash
openclaw config set gateway.bind loopback
openclaw gateway restart
```

#### 启用认证
```bash
openclaw config set gateway.auth.mode token
openclaw config set gateway.auth.token "你的随机token"
openclaw gateway restart
```

#### 修复文件权限
```bash
chmod 700 ~/.openclaw/credentials
chmod 600 ~/.openclaw/openclaw.json
```

#### 设置插件白名单
```bash
openclaw config set plugins.allow '["feishu","imessage","memory-core"]'
openclaw gateway restart
```

### 🤝 贡献

欢迎提交 Issue 和 Pull Request！

如果你有好的想法或发现了 bug，请：
1. 提交 [Issue](https://github.com/cicoccc/openclaw-security-scanner/issues)
2. Fork 仓库并提交 PR
3. 在 [讨论区](https://github.com/cicoccc/openclaw-security-scanner/discussions) 分享经验

### 📞 获得帮助

- 📖 查看 [Wiki](https://github.com/cicoccc/openclaw-security-scanner/wiki)
- 💬 加入 [讨论](https://github.com/cicoccc/openclaw-security-scanner/discussions)
- 🐛 报告 [Bug](https://github.com/cicoccc/openclaw-security-scanner/issues)

### 🙏 致谢

基于专业安全指南：
- [Composio Security Guide](https://composio.dev/blog/secure-moltbot-clawdbot-setup-composio)
- [OpenClaw Official Security Documentation](https://docs.openclaw.ai/gateway/security)
- OpenClaw 项目和所有安全研究者的贡献

---

## English

**OpenClaw Security Scanner Skill** - One-click security scanner for your OpenClaw configuration to prevent unauthorized access and data leaks.

Can be used as an **OpenClaw Skill** or **Claude Code Skill** directly in conversations, or as standalone scripts.

Based on professional security guidelines including Composio Security Guide and OpenClaw official security documentation.

### 😱 Why You Need This

Recent security reports show **1,800+ exposed OpenClaw instances** due to misconfiguration:

- ❌ Gateway bound to `0.0.0.0` (publicly accessible)
- ❌ No authentication enabled
- ❌ Plaintext API keys in config files
- ❌ Loose file permissions leaking credentials

**One configuration error can lead to:**
- 🔓 Chat history exposed
- 🔑 API keys stolen → massive bills
- 💻 Complete server control
- 📱 Social accounts hijacked

### ✨ Features

#### 🎯 Three-Tier Risk Classification

Based on Composio's professional security framework:

- 🔴 **Host Compromise** - Gateway exposure, authentication, Docker isolation
- 🟡 **Agency Control** - Tool permissions, hooks, browser automation
- 🔵 **Credential Leakage** - API keys, file permissions, session data

#### 🔍 16 Comprehensive Checks

| Category | Checks | Critical Items |
|----------|--------|----------------|
| **Host Security** | 5 checks | Gateway bind, Port listening, Auth, Docker, Version |
| **Agency Control** | 4 checks | Tools permissions, Hooks, Browser, Channel policies |
| **Credential Protection** | 7 checks | **Plaintext keys**, File perms, Sessions, Logs, Plugins |

### 🚀 Quick Start

#### Method 1: Use as OpenClaw Skill (Recommended)

**In Claude Code:**

1. Clone the repository:
```bash
git clone https://github.com/cicoccc/openclaw-security-scanner.git ~/openclaw-security-scanner
```

2. In Claude Code conversation, simply ask:
```
Please run OpenClaw security scan
```

Claude Code will automatically recognize this Skill and execute the security check.

**In OpenClaw:**

Clone to OpenClaw skills directory:
```bash
git clone https://github.com/cicoccc/openclaw-security-scanner.git ~/.openclaw/skills/security-scanner
```

Then in conversation:
```
Check my OpenClaw security configuration
```

#### Method 2: Use as Standalone Scripts

```bash
# Clone repository
git clone https://github.com/cicoccc/openclaw-security-scanner.git
cd openclaw-security-scanner

# Run security scan
./scripts/security_check.sh

# Run auto-fix if issues found
./scripts/security_fix.sh

# Generate detailed report (optional)
./scripts/security_report.sh
```

### Example Output

```
🛡️  OpenClaw Security Scanner v2.0
Based on Professional Security Guidelines
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

📋 开始全面安全检查...

🔍 检查分类:
  🔴 主机安全 (Host Compromise)
  🟡 自动化控制 (Agency Control)
  🔵 凭证保护 (Credential Leakage)

━━━ 🔴 主机安全检查 ━━━

🔍 检查 Gateway 绑定配置... ✅ 安全
🔍 检查端口监听状态... ✅ 安全
🔍 检查认证配置... ✅ 安全
🔍 检查 Docker 隔离... ⚠️  直接运行在主机
🔍 检查 OpenClaw 版本... ✅ 最新版本: 2026.1.29

━━━ 🟡 自动化控制检查 ━━━

🔍 检查工具权限配置... ✅ 权限受限
🔍 检查 Hooks 配置... ✅ Hooks 未启用
🔍 检查浏览器控制... ⚠️  浏览器控制已启用
🔍 检查频道访问策略... ✅ 访问策略安全

━━━ 🔵 凭证保护检查 ━━━

🔍 扫描配置文件中的明文 API Keys... ❌ 发现 3 个可疑凭证
🔍 检查 Credentials 目录权限... ✅ 安全 (700)
🔍 检查配置文件权限... ✅ 安全 (600)
🔍 检查会话历史文件权限... ✅ 权限安全
🔍 检查日志文件权限... ✅ 目录权限安全
🔍 检查插件白名单... ✅ 已设置

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

📊 安全评分: 72/100

👍 良好 - 有小问题需要优化

📈 问题统计:
  🔴 严重风险: 1
  ⚠️  中等风险: 2
  ✅ 安全配置: 11

🎯 风险分类:
  🔴 主机安全风险: 0
  🟡 自动化控制风险: 1
  🔵 凭证泄露风险: 2
```

### 📖 Usage

#### 🔍 Security Scan

```bash
./scripts/security_check.sh
```

Returns exit codes:
- `0` - All clear
- `1` - Warnings found
- `2` - Critical issues found

#### 🔧 Auto-Fix

```bash
./scripts/security_fix.sh
```

Automatically fixes:
- Gateway binding
- Authentication setup
- File permissions
- Plugin whitelist
- Credentials protection

#### 📄 Generate Report

```bash
./scripts/security_report.sh
```

Creates detailed Markdown report with:
- Full configuration audit
- Fix recommendations
- Security best practices
- Compliance checklist

### 🔍 Security Checks

#### 🔴 Host Compromise (Critical)

| Check | Risk | Impact |
|-------|------|--------|
| Gateway bind = `all` | 🔴 Critical | Public internet access |
| Port listening `0.0.0.0` | 🔴 Critical | Anyone can connect |
| No authentication | 🔴 Critical | No access control |
| No Docker isolation | ⚠️  Warning | Limited containment |
| Old version (< v2026.1.29) | ⚠️  Warning | No mandatory password |

#### 🟡 Agency Control (Medium)

| Check | Risk | Impact |
|-------|------|--------|
| `tools.elevated = true` | ⚠️  Warning | Can execute dangerous commands |
| Hooks enabled | ⚠️  Warning | Arbitrary script execution |
| Browser control enabled | ⚠️  Warning | Can access sensitive sites |
| Open channel policies | ⚠️  Warning | Anyone can message bot |

#### 🔵 Credential Leakage (High)

| Check | Risk | Impact |
|-------|------|--------|
| **Plaintext API keys** | 🔴 Critical | **Keys stolen** → massive bills |
| Credentials dir perms | ⚠️  Warning | Other users can read |
| Config file perms | ⚠️  Warning | Sensitive data exposed |
| Session files perms | ⚠️  Warning | Chat history leaked |
| Log files perms | ⚠️  Warning | Debugging info exposed |
| No plugin whitelist | ⚠️  Warning | Malicious plugins can steal |

### 📊 Scoring System

| Score | Grade | Recommendation |
|-------|-------|----------------|
| 90-100 | ✨ Excellent | Keep it up! Regular checks recommended |
| 70-89 | 👍 Good | Minor issues, run auto-fix |
| 50-69 | ⚠️  Needs Improvement | Medium risks, fix soon |
| 0-49 | 🚨 Critical | **Fix immediately!** |

### 💡 Common Issues & Fixes

#### Issue 1: Plaintext API Keys Detected

**Risk:** 🔴 Critical - Keys can be stolen

**Fix:**
```bash
# Use environment variables instead
export OPENAI_API_KEY="sk-..."
export ANTHROPIC_API_KEY="sk-ant-..."

# Or use credentials manager
openclaw config set auth.profiles.openai.mode env
```

#### Issue 2: No Docker Isolation

**Risk:** ⚠️  Warning - Limited attack containment

**Fix:**
```bash
# Run in Docker with volume mount
docker run -v ~/.openclaw:/root/.openclaw openclaw/openclaw
```

#### Issue 3: Gateway Exposed

**Risk:** 🔴 Critical - Public internet access

**Fix:**
```bash
# Immediately fix binding
openclaw config set gateway.bind loopback
openclaw gateway restart

# Or run auto-fix
./scripts/security_fix.sh
```

### 🎓 Security Best Practices

#### ✅ Recommended Configuration

```yaml
gateway:
  bind: loopback          # ✅ Local only
  auth:
    mode: token           # ✅ Authentication required
  tailscale:
    mode: off             # ✅ Unless needed with ACLs

channels:
  *:
    dmPolicy: pairing     # ✅ Require pairing
    groupPolicy: allowlist # ✅ Whitelist groups

plugins:
  allow:                  # ✅ Explicit whitelist
    - feishu
    - imessage
    - memory-core

tools:
  elevated: false         # ✅ Restrict permissions
```

#### 🔒 File Permissions

```bash
chmod 700 ~/.openclaw/credentials
chmod 600 ~/.openclaw/openclaw.json
chmod 700 ~/.openclaw/logs
```

#### 🐳 Docker Deployment

```bash
# Recommended for production
docker run -d \
  --name openclaw \
  -v ~/.openclaw:/root/.openclaw:ro \
  --network none \
  openclaw/openclaw
```

### 🤝 Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md)

### 📄 License

MIT License - see [LICENSE](LICENSE)

### 🙏 Acknowledgments

- [OpenClaw Project](https://github.com/openclaw/openclaw)
- [Composio Security Guide](https://composio.dev/blog/secure-moltbot-clawdbot-setup-composio)
- OpenClaw Official Security Documentation
- Security researchers and community contributors

### 📞 Support

- 📖 [Documentation](https://github.com/cicoccc/openclaw-security-scanner/wiki)
- 💬 [Discussions](https://github.com/cicoccc/openclaw-security-scanner/discussions)
- 🐛 [Report Issues](https://github.com/cicoccc/openclaw-security-scanner/issues)

### 🔗 References

Professional security guidelines this tool is based on:

- [Composio: Secure OpenClaw Setup](https://composio.dev/blog/secure-moltbot-clawdbot-setup-composio)
- [OpenClaw Security Documentation](https://docs.openclaw.ai/gateway/security)
- [GitHub Security Advisory](https://github.com/openclaw/openclaw/security)
- [VentureBeat: OpenClaw Security Risks](https://venturebeat.com/security/openclaw-agentic-ai-security-risk-ciso-guide)
- [Cisco: Personal AI Agents Security](https://blogs.cisco.com/ai/personal-ai-agents-like-openclaw-are-a-security-nightmare)

---

## 🏷️ Keywords & Aliases

This tool supports all versions of the project:

- **Moltbot** (legacy name)
- **Clawdbot** (previous name)
- **OpenClaw** (current name)

Search tags: `moltbot security`, `clawdbot security`, `openclaw security`, `ai agent security`, `claude security scanner`, `agentic ai security`

---

**⚠️  Disclaimer**: This tool helps identify common security issues but doesn't guarantee complete security. Use alongside official tools and security best practices.

**🌟 If this tool helped you, please star the repo!**
