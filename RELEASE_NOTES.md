# v1.0.2 发布说明

新增真正的 App 损坏诊断。

## 新增内容

- 清除隔离属性后，对已有签名的 App 执行严格代码签名验证。
- 若 App 内部文件缺失或被修改，会明确提示从可信来源重新安装。
- 避免把真正的安装损坏误判为隔离属性问题。

`xattr` 只能移除隔离属性，无法补回安装包中缺失的文件。本版本会区分这两类问题。

## 下载

下载 `App-Unlock-Tool-v1.0.2-macOS.zip` 并解压即可使用。

可使用同名 `.sha256` 文件核对下载完整性：

```sh
shasum -a 256 -c App-Unlock-Tool-v1.0.2-macOS.zip.sha256
```

## 注意

本版本暂未使用 Apple Developer ID 签名。请只从本项目的 GitHub Releases 下载，并核对 SHA-256。首次运行时可能需要在 Finder 中按住 Control 点击工具并选择“打开”。
