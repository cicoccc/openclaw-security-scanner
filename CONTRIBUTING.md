# 贡献指南

感谢你考虑为 OpenClaw Security Scanner 做贡献！

## 如何贡献

### 报告 Bug

发现问题？请 [提交 Issue](https://github.com/cicoccc/openclaw-security-scanner/issues/new) 并包含：

- 问题描述
- 复现步骤
- 预期行为
- 实际行为
- 系统环境（OS、OpenClaw 版本等）
- 相关日志或截图

### 建议新功能

有好想法？我们欢迎：

1. 先在 [Discussions](https://github.com/cicoccc/openclaw-security-scanner/discussions) 讨论
2. 确认可行后提交 Issue
3. 等待维护者反馈
4. 开始实现（如果你愿意）

### 提交 Pull Request

1. Fork 仓库
2. 创建特性分支
   ```bash
   git checkout -b feature/your-feature-name
   ```
3. 进行修改
4. 测试修改
   ```bash
   ./scripts/security_check.sh
   ```
5. 提交修改
   ```bash
   git commit -m "Add: 你的功能描述"
   ```
6. 推送到 Fork
   ```bash
   git push origin feature/your-feature-name
   ```
7. 创建 Pull Request

## 开发指南

### 项目结构

```
openclaw-security-scanner/
├── SKILL.md                 # Skill 定义文件
├── README.md                # 英文文档
├── README_CN.md             # 中文文档
├── LICENSE                  # MIT 许可证
├── scripts/
│   ├── security_check.sh    # 安全检查脚本
│   ├── security_fix.sh      # 自动修复脚本
│   └── security_report.sh   # 报告生成脚本
└── .gitignore
```

### 代码风格

- Shell 脚本使用 Bash
- 遵循 ShellCheck 规范
- 添加清晰的注释
- 保持一致的缩进（2 空格）

### 测试

添加新功能时：
1. 在安全和不安全的配置下测试
2. 确保不会破坏现有功能
3. 测试修复功能是否正确

### Commit 信息格式

```
类型: 简短描述

详细描述（可选）

类型:
- Add: 新功能
- Fix: Bug 修复
- Update: 功能更新
- Docs: 文档更新
- Style: 代码格式
- Refactor: 重构
- Test: 测试相关
```

## 行为准则

- 尊重所有贡献者
- 保持友好和专业
- 接受建设性批评
- 关注项目目标

## 需要帮助？

- 查看 [Issues](https://github.com/cicoccc/openclaw-security-scanner/issues)
- 加入 [Discussions](https://github.com/cicoccc/openclaw-security-scanner/discussions)
- 联系维护者

感谢你的贡献！🎉
