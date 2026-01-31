#!/bin/bash
# OpenClaw Security Scanner v2.0
# 基于专业安全指南的全面安全检查
# 参考: Composio Security Guide, OpenClaw Official Docs

set -euo pipefail

# 颜色定义
RED='\033[0;31m'
YELLOW='\033[1;33m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
NC='\033[0m'
BOLD='\033[1m'

# 分数和统计
SCORE=100
CRITICAL_ISSUES=0
WARNINGS=0
GOOD_PRACTICES=0

# 三大核心风险分类
HOST_RISK=0
AGENCY_RISK=0
CREDENTIAL_RISK=0

# 问题列表
declare -a CRITICAL_LIST
declare -a WARNING_LIST
declare -a GOOD_LIST
declare -a HOST_ISSUES
declare -a AGENCY_ISSUES
declare -a CREDENTIAL_ISSUES

echo ""
echo -e "${BOLD}🛡️  OpenClaw Security Scanner v2.0${NC}"
echo -e "${BLUE}Based on Professional Security Guidelines${NC}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# 检查命令
if ! command -v openclaw &> /dev/null; then
    echo -e "${RED}❌ 错误: 未找到 openclaw 命令${NC}"
    exit 1
fi

CONFIG_DIR="$HOME/.openclaw"
if [ ! -d "$CONFIG_DIR" ]; then
    echo -e "${RED}❌ 错误: 未找到 OpenClaw 配置目录${NC}"
    exit 1
fi

CONFIG_FILE="$CONFIG_DIR/openclaw.json"

echo -e "${BLUE}📋 开始全面安全检查...${NC}"
echo ""
echo -e "${MAGENTA}🔍 检查分类:${NC}"
echo -e "  ${RED}🔴 主机安全 (Host Compromise)${NC}"
echo -e "  ${YELLOW}🟡 自动化控制 (Agency Control)${NC}"
echo -e "  ${BLUE}🔵 凭证保护 (Credential Leakage)${NC}"
echo ""

# ============================================
# 第一部分：主机安全 (Host Compromise)
# ============================================
echo -e "${RED}${BOLD}━━━ 🔴 主机安全检查 ━━━${NC}"
echo ""

# 检查 1: Gateway 绑定
echo -n "🔍 检查 Gateway 绑定配置... "
GATEWAY_BIND=$(openclaw config get gateway.bind 2>/dev/null || echo "unknown")

if [ "$GATEWAY_BIND" = "all" ]; then
    echo -e "${RED}❌ 严重风险${NC}"
    CRITICAL_ISSUES=$((CRITICAL_ISSUES + 1))
    HOST_RISK=$((HOST_RISK + 1))
    CRITICAL_LIST+=("[HOST] Gateway 绑定到所有地址 (bind: all) - 外网可直接访问！")
    HOST_ISSUES+=("Gateway 暴露到公网 (bind: all)")
    SCORE=$((SCORE - 30))
elif [ "$GATEWAY_BIND" = "loopback" ]; then
    echo -e "${GREEN}✅ 安全${NC}"
    GOOD_PRACTICES=$((GOOD_PRACTICES + 1))
    GOOD_LIST+=("Gateway 正确绑定到 loopback")
else
    echo -e "${YELLOW}⚠️  未知: $GATEWAY_BIND${NC}"
    WARNINGS=$((WARNINGS + 1))
    WARNING_LIST+=("[HOST] Gateway 绑定配置未知")
    SCORE=$((SCORE - 10))
fi

# 检查 2: 端口监听状态
echo -n "🔍 检查端口监听状态... "
GATEWAY_PORT=$(openclaw config get gateway.port 2>/dev/null || echo "18789")

if netstat -an 2>/dev/null | grep -q "0.0.0.0[.:]$GATEWAY_PORT.*LISTEN" || \
   lsof -i :$GATEWAY_PORT 2>/dev/null | grep -q "0.0.0.0:$GATEWAY_PORT"; then
    echo -e "${RED}❌ 严重风险${NC}"
    CRITICAL_ISSUES=$((CRITICAL_ISSUES + 1))
    HOST_RISK=$((HOST_RISK + 1))
    CRITICAL_LIST+=("[HOST] 端口监听 0.0.0.0 - 外网可访问！")
    HOST_ISSUES+=("端口监听所有接口 (0.0.0.0:$GATEWAY_PORT)")
    SCORE=$((SCORE - 30))
