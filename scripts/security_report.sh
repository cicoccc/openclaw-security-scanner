#!/bin/bash
# OpenClaw Security Report Generator
# 生成详细的安全报告（Markdown 格式）

set -euo pipefail

OUTPUT_FILE="openclaw_security_report_$(date +%Y%m%d_%H%M%S).md"

echo "🛡️  生成安全报告..."
echo ""

# 检查 openclaw 命令
if ! command -v openclaw &> /dev/null; then
    echo "❌ 错误: 未找到 openclaw 命令"
    exit 1
fi

CONFIG_DIR="$HOME/.openclaw"

# 开始生成报告
cat > "$OUTPUT_FILE" << 'REPORT_START'
# 🛡️ OpenClaw 安全检查报告

**生成时间:** $(date '+%Y-%m-%d %H:%M:%S')
**主机名:** $(hostname)
**OpenClaw 版本:** $(openclaw --version 2>/dev/null || echo "未知")

---

## 📊 检查摘要

REPORT_START

# 运行检查脚本并捕获输出
CHECK_SCRIPT="$(dirname "$0")/security_check.sh"
if [ -f "$CHECK_SCRIPT" ]; then
    bash "$CHECK_SCRIPT" > /tmp/security_check_output.txt 2>&1 || true
    CHECK_OUTPUT=$(cat /tmp/security_check_output.txt)

    # 提取分数
    SCORE=$(echo "$CHECK_OUTPUT" | grep -oE "安全评分: [0-9]+/100" | grep -oE "[0-9]+" | head -1 || echo "0")

    cat >> "$OUTPUT_FILE" << REPORT_SUMMARY
**安全评分:** $SCORE/100

$(echo "$CHECK_OUTPUT" | grep -A 10 "问题统计:")

REPORT_SUMMARY
fi

# 详细配置检查
cat >> "$OUTPUT_FILE" << 'REPORT_DETAILS'

---

## 🔍 详细配置检查

### Gateway 配置

REPORT_DETAILS

# Gateway 配置
GATEWAY_CONFIG=$(openclaw config get gateway 2>/dev/null || echo "{}")
cat >> "$OUTPUT_FILE" << GATEWAY_SECTION

