# 安全说明

## 支持范围

当前维护版本为最新 GitHub Release。

## 报告安全问题

请不要在公开 Issue 中披露可被利用的安全问题。请通过 GitHub 仓库的 Security Advisory 私下报告，并说明：

- 受影响版本
- 复现步骤
- 潜在影响
- 建议修复方式

## 项目安全边界

本工具只删除用户明确选择的单个 App 上的 `com.apple.quarantine` 属性。它不会验证 App 是否可信，也不会关闭 Gatekeeper。

管理员授权阶段只执行 macOS 系统固定路径下的 `/usr/bin/xattr`，不会以管理员权限执行 App 包内的辅助脚本。
