#!/bin/bash
# OpenClaw Security Fix Script
# 自动修复检测到的安全问题

set -euo pipefail

# 颜色定义
RED='\033[0;31m'
YELLOW='\033[1;33m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'
BOLD='\033[1m'

FIXED=0
SKIPPED=0

echo ""
echo -e "${BOLD}🔧 OpenClaw Security Auto-Fix${NC}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# 检查 openclaw 命令
if ! command -v openclaw &> /dev/null; then
    echo -e "${RED}❌ 错误: 未找到 openclaw 命令${NC}"
    exit 1
fi

CONFIG_DIR="$HOME/.openclaw"
if [ ! -d "$CONFIG_DIR" ]; then
    echo -e "${RED}❌ 错误: 未找到 OpenClaw 配置目录${NC}"
    exit 1
fi

echo -e "${YELLOW}⚠️  警告: 此操作将修改你的配置文件${NC}"
echo ""
echo "修复内容:"
echo "  • 设置 gateway.bind = loopback"
echo "  • 修复 credentials 目录权限 (700)"
echo "  • 设置插件白名单"
echo "  • 修复配置文件权限 (600)"
echo ""
read -p "是否继续? [y/N] " -n 1 -r
echo ""

if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "已取消"
    exit 0
fi

echo ""
echo -e "${BLUE}📦 备份当前配置...${NC}"

# 创建备份
BACKUP_DIR="$CONFIG_DIR/backups"
mkdir -p "$BACKUP_DIR"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
BACKUP_FILE="$BACKUP_DIR/openclaw.json.backup_$TIMESTAMP"

if [ -f "$CONFIG_DIR/openclaw.json" ]; then
    cp "$CONFIG_DIR/openclaw.json" "$BACKUP_FILE"
    echo -e "${GREEN}✅ 已备份到: $BACKUP_FILE${NC}"
else
    echo -e "${YELLOW}⚠️  未找到配置文件${NC}"
fi

echo ""
echo -e "${BLUE}🔧 开始修复...${NC}"
echo ""

# ============================================
# 修复 1: Gateway 绑定
# ============================================
echo -n "🔧 修复 Gateway 绑定配置... "
CURRENT_BIND=$(openclaw config get gateway.bind 2>/dev/null || echo "unknown")

if [ "$CURRENT_BIND" != "loopback" ]; then
    openclaw config set gateway.bind loopback > /dev/null 2>&1
    echo -e "${GREEN}✅ 已修复${NC}"
    FIXED=$((FIXED + 1))
else
    echo -e "${BLUE}ℹ️  已是安全配置${NC}"
    SKIPPED=$((SKIPPED + 1))
fi

# ============================================
# 修复 2: 认证配置
# ============================================
echo -n "🔧 检查认证配置... "
AUTH_MODE=$(openclaw config get gateway.auth.mode 2>/dev/null || echo "unknown")

if [ "$AUTH_MODE" = "none" ] || [ "$AUTH_MODE" = "null" ] || [ "$AUTH_MODE" = "unknown" ]; then
    # 生成随机 token
    NEW_TOKEN=$(openssl rand -hex 24 2>/dev/null || head -c 24 /dev/urandom | xxd -p)
    openclaw config set gateway.auth.mode token > /dev/null 2>&1
    openclaw config set gateway.auth.token "$NEW_TOKEN" > /dev/null 2>&1
    echo -e "${GREEN}✅ 已启用 Token 认证${NC}"
    FIXED=$((FIXED + 1))
else
    echo -e "${BLUE}ℹ️  认证已启用${NC}"
    SKIPPED=$((SKIPPED + 1))
fi

# ============================================
# 修复 3: Credentials 目录权限
# ============================================
echo -n "🔧 修复 Credentials 目录权限... "
CRED_DIR="$CONFIG_DIR/credentials"

if [ -d "$CRED_DIR" ]; then
    CURRENT_PERMS=$(stat -f "%Lp" "$CRED_DIR" 2>/dev/null || stat -c "%a" "$CRED_DIR" 2>/dev/null)
    if [ "$CURRENT_PERMS" != "700" ]; then
        chmod 700 "$CRED_DIR"
        echo -e "${GREEN}✅ 已修复 (700)${NC}"
        FIXED=$((FIXED + 1))
    else
        echo -e "${BLUE}ℹ️  权限正确${NC}"
        SKIPPED=$((SKIPPED + 1))
    fi
