---
name: security-scanner
description: 一键检查 OpenClaw 安全配置，防止被黑客监控。基于 Composio 专业安全指南的 16 项全面检查。
homepage: https://github.com/cicoccc/openclaw-security-scanner
metadata: {"openclaw":{"emoji":"🛡️","requires":{"bins":["openclaw"]}}}
---

# 🛡️ OpenClaw Security Scanner

一键检查你的 OpenClaw 配置是否安全，防止配置不当导致的安全风险。

基于专业安全指南：Composio Security Guide、OpenClaw Official Docs。

## 快速检查

运行完整的安全扫描（16 项检查）：

```bash
{baseDir}/scripts/security_check.sh
```

**输出：**
- 安全评分（0-100）
- 三层风险分类（主机/自动化/凭证）
- 详细问题列表
- 修复建议

## 一键修复

自动修复发现的安全问题：

```bash
{baseDir}/scripts/security_fix.sh
```

**修复内容：**
- Gateway 绑定设置
- 启用 Token 认证
- 文件权限修复
- 插件白名单设置
- 自动备份配置

## 生成报告

生成详细的安全报告（Markdown 格式）：

```bash
{baseDir}/scripts/security_report.sh
```

## 检查项目

### 🔴 主机安全 (Host Compromise)
- Gateway 绑定配置（bind: all = 危险）
- 端口监听状态（0.0.0.0 = 暴露）
- 认证配置（auth.mode: none = 无保护）
- Docker 隔离检查（建议容器化）
- 版本检查（v2026.1.29+ 强制密码）

### 🟡 自动化控制 (Agency Control)
- 工具权限审计（tools.elevated）
- Hooks 安全检查
- 浏览器控制审计
- 频道访问策略（open = 任何人可消息）

### 🔵 凭证保护 (Credential Leakage)
- 明文 API Keys 扫描（最重要！）
- Credentials 目录权限
- 配置文件权限
- 会话历史文件权限
- 日志文件权限
- 插件白名单
- Tailscale 配置

## 评分说明

- **90-100**: ✨ 优秀 - 配置非常安全
- **70-89**: 👍 良好 - 有小问题需要优化
- **50-69**: ⚠️ 需要改进 - 存在中等风险
- **0-49**: 🚨 危险 - 立即修复！

## 使用场景

- 首次部署后验证配置
- 定期安全检查（建议每周）
- 看到安全警告后快速自查
- 生成合规报告
- 防止类似 1800+ 实例暴露的灾难

## 输出示例

```
🛡️  OpenClaw Security Scanner v2.0
Based on Professional Security Guidelines
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

🔍 检查分类:
  🔴 主机安全 (Host Compromise)
  🟡 自动化控制 (Agency Control)
  🔵 凭证保护 (Credential Leakage)

━━━ 🔴 主机安全检查 ━━━
✅ Gateway 绑定配置... 安全
✅ 端口监听状态... 安全
⚠️  Docker 隔离... 直接运行在主机

━━━ 🔵 凭证保护检查 ━━━
❌ 明文 API Keys... 发现 3 个可疑凭证

📊 安全评分: 72/100
👍 良好 - 有小问题需要优化

🎯 风险分类:
  🔴 主机安全风险: 0
  🟡 自动化控制风险: 1
  🔵 凭证泄露风险: 2
```

## 注意事项

- 自动修复会修改配置文件（会先备份）
- 建议先运行检查，确认后再修复
- 与官方 `openclaw security audit --deep` 配合使用最佳
- 定期检查可防患于未然

## 参考资源

- [Composio 安全指南](https://composio.dev/blog/secure-moltbot-clawdbot-setup-composio)
- [OpenClaw 官方安全文档](https://docs.openclaw.ai/gateway/security)
- [VentureBeat 安全分析](https://venturebeat.com/security/openclaw-agentic-ai-security-risk-ciso-guide)