elif netstat -an 2>/dev/null | grep -q "127.0.0.1[.:]$GATEWAY_PORT.*LISTEN" || \
     lsof -i :$GATEWAY_PORT 2>/dev/null | grep -q "127.0.0.1:$GATEWAY_PORT"; then
    echo -e "${GREEN}✅ 安全${NC}"
    GOOD_PRACTICES=$((GOOD_PRACTICES + 1))
    GOOD_LIST+=("端口仅监听本地 (127.0.0.1)")
else
    echo -e "${BLUE}ℹ️  未运行${NC}"
fi

# 检查 3: 认证配置
echo -n "🔍 检查认证配置... "
AUTH_MODE=$(openclaw config get gateway.auth.mode 2>/dev/null || echo "unknown")

if [ "$AUTH_MODE" = "none" ] || [ "$AUTH_MODE" = "null" ]; then
    echo -e "${RED}❌ 严重风险${NC}"
    CRITICAL_ISSUES=$((CRITICAL_ISSUES + 1))
    HOST_RISK=$((HOST_RISK + 1))
    CRITICAL_LIST+=("[HOST] 未启用认证 - 任何人可访问！")
    HOST_ISSUES+=("无认证保护 (auth.mode: none)")
    SCORE=$((SCORE - 25))
elif [ "$AUTH_MODE" = "token" ]; then
    echo -e "${GREEN}✅ 安全${NC}"
    GOOD_PRACTICES=$((GOOD_PRACTICES + 1))
    GOOD_LIST+=("已启用 Token 认证")
else
    echo -e "${YELLOW}⚠️  未知: $AUTH_MODE${NC}"
    WARNINGS=$((WARNINGS + 1))
    WARNING_LIST+=("[HOST] 认证模式未知")
    SCORE=$((SCORE - 10))
fi

# 检查 4: Docker 隔离
echo -n "🔍 检查 Docker 隔离... "
if [ -f "/.dockerenv" ] || grep -q docker /proc/1/cgroup 2>/dev/null; then
    echo -e "${GREEN}✅ 在 Docker 中运行${NC}"
    GOOD_PRACTICES=$((GOOD_PRACTICES + 1))
    GOOD_LIST+=("运行在 Docker 容器中（隔离保护）")
else
    echo -e "${YELLOW}⚠️  直接运行在主机${NC}"
    WARNINGS=$((WARNINGS + 1))
    HOST_RISK=$((HOST_RISK + 1))
    WARNING_LIST+=("[HOST] 未使用 Docker 隔离 - 建议容器化运行")
    HOST_ISSUES+=("未使用 Docker 隔离")
    SCORE=$((SCORE - 15))
fi

# 检查 5: 版本检查（v2026.1.29+ 强制密码）
echo -n "🔍 检查 OpenClaw 版本... "
OPENCLAW_VERSION=$(openclaw --version 2>/dev/null || echo "unknown")
VERSION_DATE=$(echo "$OPENCLAW_VERSION" | grep -oE "[0-9]{4}\.[0-9]+\.[0-9]+" || echo "0")

if [[ "$VERSION_DATE" < "2026.1.29" ]] && [ "$VERSION_DATE" != "0" ]; then
    echo -e "${YELLOW}⚠️  旧版本: $OPENCLAW_VERSION${NC}"
    WARNINGS=$((WARNINGS + 1))
    WARNING_LIST+=("[HOST] 版本低于 v2026.1.29 - 建议升级到强制密码版本")
    SCORE=$((SCORE - 10))
elif [ "$VERSION_DATE" != "0" ]; then
    echo -e "${GREEN}✅ 最新版本: $OPENCLAW_VERSION${NC}"
    GOOD_LIST+=("使用安全版本 (>= v2026.1.29)")
else
    echo -e "${BLUE}ℹ️  无法检测版本${NC}"
fi

echo ""

# ============================================
# 第二部分：自动化控制 (Agency Control)
# ============================================
echo -e "${YELLOW}${BOLD}━━━ 🟡 自动化控制检查 ━━━${NC}"
echo ""

# 检查 6: 工具权限 (tools.elevated)
echo -n "🔍 检查工具权限配置... "
TOOLS_ELEVATED=$(openclaw config get tools.elevated 2>/dev/null || echo "unknown")

if [ "$TOOLS_ELEVATED" = "true" ]; then
    echo -e "${YELLOW}⚠️  已启用提升权限${NC}"
    WARNINGS=$((WARNINGS + 1))
    AGENCY_RISK=$((AGENCY_RISK + 1))
    WARNING_LIST+=("[AGENCY] 工具提升权限已启用 - 可能执行危险操作")
    AGENCY_ISSUES+=("工具提升权限已启用 (tools.elevated: true)")
    SCORE=$((SCORE - 10))
