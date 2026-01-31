# 🛡️ OpenClaw Security Scanner v2.0

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Version](https://img.shields.io/badge/version-2.0-blue.svg)](https://github.com/cicoccc/openclaw-security-scanner/releases)

**Professional security scanner for OpenClaw/Clawdbot** - Prevent configuration leaks and unauthorized access.

Based on professional security guidelines including Composio Security Guide and OpenClaw official security documentation.

## 😱 Why You Need This

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

## ✨ Features

### 🎯 Three-Tier Risk Classification

Based on Composio's professional security framework:

- 🔴 **Host Compromise** - Gateway exposure, authentication, Docker isolation
- 🟡 **Agency Control** - Tool permissions, hooks, browser automation
- 🔵 **Credential Leakage** - API keys, file permissions, session data

### 🔍 16 Comprehensive Checks

| Category | Checks | Critical Items |
|----------|--------|----------------|
| **Host Security** | 5 checks | Gateway bind, Port listening, Auth, Docker, Version |
| **Agency Control** | 4 checks | Tools permissions, Hooks, Browser, Channel policies |
| **Credential Protection** | 7 checks | **Plaintext keys**, File perms, Sessions, Logs, Plugins |

## 🚀 Quick Start

### Installation

```bash
# Clone repository
git clone https://github.com/cicoccc/openclaw-security-scanner.git
cd openclaw-security-scanner

# Run security scan
./scripts/security_check.sh
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

## 📖 Usage

### 🔍 Security Scan

```bash
./scripts/security_check.sh
```

Returns exit codes:
- `0` - All clear
- `1` - Warnings found
- `2` - Critical issues found

### 🔧 Auto-Fix

```bash
./scripts/security_fix.sh
```

Automatically fixes:
- Gateway binding
- Authentication setup
- File permissions
- Plugin whitelist
- Credentials protection

### 📄 Generate Report

```bash
./scripts/security_report.sh
```

Creates detailed Markdown report with:
- Full configuration audit
- Fix recommendations
- Security best practices
- Compliance checklist

## 🔍 Security Checks

### 🔴 Host Compromise (Critical)

| Check | Risk | Impact |
|-------|------|--------|
| Gateway bind = `all` | 🔴 Critical | Public internet access |
| Port listening `0.0.0.0` | 🔴 Critical | Anyone can connect |
| No authentication | 🔴 Critical | No access control |
| No Docker isolation | ⚠️  Warning | Limited containment |
| Old version (< v2026.1.29) | ⚠️  Warning | No mandatory password |

### 🟡 Agency Control (Medium)

| Check | Risk | Impact |
|-------|------|--------|
| `tools.elevated = true` | ⚠️  Warning | Can execute dangerous commands |
| Hooks enabled | ⚠️  Warning | Arbitrary script execution |
| Browser control enabled | ⚠️  Warning | Can access sensitive sites |
| Open channel policies | ⚠️  Warning | Anyone can message bot |

### 🔵 Credential Leakage (High)

| Check | Risk | Impact |
|-------|------|--------|
| **Plaintext API keys** | 🔴 Critical | **Keys stolen** → massive bills |
| Credentials dir perms | ⚠️  Warning | Other users can read |
| Config file perms | ⚠️  Warning | Sensitive data exposed |
| Session files perms | ⚠️  Warning | Chat history leaked |
| Log files perms | ⚠️  Warning | Debugging info exposed |
| No plugin whitelist | ⚠️  Warning | Malicious plugins can steal |

## 📊 Scoring System

| Score | Grade | Recommendation |
|-------|-------|----------------|
| 90-100 | ✨ Excellent | Keep it up! Regular checks recommended |
| 70-89 | 👍 Good | Minor issues, run auto-fix |
| 50-69 | ⚠️  Needs Improvement | Medium risks, fix soon |
| 0-49 | 🚨 Critical | **Fix immediately!** |

## 💡 Common Issues & Fixes

### Issue 1: Plaintext API Keys Detected

**Risk:** 🔴 Critical - Keys can be stolen

**Fix:**
```bash
# Use environment variables instead
export OPENAI_API_KEY="sk-..."
export ANTHROPIC_API_KEY="sk-ant-..."

# Or use credentials manager
openclaw config set auth.profiles.openai.mode env
```

### Issue 2: No Docker Isolation

**Risk:** ⚠️  Warning - Limited attack containment

**Fix:**
```bash
# Run in Docker with volume mount
docker run -v ~/.openclaw:/root/.openclaw openclaw/openclaw
```

### Issue 3: Gateway Exposed

**Risk:** 🔴 Critical - Public internet access

**Fix:**
```bash
# Immediately fix binding
openclaw config set gateway.bind loopback
openclaw gateway restart

# Or run auto-fix
./scripts/security_fix.sh
```

## 🎓 Security Best Practices

### ✅ Recommended Configuration

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

### 🔒 File Permissions

```bash
chmod 700 ~/.openclaw/credentials
chmod 600 ~/.openclaw/openclaw.json
chmod 700 ~/.openclaw/logs
```

### 🐳 Docker Deployment

```bash
# Recommended for production
docker run -d \
  --name openclaw \
  -v ~/.openclaw:/root/.openclaw:ro \
  --network none \
  openclaw/openclaw
```

## 🤝 Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md)

## 📄 License

MIT License - see [LICENSE](LICENSE)

## 🙏 Acknowledgments

- [OpenClaw Project](https://github.com/openclaw/openclaw)
- [Composio Security Guide](https://composio.dev/blog/secure-moltbot-clawdbot-setup-composio)
- OpenClaw Official Security Documentation
- Security researchers and community contributors

## 📞 Support

- 📖 [Documentation](https://github.com/cicoccc/openclaw-security-scanner/wiki)
- 💬 [Discussions](https://github.com/cicoccc/openclaw-security-scanner/discussions)
- 🐛 [Report Issues](https://github.com/cicoccc/openclaw-security-scanner/issues)

## 🔗 References

Professional security guidelines this tool is based on:

- [Composio: Secure OpenClaw Setup](https://composio.dev/blog/secure-moltbot-clawdbot-setup-composio)
- [OpenClaw Security Documentation](https://docs.openclaw.ai/gateway/security)
- [GitHub Security Advisory](https://github.com/openclaw/openclaw/security)
- [VentureBeat: OpenClaw Security Risks](https://venturebeat.com/security/openclaw-agentic-ai-security-risk-ciso-guide)
- [Cisco: Personal AI Agents Security](https://blogs.cisco.com/ai/personal-ai-agents-like-openclaw-are-a-security-nightmare)

---

**⚠️  Disclaimer**: This tool helps identify common security issues but doesn't guarantee complete security. Use alongside official tools and security best practices.

**🌟 If this tool helped you, please star the repo!**
