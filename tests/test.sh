#!/usr/bin/env bash

set -u

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
APP="$ROOT_DIR/app/app.sh"

PASS=0
FAIL=0

pass() {
    echo "PASS: $1"
    PASS=$((PASS + 1))
}

fail() {
    echo "FAIL: $1"
    FAIL=$((FAIL + 1))
}

check_exit_code() {
    local description="$1"
    local expected="$2"
    shift 2

    "$@" >/tmp/assignment3-test.log 2>&1
    local actual=$?

    if [[ "$actual" -eq "$expected" ]]; then
        pass "$description"
    else
        fail "$description (expected exit $expected, got $actual)"
        cat /tmp/assignment3-test.log
    fi
}

check_output() {
    local description="$1"
    local expected="$2"
    shift 2

    if "$@" 2>&1 | grep -Fq "$expected"; then
        pass "$description"
    else
        fail "$description"
    fi
}

echo "=================================="
echo " Assignment 3: Application Tests"
echo "=================================="

# 1. Help command
check_exit_code "Help command succeeds" 0 "$APP" help

# 2. System information
check_exit_code "System-info command succeeds" 0 "$APP" system-info

# 3. Invalid command
check_exit_code "Invalid command returns exit code 2" 2 "$APP" invalid-command

# 4. Missing host
check_exit_code "Missing host returns exit code 2" 2 "$APP" check-host

# 5. Valid host
check_exit_code "Valid host resolves" 0 "$APP" check-host localhost

# 6. Missing port
check_exit_code "Missing port returns exit code 2" 2 "$APP" check-port localhost

# 7. Non-numeric port
check_exit_code "Non-numeric port returns exit code 2" 2 "$APP" check-port localhost abc

# 8. Out-of-range port
check_exit_code "Out-of-range port returns exit code 2" 2 "$APP" check-port localhost 70000

# 9. Port zero
check_exit_code "Port zero returns exit code 2" 2 "$APP" check-port localhost 0

# 10. Valid port format
check_output "Port validation accepts a numeric port" \
    "TCP connection" "$APP" check-port localhost 1

echo
echo "=================================="
echo "Test Summary"
echo "Passed: $PASS"
echo "Failed: $FAIL"
echo "=================================="

[[ "$FAIL" -eq 0 ]]
echo "FAILURE DEMONSTRATION"
exit 1