elif [ "$TOOLS_ELEVATED" = "false" ]; then
    echo -e "${GREEN}✅ 权限受限${NC}"
    GOOD_LIST+=("工具权限受限")
else
    echo -e "${BLUE}ℹ️  未配置${NC}"
fi

# 检查 7: Hooks 配置
echo -n "🔍 检查 Hooks 配置... "
HOOKS_ENABLED=$(openclaw config get hooks 2>/dev/null | grep -q "enabled.*true" && echo "true" || echo "false")

if [ "$HOOKS_ENABLED" = "true" ]; then
    echo -e "${YELLOW}⚠️  Hooks 已启用${NC}"
    WARNINGS=$((WARNINGS + 1))
    AGENCY_RISK=$((AGENCY_RISK + 1))
    WARNING_LIST+=("[AGENCY] Hooks 已启用 - 请确保 hook 脚本安全")
    AGENCY_ISSUES+=("Hooks 已启用")
    SCORE=$((SCORE - 5))
else
    echo -e "${GREEN}✅ Hooks 未启用${NC}"
    GOOD_LIST+=("Hooks 禁用（减少自动化风险）")
fi

# 检查 8: Browser Control
echo -n "🔍 检查浏览器控制... "
BROWSER_ENABLED=$(ls -d "$CONFIG_DIR/browser" 2>/dev/null && echo "true" || echo "false")

if [ "$BROWSER_ENABLED" = "true" ]; then
    echo -e "${YELLOW}⚠️  浏览器控制已启用${NC}"
    WARNINGS=$((WARNINGS + 1))
    AGENCY_RISK=$((AGENCY_RISK + 1))
    WARNING_LIST+=("[AGENCY] 浏览器控制已启用 - 可能访问敏感网站")
    AGENCY_ISSUES+=("浏览器控制已启用")
    SCORE=$((SCORE - 5))
else
    echo -e "${GREEN}✅ 浏览器控制未启用${NC}"
    GOOD_LIST+=("浏览器控制禁用")
fi

# 检查 9: 频道访问策略
echo -n "🔍 检查频道访问策略... "
OPEN_CHANNELS=0
for channel in imessage feishu whatsapp telegram slack discord; do
    DM_POLICY=$(openclaw config get "channels.$channel.dmPolicy" 2>/dev/null || echo "")
    GROUP_POLICY=$(openclaw config get "channels.$channel.groupPolicy" 2>/dev/null || echo "")

    if [ "$DM_POLICY" = "open" ] || [ "$GROUP_POLICY" = "open" ]; then
        OPEN_CHANNELS=$((OPEN_CHANNELS + 1))
    fi
done

if [ $OPEN_CHANNELS -gt 0 ]; then
    echo -e "${YELLOW}⚠️  发现 $OPEN_CHANNELS 个开放频道${NC}"
    WARNINGS=$((WARNINGS + 1))
    AGENCY_RISK=$((AGENCY_RISK + 1))
    WARNING_LIST+=("[AGENCY] $OPEN_CHANNELS 个频道使用 open 策略 - 任何人可发消息")
    AGENCY_ISSUES+=("$OPEN_CHANNELS 个频道策略过于开放")
    SCORE=$((SCORE - 5))
else
    echo -e "${GREEN}✅ 访问策略安全${NC}"
    GOOD_LIST+=("所有频道使用限制性策略")
fi

echo ""

# ============================================
# 第三部分：凭证保护 (Credential Leakage)
# ============================================
echo -e "${BLUE}${BOLD}━━━ 🔵 凭证保护检查 ━━━${NC}"
echo ""

# 检查 10: 明文 API Keys 扫描
echo -n "🔍 扫描配置文件中的明文 API Keys... "
if [ -f "$CONFIG_FILE" ]; then
    # 查找常见的 API key 模式
    API_KEY_COUNT=$(grep -iE "(apiKey|api_key|apikey|token|secret|password|sk-|AIza)" "$CONFIG_FILE" 2>/dev/null | grep -v "mode.*token" | wc -l | tr -d ' ')

    if [ "$API_KEY_COUNT" -gt 0 ]; then
        echo -e "${RED}❌ 发现 $API_KEY_COUNT 个可疑凭证${NC}"
        CRITICAL_ISSUES=$((CRITICAL_ISSUES + 1))
        CREDENTIAL_RISK=$((CREDENTIAL_RISK + 1))
        CRITICAL_LIST+=("[CREDENTIAL] 配置文件中发现 $API_KEY_COUNT 个明文 API Keys/Secrets")
        CREDENTIAL_ISSUES+=("配置文件含明文凭证 ($API_KEY_COUNT 个)")
        SCORE=$((SCORE - 20))
    else
        echo -e "${GREEN}✅ 未发现明显明文 keys${NC}"
        GOOD_LIST+=("配置文件未发现明显明文凭证")
    fi
