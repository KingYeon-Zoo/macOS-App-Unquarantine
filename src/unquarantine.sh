#!/bin/bash

set -u

EXIT_UNCHANGED=10
EXIT_DAMAGED_SIGNATURE=20
EXIT_INVALID_INPUT=64

if [ "$#" -ne 1 ]; then
  printf '用法：%s "/路径/应用.app"\n' "$0" >&2
  exit "$EXIT_INVALID_INPUT"
fi

APP_PATH="$1"

if [ ! -d "$APP_PATH" ] || [[ "$APP_PATH" != *.app ]]; then
  printf '所选路径不是有效的 .app 应用包：%s\n' "$APP_PATH" >&2
  exit "$EXIT_INVALID_INPUT"
fi

has_quarantine_attribute() {
  /usr/bin/xattr -lr "$APP_PATH" 2>/dev/null |
    /usr/bin/grep -q "com.apple.quarantine:"
}

verify_signed_app() {
  if /usr/bin/codesign -dv "$APP_PATH" >/dev/null 2>&1; then
    if ! SIGNATURE_ERROR=$(/usr/bin/codesign --verify --deep --strict "$APP_PATH" 2>&1); then
      printf '代码签名验证失败：App 的文件缺失或已被修改。\n%s\n' "$SIGNATURE_ERROR" >&2
      return "$EXIT_DAMAGED_SIGNATURE"
    fi
  fi
}

HAD_QUARANTINE=0
if has_quarantine_attribute; then
  HAD_QUARANTINE=1

  if ! ERROR_OUTPUT=$(/usr/bin/xattr -dr com.apple.quarantine "$APP_PATH" 2>&1); then
    printf '%s\n' "$ERROR_OUTPUT" >&2
    exit 1
  fi

  if has_quarantine_attribute; then
    printf '修复失败：隔离属性仍然存在。\n' >&2
    exit 1
  fi
fi

if ! verify_signed_app; then
  exit "$EXIT_DAMAGED_SIGNATURE"
fi

if [ "$HAD_QUARANTINE" -eq 0 ]; then
  printf '无需修复：该 App 没有下载隔离属性，代码签名未发现损坏。\n'
  exit "$EXIT_UNCHANGED"
fi

printf '修复完成：已删除下载隔离属性。\n'
