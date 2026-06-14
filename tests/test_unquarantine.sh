#!/bin/bash

set -u

PROJECT_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
SCRIPT="$PROJECT_ROOT/src/unquarantine.sh"
TEMP_ROOT="$(mktemp -d "${TMPDIR:-/tmp}/app-unquarantine-tests.XXXXXX")"
PASSED=0
FAILED=0

cleanup() {
  rm -rf "$TEMP_ROOT"
}
trap cleanup EXIT

pass() {
  printf '通过：%s\n' "$1"
  PASSED=$((PASSED + 1))
}

fail() {
  printf '失败：%s\n' "$1" >&2
  FAILED=$((FAILED + 1))
}

assert_status() {
  expected="$1"
  actual="$2"
  name="$3"

  if [ "$actual" -eq "$expected" ]; then
    pass "$name"
  else
    fail "$name（预期状态码 $expected，实际 $actual）"
  fi
}

run_script() {
  "$SCRIPT" "$1" >"$TEMP_ROOT/stdout" 2>"$TEMP_ROOT/stderr"
}

set -e

if [ ! -x "$SCRIPT" ]; then
  printf '失败：核心脚本不存在或不可执行：%s\n' "$SCRIPT" >&2
  exit 1
fi

PLAIN_DIR="$TEMP_ROOT/普通目录"
mkdir -p "$PLAIN_DIR"
STATUS=0
run_script "$PLAIN_DIR" || STATUS=$?
assert_status 64 "$STATUS" "拒绝非 .app 目录"

NO_QUARANTINE_APP="$TEMP_ROOT/无需修复.app"
mkdir -p "$NO_QUARANTINE_APP/Contents"
STATUS=0
run_script "$NO_QUARANTINE_APP" || STATUS=$?
assert_status 10 "$STATUS" "没有隔离属性时返回无需修复"

QUARANTINED_APP="$TEMP_ROOT/带 空格的测试 应用.app"
mkdir -p "$QUARANTINED_APP/Contents/MacOS"
/usr/bin/xattr -w com.apple.quarantine "0081;test;Browser;UUID" "$QUARANTINED_APP"
/usr/bin/xattr -w com.example.keep "保留此属性" "$QUARANTINED_APP"

STATUS=0
run_script "$QUARANTINED_APP" || STATUS=$?
assert_status 0 "$STATUS" "可处理包含空格和中文的 App 路径"

if /usr/bin/xattr -p com.apple.quarantine "$QUARANTINED_APP" >/dev/null 2>&1; then
  fail "隔离属性已删除"
else
  pass "隔离属性已删除"
fi

if [ "$(/usr/bin/xattr -p com.example.keep "$QUARANTINED_APP" 2>/dev/null)" = "保留此属性" ]; then
  pass "其他扩展属性保持不变"
else
  fail "其他扩展属性保持不变"
fi

printf '\n测试结果：%s 项通过，%s 项失败\n' "$PASSED" "$FAILED"
[ "$FAILED" -eq 0 ]
