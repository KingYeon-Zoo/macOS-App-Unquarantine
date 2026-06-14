# v1.0.1 发布说明

修复递归隔离属性检测问题。

## 修复内容

- 旧版本只检查 App 包最外层是否存在 `com.apple.quarantine`。
- 当隔离属性仅残留在 App 内部文件或目录时，旧版本会错误显示“无需修复”。
- 新版本会递归检测、递归删除并递归验证整个 App 包。
- 修复命令等价于：

```sh
sudo xattr -r -d com.apple.quarantine "/Applications/目标应用.app"
```

## 下载

下载 `App-Unlock-Tool-v1.0.1-macOS.zip` 并解压即可使用。

可使用同名 `.sha256` 文件核对下载完整性：

```sh
shasum -a 256 -c App-Unlock-Tool-v1.0.1-macOS.zip.sha256
```

## 注意

本版本暂未使用 Apple Developer ID 签名。请只从本项目的 GitHub Releases 下载，并核对 SHA-256。首次运行时可能需要在 Finder 中按住 Control 点击工具并选择“打开”。
