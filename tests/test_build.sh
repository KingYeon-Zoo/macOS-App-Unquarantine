#!/bin/bash

set -eu

PROJECT_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
BUILD_SCRIPT="$PROJECT_ROOT/scripts/build.sh"
APP="$PROJECT_ROOT/build/App 解锁工具.app"
ZIP="$PROJECT_ROOT/dist/App-Unlock-Tool-v1.0.2-macOS.zip"
CHECKSUM="$ZIP.sha256"

if [ ! -x "$BUILD_SCRIPT" ]; then
  printf '失败：构建脚本不存在或不可执行：%s\n' "$BUILD_SCRIPT" >&2
  exit 1
fi

"$BUILD_SCRIPT"

[ -d "$APP" ]
[ -x "$APP/Contents/Resources/unquarantine.sh" ]
[ -f "$APP/Contents/Info.plist" ]
[ -f "$ZIP" ]
[ -f "$CHECKSUM" ]

/usr/bin/plutil -lint "$APP/Contents/Info.plist" >/dev/null
/usr/bin/codesign --verify --deep --strict "$APP"

[ "$(/usr/libexec/PlistBuddy -c 'Print :LSMinimumSystemVersion' "$APP/Contents/Info.plist")" = "12.0" ]
if /usr/libexec/PlistBuddy -c 'Print :NSCameraUsageDescription' "$APP/Contents/Info.plist" >/dev/null 2>&1; then
  printf '失败：App 不应声明相机权限用途。\n' >&2
  exit 1
fi

printf '通过：App、发布压缩包和校验文件均已生成并验证。\n'
