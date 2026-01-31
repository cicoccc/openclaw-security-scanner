# 快速开始指南

## 1. 下载工具

```bash
git clone https://github.com/cicoccc/openclaw-security-scanner.git
cd openclaw-security-scanner
```

## 2. 运行检查

```bash
./scripts/security_check.sh
```

## 3. 查看结果

根据评分采取行动：

### ✨ 90-100 分：优秀
恭喜！你的配置很安全，继续保持。

建议：
- 每周运行一次检查
- 每次修改配置后检查

### 👍 70-89 分：良好
配置基本安全，有小问题需要优化。

**立即行动：**
```bash
./scripts/security_fix.sh
```

### ⚠️ 50-69 分：需要改进
存在中等风险，建议尽快修复。

**立即行动：**
```bash
# 1. 运行自动修复
./scripts/security_fix.sh

# 2. 再次检查
./scripts/security_check.sh
```

### 🚨 0-49 分：危险
有严重安全风险，请立即修复！

**紧急行动：**
```bash
# 1. 立即运行自动修复
./scripts/security_fix.sh

# 2. 如果无法自动修复，手动操作：
openclaw config set gateway.bind loopback
openclaw config set gateway.auth.mode token
openclaw gateway restart

# 3. 再次检查确认
./scripts/security_check.sh
```

## 4. 生成报告（可选）

```bash
./scripts/security_report.sh
```

会在当前目录生成 `openclaw_security_report_*.md` 文件。

## 5. 定期检查

建议添加到日程：
- 首次部署后立即检查 ✅
- 每周运行一次 📅
- 修改配置后检查 🔧

## 需要帮助？

- 查看 [README](README_CN.md)
- 提交 [Issue](https://github.com/cicoccc/openclaw-security-scanner/issues)
- 加入 [讨论](https://github.com/cicoccc/openclaw-security-scanner/discussions)