else
    echo -e "${BLUE}ℹ️  目录不存在${NC}"
    SKIPPED=$((SKIPPED + 1))
fi

# ============================================
# 修复 4: 插件白名单
# ============================================
echo -n "🔧 设置插件白名单... "
PLUGIN_ALLOW=$(openclaw config get plugins.allow 2>/dev/null || echo "null")

if [ "$PLUGIN_ALLOW" = "null" ] || [ -z "$PLUGIN_ALLOW" ]; then
    # 获取当前已启用的插件
    ENABLED_PLUGINS=$(openclaw plugins list 2>/dev/null | grep "│ loaded" | awk '{print $2}' | tr '\n' ',' | sed 's/,$//' || echo "")

    if [ -n "$ENABLED_PLUGINS" ]; then
        # 转换为 JSON 数组格式
        PLUGIN_ARRAY="[\"$(echo "$ENABLED_PLUGINS" | sed 's/,/","/g')\"]"
        openclaw config set plugins.allow "$PLUGIN_ARRAY" > /dev/null 2>&1
        echo -e "${GREEN}✅ 已设置${NC}"
        FIXED=$((FIXED + 1))
    else
        # 默认白名单
        openclaw config set plugins.allow '["imessage","feishu","memory-core"]' > /dev/null 2>&1
        echo -e "${GREEN}✅ 已设置默认白名单${NC}"
        FIXED=$((FIXED + 1))
    fi
else
    echo -e "${BLUE}ℹ️  已设置${NC}"
    SKIPPED=$((SKIPPED + 1))
fi

# ============================================
# 修复 5: 配置文件权限
# ============================================
echo -n "🔧 修复配置文件权限... "
CONFIG_FILE="$CONFIG_DIR/openclaw.json"

if [ -f "$CONFIG_FILE" ]; then
    CURRENT_PERMS=$(stat -f "%Lp" "$CONFIG_FILE" 2>/dev/null || stat -c "%a" "$CONFIG_FILE" 2>/dev/null)
    if [ "$CURRENT_PERMS" != "600" ] && [ "$CURRENT_PERMS" != "400" ]; then
        chmod 600 "$CONFIG_FILE"
        echo -e "${GREEN}✅ 已修复 (600)${NC}"
        FIXED=$((FIXED + 1))
    else
        echo -e "${BLUE}ℹ️  权限正确${NC}"
        SKIPPED=$((SKIPPED + 1))
    fi
fi

# ============================================
# 修复 6: Tailscale 配置
# ============================================
echo -n "🔧 检查 Tailscale 配置... "
TAILSCALE_MODE=$(openclaw config get gateway.tailscale.mode 2>/dev/null || echo "off")

if [ "$TAILSCALE_MODE" != "off" ]; then
    read -p "检测到 Tailscale 已启用，是否关闭? [y/N] " -n 1 -r
    echo ""
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        openclaw config set gateway.tailscale.mode off > /dev/null 2>&1
        echo -e "${GREEN}✅ 已关闭 Tailscale${NC}"
        FIXED=$((FIXED + 1))
    else
        echo -e "${BLUE}ℹ️  保持启用${NC}"
        SKIPPED=$((SKIPPED + 1))
    fi
else
    echo -e "${BLUE}ℹ️  未启用${NC}"
    SKIPPED=$((SKIPPED + 1))
fi

# ============================================
# 重启 Gateway
# ============================================
echo ""
echo -e "${BLUE}🔄 重启 Gateway 以应用更改...${NC}"

if openclaw gateway restart > /dev/null 2>&1; then
    echo -e "${GREEN}✅ Gateway 已重启${NC}"
else
    echo -e "${YELLOW}⚠️  Gateway 重启失败，请手动重启:${NC}"
    echo "   openclaw gateway restart"
fi

# ============================================
# 输出结果
# ============================================
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo -e "${BOLD}✅ 修复完成！${NC}"
echo ""
echo -e "  ${GREEN}已修复: $FIXED 个问题${NC}"
echo -e "  ${BLUE}已跳过: $SKIPPED 项（已是安全配置）${NC}"
echo ""

if [ $FIXED -gt 0 ]; then
    echo -e "${YELLOW}💡 建议:${NC}"
    echo "  1. 运行安全检查验证修复: $(dirname "$0")/security_check.sh"
    echo "  2. 备份文件已保存: $BACKUP_FILE"
    echo ""
fi

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
