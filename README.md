# macOS App 解锁工具

一个小型、可审查的 macOS 工具，用于处理可信 App 因下载隔离属性而出现的“已损坏，无法打开，你应该将它移到废纸篓”提示。

## 功能

- 把出问题的 `.app` 拖到“App 解锁工具”上即可识别。
- 也可以双击工具，再从系统窗口选择一个 `.app`。
- 执行前显示 App 名称和完整路径。
- 只删除 `com.apple.quarantine`，不清除其他扩展属性。
- 清除后验证已有代码签名，识别文件缺失或被修改的真正损坏情况。
- 优先使用当前用户权限，仅在权限不足时显示 macOS 官方管理员授权窗口。
- 不读取、不记录、不保存密码。

## 安全提示

隔离属性是 macOS 的安全机制。这个工具不会判断一个 App 是否安全，只应处理你确认来源可信的 App。

工具不会关闭 Gatekeeper，也不会修改系统全局安全设置。它只处理你本次明确拖入或选择的单个 App。

如果 App 来历不明、签名异常或校验值不可信，请不要使用本工具绕过警告。

## 系统要求

- macOS 12 或更高版本
- Apple Silicon 或 Intel Mac

## GitHub 仓库信息

- 建议仓库名：`macOS-App-Unquarantine`
- 建议描述：`一个支持拖放、无需保存密码的 macOS App 下载隔离属性修复工具。`
- 建议主题：`macos`、`applescript`、`quarantine`、`gatekeeper`、`open-source`

## 安装

1. 从 GitHub Releases 下载最新的 `App-Unlock-Tool-v1.0.2-macOS.zip`。
2. 解压缩。
3. 把“App 解锁工具.app”移动到“应用程序”或桌面。
4. 双击运行，或把需要处理的 App 拖到工具图标上。

本项目发布包暂不使用 Apple Developer ID 签名。首次运行工具本身时，如 macOS 阻止打开，请在 Finder 中按住 Control 点击工具，选择“打开”，然后再次确认。

## 使用方法

### 拖放

1. 关闭“App 已损坏”的提示。
2. 在 Finder 中找到该 App。
3. 把 App 图标拖到“App 解锁工具”图标上。
4. 核对名称和路径，确认来源可信后点击“继续”。
5. 完成后可选择立即打开该 App。

### 双击选择

1. 双击“App 解锁工具”。
2. 在系统文件选择窗口中选择需要处理的 `.app`。
3. 核对名称和路径并确认。

## 关于密码

大多数情况下不需要管理员密码。如果目标 App 的文件权限不允许当前用户修改，工具才会调用 macOS 标准授权窗口。

密码由 macOS 接收，工具无法读取或保存。系统是否在短时间内复用授权状态由 macOS 决定。

## 从源码构建

```sh
git clone <你的仓库地址>
cd macOS-App-Unquarantine
bash tests/test_unquarantine.sh
bash scripts/build.sh
```

构建产物：

- `build/App 解锁工具.app`
- `dist/App-Unlock-Tool-v1.0.2-macOS.zip`
- `dist/App-Unlock-Tool-v1.0.2-macOS.zip.sha256`

构建只使用 macOS 自带命令，无第三方依赖。

## 项目结构

```text
.
├── src/
│   ├── AppUnlock.applescript
│   └── unquarantine.sh
├── tests/
│   └── test_unquarantine.sh
├── scripts/
│   └── build.sh
├── README.md
├── CHANGELOG.md
├── RELEASE_NOTES.md
└── LICENSE
```

## 核心命令

本工具最终针对用户选择的 App 执行：

```sh
/usr/bin/xattr -dr com.apple.quarantine "/路径/应用.app"
```

## 开发与测试

```sh
bash tests/test_unquarantine.sh
bash scripts/build.sh
```

测试会在临时目录创建模拟 App，不会修改你已安装的应用。

## 许可证

MIT 许可证，详见 [LICENSE](LICENSE)。

## 参与贡献

提交问题或代码前请阅读 [CONTRIBUTING.md](CONTRIBUTING.md) 和 [SECURITY.md](SECURITY.md)。
