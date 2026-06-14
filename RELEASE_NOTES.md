# v1.0.0 发布说明

首个公开版本。

## 主要功能

- 将需要处理的 App 拖到“App 解锁工具”上即可自动识别。
- 双击工具时可从系统文件选择窗口选择 App。
- 工具不会保存密码；权限不足时使用 macOS 官方管理员授权窗口。
- 只删除所选 App 的 `com.apple.quarantine` 属性，不关闭 Gatekeeper。

## 下载

下载 `App-Unlock-Tool-v1.0.0-macOS.zip` 并解压即可使用。

可使用同名 `.sha256` 文件核对下载完整性：

```sh
shasum -a 256 -c App-Unlock-Tool-v1.0.0-macOS.zip.sha256
```

## 注意

本版本暂未使用 Apple Developer ID 签名。请只从本项目的 GitHub Releases 下载，并核对 SHA-256。首次运行时可能需要在 Finder 中按住 Control 点击工具并选择“打开”。