else
    echo -e "${BLUE}ℹ️  配置文件不存在${NC}"
fi

# 检查 11: Credentials 目录权限
echo -n "🔍 检查 Credentials 目录权限... "
CRED_DIR="$CONFIG_DIR/credentials"
if [ -d "$CRED_DIR" ]; then
    PERMS=$(stat -f "%Lp" "$CRED_DIR" 2>/dev/null || stat -c "%a" "$CRED_DIR" 2>/dev/null)
    if [ "$PERMS" = "700" ]; then
        echo -e "${GREEN}✅ 安全 (700)${NC}"
        GOOD_PRACTICES=$((GOOD_PRACTICES + 1))
        GOOD_LIST+=("Credentials 目录权限正确")
    else
        echo -e "${YELLOW}⚠️  权限过松: $PERMS${NC}"
        WARNINGS=$((WARNINGS + 1))
        CREDENTIAL_RISK=$((CREDENTIAL_RISK + 1))
        WARNING_LIST+=("[CREDENTIAL] Credentials 目录权限为 $PERMS，应为 700")
        CREDENTIAL_ISSUES+=("目录权限过松 ($PERMS)")
        SCORE=$((SCORE - 10))
    fi
else
    echo -e "${BLUE}ℹ️  目录不存在${NC}"
fi

# 检查 12: 配置文件权限
echo -n "🔍 检查配置文件权限... "
if [ -f "$CONFIG_FILE" ]; then
    CONFIG_PERMS=$(stat -f "%Lp" "$CONFIG_FILE" 2>/dev/null || stat -c "%a" "$CONFIG_FILE" 2>/dev/null)
    if [ "$CONFIG_PERMS" = "600" ] || [ "$CONFIG_PERMS" = "400" ]; then
        echo -e "${GREEN}✅ 安全 ($CONFIG_PERMS)${NC}"
        GOOD_PRACTICES=$((GOOD_PRACTICES + 1))
        GOOD_LIST+=("配置文件权限正确")
    else
        echo -e "${YELLOW}⚠️  权限过松: $CONFIG_PERMS${NC}"
        WARNINGS=$((WARNINGS + 1))
        CREDENTIAL_RISK=$((CREDENTIAL_RISK + 1))
        WARNING_LIST+=("[CREDENTIAL] 配置文件权限为 $CONFIG_PERMS，建议 600")
        CREDENTIAL_ISSUES+=("配置文件权限过松 ($CONFIG_PERMS)")
        SCORE=$((SCORE - 5))
    fi
fi

# 检查 13: 会话历史权限
echo -n "🔍 检查会话历史文件权限... "
SESSION_DIR="$CONFIG_DIR/agents/*/sessions"
SESSION_FILES=$(find $CONFIG_DIR/agents -name "sessions.json" 2>/dev/null || true)

if [ -n "$SESSION_FILES" ]; then
    BAD_PERMS=0
    while IFS= read -r file; do
        FILE_PERMS=$(stat -f "%Lp" "$file" 2>/dev/null || stat -c "%a" "$file" 2>/dev/null)
        if [ "$FILE_PERMS" != "600" ] && [ "$FILE_PERMS" != "400" ]; then
            BAD_PERMS=$((BAD_PERMS + 1))
        fi
    done <<< "$SESSION_FILES"

    if [ $BAD_PERMS -gt 0 ]; then
        echo -e "${YELLOW}⚠️  发现 $BAD_PERMS 个权限过松的文件${NC}"
        WARNINGS=$((WARNINGS + 1))
        CREDENTIAL_RISK=$((CREDENTIAL_RISK + 1))
        WARNING_LIST+=("[CREDENTIAL] $BAD_PERMS 个会话文件权限过松 - 可能泄露对话历史")
        CREDENTIAL_ISSUES+=("$BAD_PERMS 个会话文件权限不安全")
        SCORE=$((SCORE - 8))
    else
        echo -e "${GREEN}✅ 权限安全${NC}"
        GOOD_LIST+=("会话文件权限正确")
    fi
