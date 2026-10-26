#!/usr/bin/env bash

set -u

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR" || exit 1

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

echo "=================================="
echo " Assignment 3: Bash Linting"
echo "=================================="

required_files=(
    README.md
    app/app.sh
    scripts/lint.sh
    scripts/build.sh
    tests/test.sh
    .github/workflows/ci.yml
    Dockerfile
    compose.yaml
    .dockerignore
    grade.sh
)

for file in "${required_files[@]}"; do
    if [[ -f "$file" ]]; then
        pass "Required file exists: $file"
    else
        fail "Missing required file: $file"
    fi
done

bash_scripts=(
    app/app.sh
    scripts/lint.sh
    scripts/build.sh
    tests/test.sh
    grade.sh
)

for file in "${bash_scripts[@]}"; do
    if [[ -f "$file" ]] && bash -n "$file"; then
        pass "Bash syntax valid: $file"
    else
        fail "Bash syntax invalid or file missing: $file"
    fi
done

echo
echo "=================================="
echo "Lint Summary"
echo "Passed: $PASS"
echo "Failed: $FAIL"
echo "=================================="

[[ "$FAIL" -eq 0 ]]

