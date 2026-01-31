# 🛡️ OpenClaw 安全扫描器

[English](README.md) | 简体中文

一键检查你的 OpenClaw 配置是否安全，防止配置不当导致被黑客监控。

## 😱 为什么需要这个工具？

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

## ✨ 功能特性

- 🔍 **智能检测** - 覆盖 16 项常见安全风险
- 🎯 **风险评分** - 直观的 0-100 分评分系统
- 🔧 **一键修复** - 自动修复发现的安全问题
- 📄 **详细报告** - 生成可分享的 Markdown 格式报告
- 💬 **小白友好** - 用人话解释问题，不需要技术背景
- 🚀 **开箱即用** - 无需安装额外依赖

## 🚀 快速开始

### 下载和使用

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

## 📖 详细说明

### 🔍 安全检查

```bash
./scripts/security_check.sh
```

**示例输出：**

```
🛡️  OpenClaw Security Scanner
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

📋 开始安全检查...

🔍 检查 Gateway 绑定配置... ✅ 安全
🔍 检查端口监听状态... ✅ 安全
🔍 检查认证配置... ✅ 安全
🔍 检查 Credentials 目录权限... ⚠️  权限过松: 755
🔍 检查插件白名单... ⚠️  未设置

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

📊 安全评分: 85/100

👍 良好 - 有小问题需要优化
```

### 🔧 自动修复

发现问题后，可以一键修复：

```bash
./scripts/security_fix.sh
```

脚本会：
1. 自动备份当前配置
2. 修复所有检测到的问题
3. 重启 Gateway 应用更改
4. 给出修复报告

### 📄 生成报告

```bash
./scripts/security_report.sh
```

生成包含以下内容的 Markdown 报告：
- 完整的配置检查结果
- 详细的修复建议
- 安全最佳实践指南

## 🔍 检查项目说明

### 🔴 严重风险

| 检查项 | 危险配置 | 安全配置 |
|--------|---------|---------|
| Gateway 绑定 | `bind: all` | `bind: loopback` |
| 端口监听 | `0.0.0.0:18789` | `127.0.0.1:18789` |
| 认证模式 | `auth.mode: none` | `auth.mode: token` |

### ⚠️ 中等风险

- Credentials 目录权限应为 `700`
- 应设置插件白名单
- 配置文件权限应为 `600`
- 频道访问策略应使用 `pairing` 或 `allowlist`

## 📊 评分说明

- **90-100 分**: ✨ 优秀 - 配置非常安全
- **70-89 分**: 👍 良好 - 有小问题需要优化
- **50-69 分**: ⚠️ 需要改进 - 存在中等风险
- **0-49 分**: 🚨 危险 - 请立即修复！

## 💡 常见问题

**Q: 这个工具安全吗？会不会上传我的数据？**

A: 完全安全！所有检查都在本地进行，不会上传任何数据。代码开源，可以自行审查。

**Q: 检查脚本会修改我的配置吗？**

A: 不会。`security_check.sh` 只检查不修改。只有运行 `security_fix.sh` 并手动确认后才会修改配置。

**Q: 修复会不会影响我正在使用的功能？**

A: 不会。修复只是加强安全性，不会影响正常功能。而且修复前会自动备份配置。

**Q: 我已经用了官方的 `openclaw security audit`，还需要这个吗？**

A: 两个工具可以互补：
- 官方工具：专业、全面、技术性强
- 本工具：简单、直观、自动修复

**Q: 多久运行一次检查？**

A: 建议：
- 首次部署后立即检查
- 每次修改配置后检查
- 每周定期检查一次

## 🛠️ 手动修复指南

如果不想用自动修复，也可以手动操作：

### 修复 Gateway 绑定

```bash
openclaw config set gateway.bind loopback
openclaw gateway restart
```

### 启用认证

```bash
openclaw config set gateway.auth.mode token
openclaw config set gateway.auth.token "你的随机token"
openclaw gateway restart
```

### 修复文件权限

```bash
chmod 700 ~/.openclaw/credentials
chmod 600 ~/.openclaw/openclaw.json
```

### 设置插件白名单

```bash
openclaw config set plugins.allow '["feishu","imessage","memory-core"]'
openclaw gateway restart
```

## 🤝 贡献

欢迎提交 Issue 和 Pull Request！

如果你有好的想法或发现了 bug，请：
1. 提交 [Issue](https://github.com/cicoccc/openclaw-security-scanner/issues)
2. Fork 仓库并提交 PR
3. 在 [讨论区](https://github.com/cicoccc/openclaw-security-scanner/discussions) 分享经验

## 📞 获得帮助

- 📖 查看 [Wiki](https://github.com/cicoccc/openclaw-security-scanner/wiki)
- 💬 加入 [讨论](https://github.com/cicoccc/openclaw-security-scanner/discussions)
- 🐛 报告 [Bug](https://github.com/cicoccc/openclaw-security-scanner/issues)

## 📄 开源协议

MIT License - 详见 [LICENSE](LICENSE) 文件

## 🙏 致谢

感谢 OpenClaw 项目和所有安全研究者的贡献。

---

**🌟 如果觉得有用，请给个 Star！这会鼓励我持续更新。**