else
    echo -e "${BLUE}ℹ️  未找到会话文件${NC}"
fi

# 检查 14: 日志文件权限
echo -n "🔍 检查日志文件权限... "
LOG_DIR="$CONFIG_DIR/logs"
if [ -d "$LOG_DIR" ]; then
    LOG_DIR_PERMS=$(stat -f "%Lp" "$LOG_DIR" 2>/dev/null || stat -c "%a" "$LOG_DIR" 2>/dev/null)
    if [ "$LOG_DIR_PERMS" != "700" ]; then
        echo -e "${YELLOW}⚠️  目录权限: $LOG_DIR_PERMS${NC}"
        WARNINGS=$((WARNINGS + 1))
        CREDENTIAL_RISK=$((CREDENTIAL_RISK + 1))
        WARNING_LIST+=("[CREDENTIAL] 日志目录权限为 $LOG_DIR_PERMS - 可能泄露敏感信息")
        CREDENTIAL_ISSUES+=("日志目录权限过松")
        SCORE=$((SCORE - 5))
    else
        echo -e "${GREEN}✅ 目录权限安全${NC}"
        GOOD_LIST+=("日志目录权限正确")
    fi
else
    echo -e "${BLUE}ℹ️  日志目录不存在${NC}"
fi

# 检查 15: 插件白名单
echo -n "🔍 检查插件白名单... "
PLUGIN_ALLOW=$(openclaw config get plugins.allow 2>/dev/null || echo "null")

if [ "$PLUGIN_ALLOW" = "null" ] || [ -z "$PLUGIN_ALLOW" ]; then
    echo -e "${YELLOW}⚠️  未设置${NC}"
    WARNINGS=$((WARNINGS + 1))
    CREDENTIAL_RISK=$((CREDENTIAL_RISK + 1))
    WARNING_LIST+=("[CREDENTIAL] 未设置插件白名单 - 恶意插件可能窃取凭证")
    CREDENTIAL_ISSUES+=("无插件白名单保护")
    SCORE=$((SCORE - 10))
else
    echo -e "${GREEN}✅ 已设置${NC}"
    GOOD_PRACTICES=$((GOOD_PRACTICES + 1))
    GOOD_LIST+=("插件白名单已设置")
fi

# 检查 16: Tailscale 配置
echo -n "🔍 检查 Tailscale 配置... "
TAILSCALE_MODE=$(openclaw config get gateway.tailscale.mode 2>/dev/null || echo "off")

if [ "$TAILSCALE_MODE" != "off" ]; then
    echo -e "${YELLOW}⚠️  已启用${NC}"
    WARNINGS=$((WARNINGS + 1))
    WARNING_LIST+=("[HOST] Tailscale 已启用 - 请确保 ACL 配置正确")
    SCORE=$((SCORE - 5))
else
    echo -e "${GREEN}✅ 未启用${NC}"
    GOOD_LIST+=("Tailscale 未启用")
fi

echo ""

# ============================================
# 输出结果
# ============================================
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo -e "${BOLD}📊 安全评分: $SCORE/100${NC}"
echo ""

# 评分等级
if [ $SCORE -ge 90 ]; then
    echo -e "${GREEN}${BOLD}✨ 优秀 - 配置非常安全！${NC}"
    RATING="EXCELLENT"
elif [ $SCORE -ge 70 ]; then
    echo -e "${BLUE}${BOLD}👍 良好 - 有小问题需要优化${NC}"
    RATING="GOOD"
elif [ $SCORE -ge 50 ]; then
    echo -e "${YELLOW}${BOLD}⚠️  需要改进 - 存在中等风险${NC}"
    RATING="NEEDS_IMPROVEMENT"
else
    echo -e "${RED}${BOLD}🚨 危险 - 请立即修复！${NC}"
    RATING="CRITICAL"
fi

echo ""
echo -e "${BOLD}📈 问题统计:${NC}"
echo -e "  ${RED}🔴 严重风险: $CRITICAL_ISSUES${NC}"
echo -e "  ${YELLOW}⚠️  中等风险: $WARNINGS${NC}"
echo -e "  ${GREEN}✅ 安全配置: $GOOD_PRACTICES${NC}"
echo ""

