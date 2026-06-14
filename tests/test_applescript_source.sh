#!/bin/bash

set -eu

PROJECT_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
SOURCE="$PROJECT_ROOT/src/AppUnlock.applescript"
TEMP_APP="$(mktemp -d "${TMPDIR:-/tmp}/app-unlock-compile.XXXXXX")/语法检查.app"

cleanup() {
  rm -rf "$(dirname "$TEMP_APP")"
}
trap cleanup EXIT

if [ ! -f "$SOURCE" ]; then
  printf '失败：AppleScript 源码不存在：%s\n' "$SOURCE" >&2
  exit 1
fi

/usr/bin/osacompile -o "$TEMP_APP" "$SOURCE"

DECOMPILED="$(/usr/bin/osadecompile "$TEMP_APP")"
printf '%s\n' "$DECOMPILED" | /usr/bin/grep -q "on open"
printf '%s\n' "$DECOMPILED" | /usr/bin/grep -q "on run"
printf '%s\n' "$DECOMPILED" | /usr/bin/grep -q "with administrator privileges"
printf '%s\n' "$DECOMPILED" | /usr/bin/grep -q "/usr/bin/xattr -dr com.apple.quarantine"

printf '通过：AppleScript 可编译，并包含双击、拖放及固定系统命令授权入口。\n'
