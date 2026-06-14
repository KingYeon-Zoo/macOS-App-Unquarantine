#!/bin/bash

set -eu

PROJECT_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
SOURCE="$PROJECT_ROOT/src/AppUnlock.applescript"
HELPER="$PROJECT_ROOT/src/unquarantine.sh"
BUILD_DIR="$PROJECT_ROOT/build"
DIST_DIR="$PROJECT_ROOT/dist"
APP="$BUILD_DIR/App 解锁工具.app"
VERSION="1.0.0"
ARCHIVE_NAME="App-Unlock-Tool-v${VERSION}-macOS.zip"
PLIST_BUDDY="/usr/libexec/PlistBuddy"

set_plist_string() {
  key="$1"
  value="$2"
  plist="$3"

  if "$PLIST_BUDDY" -c "Print :$key" "$plist" >/dev/null 2>&1; then
    "$PLIST_BUDDY" -c "Set :$key $value" "$plist"
  else
    "$PLIST_BUDDY" -c "Add :$key string $value" "$plist"
  fi
}

rm -rf "$BUILD_DIR" "$DIST_DIR"
mkdir -p "$BUILD_DIR" "$DIST_DIR"

/usr/bin/osacompile -o "$APP" "$SOURCE"
/bin/cp "$HELPER" "$APP/Contents/Resources/unquarantine.sh"
/bin/chmod 755 "$APP/Contents/Resources/unquarantine.sh"

INFO_PLIST="$APP/Contents/Info.plist"
set_plist_string "CFBundleIdentifier" "io.github.macos-app-unquarantine" "$INFO_PLIST"
set_plist_string "CFBundleName" "App 解锁工具" "$INFO_PLIST"
set_plist_string "CFBundleDisplayName" "App 解锁工具" "$INFO_PLIST"
set_plist_string "CFBundleShortVersionString" "$VERSION" "$INFO_PLIST"
set_plist_string "CFBundleVersion" "$VERSION" "$INFO_PLIST"
set_plist_string "LSMinimumSystemVersion" "12.0" "$INFO_PLIST"
set_plist_string "NSHumanReadableCopyright" "版权所有 © 2026 macOS-App-Unquarantine 项目贡献者，MIT 许可证。" "$INFO_PLIST"
set_plist_string "NSSystemAdministrationUsageDescription" "仅在目标 App 权限不足时请求系统管理员授权，以删除下载隔离属性。" "$INFO_PLIST"

for privacy_key in \
  NSAppleEventsUsageDescription \
  NSAppleMusicUsageDescription \
  NSCalendarsUsageDescription \
  NSCameraUsageDescription \
  NSContactsUsageDescription \
  NSHomeKitUsageDescription \
  NSMicrophoneUsageDescription \
  NSPhotoLibraryUsageDescription \
  NSRemindersUsageDescription \
  NSSiriUsageDescription
do
  "$PLIST_BUDDY" -c "Delete :$privacy_key" "$INFO_PLIST" >/dev/null 2>&1 || true
done

/usr/bin/codesign --force --deep --sign - "$APP"

(
  cd "$BUILD_DIR"
  /usr/bin/ditto -c -k --sequesterRsrc --keepParent "App 解锁工具.app" "$DIST_DIR/$ARCHIVE_NAME"
)

(
  cd "$DIST_DIR"
  /usr/bin/shasum -a 256 "$ARCHIVE_NAME" >"$ARCHIVE_NAME.sha256"
)

printf '构建完成：\n'
printf '  App：%s\n' "$APP"
printf '  发布包：%s\n' "$DIST_DIR/$ARCHIVE_NAME"
printf '  校验文件：%s\n' "$DIST_DIR/$ARCHIVE_NAME.sha256"