# 风险分类统计
echo -e "${BOLD}🎯 风险分类:${NC}"
echo -e "  ${RED}🔴 主机安全风险: $HOST_RISK${NC}"
echo -e "  ${YELLOW}🟡 自动化控制风险: $AGENCY_RISK${NC}"
echo -e "  ${BLUE}🔵 凭证泄露风险: $CREDENTIAL_RISK${NC}"
echo ""

# 显示严重问题
if [ $CRITICAL_ISSUES -gt 0 ]; then
    echo -e "${RED}${BOLD}🔴 严重风险详情:${NC}"
    for issue in "${CRITICAL_LIST[@]}"; do
        echo -e "  ${RED}• $issue${NC}"
    done
    echo ""
fi

# 显示警告
if [ $WARNINGS -gt 0 ]; then
    echo -e "${YELLOW}${BOLD}⚠️  中等风险详情:${NC}"
    for warning in "${WARNING_LIST[@]}"; do
        echo -e "  ${YELLOW}• $warning${NC}"
    done
    echo ""
fi

# 显示良好配置（仅在评分 >= 80 时显示）
if [ $SCORE -ge 80 ] && [ $GOOD_PRACTICES -gt 0 ]; then
    echo -e "${GREEN}${BOLD}✅ 安全配置详情:${NC}"
    for good in "${GOOD_LIST[@]}"; do
        echo -e "  ${GREEN}• $good${NC}"
    done
    echo ""
fi

# 核心风险详情
if [ $HOST_RISK -gt 0 ]; then
    echo -e "${RED}${BOLD}🔴 主机安全问题:${NC}"
    for issue in "${HOST_ISSUES[@]}"; do
        echo -e "  ${RED}• $issue${NC}"
    done
    echo ""
fi

if [ $AGENCY_RISK -gt 0 ]; then
    echo -e "${YELLOW}${BOLD}🟡 自动化控制问题:${NC}"
    for issue in "${AGENCY_ISSUES[@]}"; do
        echo -e "  ${YELLOW}• $issue${NC}"
    done
    echo ""
fi

if [ $CREDENTIAL_RISK -gt 0 ]; then
    echo -e "${BLUE}${BOLD}🔵 凭证保护问题:${NC}"
    for issue in "${CREDENTIAL_ISSUES[@]}"; do
        echo -e "  ${BLUE}• $issue${NC}"
    done
    echo ""
fi

# 修复建议
if [ $CRITICAL_ISSUES -gt 0 ] || [ $WARNINGS -gt 0 ]; then
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
    echo -e "${BOLD}💡 修复建议:${NC}"
    echo ""

    if [ $CRITICAL_ISSUES -gt 0 ]; then
        echo -e "${RED}${BOLD}立即执行:${NC}"
        echo "  1. 运行自动修复: $(dirname "$0")/security_fix.sh"

        if [ $HOST_RISK -gt 0 ]; then
            echo "  2. 主机安全:"
            echo "     - 确保 gateway.bind = loopback"
            echo "     - 启用认证 (auth.mode = token)"
            echo "     - 考虑使用 Docker 隔离"
        fi

        if [ $CREDENTIAL_RISK -gt 0 ]; then
            echo "  3. 凭证保护:"
            echo "     - 清理配置文件中的明文 keys"
            echo "     - 使用环境变量或凭证管理器"
            echo "     - 修复文件权限"
        fi
        echo ""
    fi

    if [ $WARNINGS -gt 0 ]; then
        echo -e "${YELLOW}${BOLD}建议优化:${NC}"
        echo "  • 运行官方审计: openclaw security audit --deep"
        echo "  • 生成详细报告: $(dirname "$0")/security_report.sh"
        echo "  • 定期检查（每周一次）"
        echo ""
    fi

    echo -e "${BLUE}${BOLD}参考资源:${NC}"
    echo "  • OpenClaw 官方安全文档: https://docs.openclaw.ai/gateway/security"
    echo "  • Composio 安全指南: https://composio.dev/blog/secure-moltbot-clawdbot-setup-composio"
    echo "  • GitHub 安全报告: https://github.com/openclaw/openclaw/security"
    echo ""
fi

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo -e "${BOLD}🔗 相关链接:${NC}"
echo "  • 检查工具: https://github.com/yourusername/openclaw-security-scanner"
echo "  • 反馈问题: https://github.com/yourusername/openclaw-security-scanner/issues"
echo ""

# 返回状态码
if [ $CRITICAL_ISSUES -gt 0 ]; then
    exit 2
elif [ $WARNINGS -gt 0 ]; then
    exit 1
else
    exit 0
fi