\`\`\`json
$GATEWAY_CONFIG
\`\`\`

**检查项:**
- **bind:** $(openclaw config get gateway.bind 2>/dev/null || echo "未知")
  - ✅ 推荐值: \`loopback\`
  - 🔴 危险值: \`all\`

- **auth.mode:** $(openclaw config get gateway.auth.mode 2>/dev/null || echo "未知")
  - ✅ 推荐值: \`token\`
  - 🔴 危险值: \`none\`

- **port:** $(openclaw config get gateway.port 2>/dev/null || echo "18789")

GATEWAY_SECTION

# 端口监听状态
GATEWAY_PORT=$(openclaw config get gateway.port 2>/dev/null || echo "18789")
LISTEN_STATUS=$(netstat -an 2>/dev/null | grep ":$GATEWAY_PORT.*LISTEN" || lsof -i :$GATEWAY_PORT 2>/dev/null || echo "未监听")

cat >> "$OUTPUT_FILE" << PORT_SECTION

### 端口监听状态

\`\`\`
$LISTEN_STATUS
\`\`\`

PORT_SECTION

# 文件权限
cat >> "$OUTPUT_FILE" << 'PERMS_SECTION'

### 文件和目录权限

| 路径 | 权限 | 状态 |
|------|------|------|
PERMS_SECTION

# Credentials 目录
if [ -d "$CONFIG_DIR/credentials" ]; then
    CRED_PERMS=$(stat -f "%Lp" "$CONFIG_DIR/credentials" 2>/dev/null || stat -c "%a" "$CONFIG_DIR/credentials" 2>/dev/null)
    if [ "$CRED_PERMS" = "700" ]; then
        STATUS="✅ 安全"
    else
        STATUS="⚠️  过松"
    fi
    echo "| \`$CONFIG_DIR/credentials\` | $CRED_PERMS | $STATUS |" >> "$OUTPUT_FILE"
fi

# 配置文件
if [ -f "$CONFIG_DIR/openclaw.json" ]; then
    CONFIG_PERMS=$(stat -f "%Lp" "$CONFIG_DIR/openclaw.json" 2>/dev/null || stat -c "%a" "$CONFIG_DIR/openclaw.json" 2>/dev/null)
    if [ "$CONFIG_PERMS" = "600" ] || [ "$CONFIG_PERMS" = "400" ]; then
        STATUS="✅ 安全"
    else
        STATUS="⚠️  过松"
    fi
    echo "| \`$CONFIG_DIR/openclaw.json\` | $CONFIG_PERMS | $STATUS |" >> "$OUTPUT_FILE"
fi

# 插件配置
cat >> "$OUTPUT_FILE" << 'PLUGINS_SECTION'

### 插件配置

PLUGINS_SECTION

PLUGIN_ALLOW=$(openclaw config get plugins.allow 2>/dev/null || echo "未设置")
cat >> "$OUTPUT_FILE" << PLUGIN_CONTENT

**插件白名单:**
\`\`\`json
$PLUGIN_ALLOW
\`\`\`

**已加载的插件:**
\`\`\`
$(openclaw plugins list 2>/dev/null | grep "│ loaded" || echo "无")
\`\`\`

PLUGIN_CONTENT

# 频道配置
cat >> "$OUTPUT_FILE" << 'CHANNELS_SECTION'

### 频道访问策略

| 频道 | DM 策略 | 群组策略 | 状态 |
|------|---------|----------|------|
CHANNELS_SECTION

for channel in imessage feishu whatsapp telegram slack discord; do
    ENABLED=$(openclaw config get "channels.$channel.enabled" 2>/dev/null || echo "false")
    if [ "$ENABLED" = "true" ]; then
        DM_POLICY=$(openclaw config get "channels.$channel.dmPolicy" 2>/dev/null || echo "-")
        GROUP_POLICY=$(openclaw config get "channels.$channel.groupPolicy" 2>/dev/null || echo "-")

        if [ "$DM_POLICY" = "open" ] || [ "$GROUP_POLICY" = "open" ]; then
            STATUS="⚠️  开放"
        else
            STATUS="✅ 限制"
        fi

        echo "| $channel | $DM_POLICY | $GROUP_POLICY | $STATUS |" >> "$OUTPUT_FILE"
    fi
done

# 建议和修复步骤
cat >> "$OUTPUT_FILE" << 'RECOMMENDATIONS'

---

## 💡 修复建议

### 严重问题修复

如果发现严重风险，立即执行:

```bash
# 1. 运行自动修复脚本
./security_fix.sh

# 2. 手动修复（如果自动修复失败）
openclaw config set gateway.bind loopback
openclaw config set gateway.auth.mode token
openclaw gateway restart
```

### 权限修复

```bash
# 修复 credentials 目录权限
chmod 700 ~/.openclaw/credentials

# 修复配置文件权限
chmod 600 ~/.openclaw/openclaw.json
```

### 插件白名单设置

```bash
# 设置插件白名单（根据实际需要调整）
openclaw config set plugins.allow '["feishu","imessage","memory-core"]'
```

---

## 📚 安全最佳实践

### ✅ 推荐配置

1. **Gateway 绑定:**
   - ✅ \`bind: loopback\` - 仅本地访问
   - ❌ \`bind: all\` - 外网可访问（危险）

2. **认证:**
   - ✅ \`auth.mode: token\` - 需要认证
   - ❌ \`auth.mode: none\` - 无认证（危险）

3. **远程访问:**
   - 如需远程访问，使用 Tailscale 而不是公网暴露
   - 或使用 Cloudflare Tunnel

4. **频道策略:**
   - ✅ \`pairing\` - 需要配对
   - ✅ \`allowlist\` - 白名单模式
   - ⚠️  \`open\` - 完全开放

5. **文件权限:**
   - Credentials: \`700\`
   - 配置文件: \`600\`

### 🔒 定期检查

```bash
# 每周运行一次安全检查
./security_check.sh

# 运行官方审计工具
openclaw security audit --deep
```

---

## 📖 参考资料

- [OpenClaw 官方文档](https://docs.openclaw.ai/)
- [安全配置指南](https://docs.openclaw.ai/security)
- [常见安全问题](https://github.com/openclaw/openclaw/issues?q=label%3Asecurity)

---

**报告生成工具:** [openclaw-security-scanner](https://github.com/yourusername/openclaw-security-scanner)

RECOMMENDATIONS

echo "✅ 报告已生成: $OUTPUT_FILE"
echo ""
echo "可以:"
echo "  • 查看报告: cat $OUTPUT_FILE"
echo "  • 或在 Markdown 编辑器中打开"
echo ""
