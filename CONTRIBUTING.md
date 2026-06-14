# 参与贡献

感谢你改进 macOS App 解锁工具。

## 开发要求

- 使用 macOS 进行构建和测试。
- 不引入关闭 Gatekeeper 或修改系统全局安全策略的功能。
- 不保存、记录或传递管理员密码。
- 保持工具只处理用户明确选择的 App。
- 新增行为时先补测试。

## 本地验证

```sh
bash tests/test_unquarantine.sh
bash tests/test_applescript_source.sh
bash tests/test_build.sh
```

所有测试通过后再提交 Pull Request。

## 提交建议

- 一个提交只解决一个明确问题。
- 提交信息简洁说明行为变化。
- Pull Request 中说明修改原因、用户影响和验证方式。

