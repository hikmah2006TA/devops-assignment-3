#!/usr/bin/env bash

set -u

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$ROOT_DIR" || exit 1

PASS=0
FAIL=0
IMAGE="devops-tool"

pass() {
    echo "PASS: $1"
    PASS=$((PASS + 1))
}

fail() {
    echo "FAIL: $1"
    FAIL=$((FAIL + 1))
}

echo "======================================"
echo " Assignment 3 Grading Checks"
echo "======================================"

# Required files
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

echo
echo "Checking Bash syntax..."

scripts=(
    app/app.sh
    scripts/lint.sh
    scripts/build.sh
    tests/test.sh
    grade.sh
)

for file in "${scripts[@]}"; do
    if [[ -f "$file" ]] && bash -n "$file"; then
        pass "Valid Bash syntax: $file"
    else
        fail "Invalid Bash syntax or missing file: $file"
    fi
done

echo
echo "Checking executable permissions..."

for file in app/app.sh scripts/lint.sh scripts/build.sh tests/test.sh grade.sh; do
    if [[ -x "$file" ]]; then
        pass "Executable: $file"
    else
        fail "Not executable: $file"
    fi
done

echo
echo "Running lint checks..."

if [[ -x ./scripts/lint.sh ]]; then
    if ./scripts/lint.sh; then
        pass "Lint checks passed"
    else
        fail "Lint checks failed"
    fi
else
    fail "Lint script is missing or not executable"
fi

echo
echo "Checking Docker..."

if command -v docker >/dev/null 2>&1; then
    if docker build -t "$IMAGE" .; then
        pass "Docker image builds successfully"

        if docker run --rm "$IMAGE" help >/dev/null 2>&1; then
            pass "Docker help command works"
        else
            fail "Docker help command failed"
        fi

        if docker run --rm "$IMAGE" system-info >/dev/null 2>&1; then
            pass "Docker system-info command works"
        else
            fail "Docker system-info command failed"
        fi

        docker image rm "$IMAGE" >/dev/null 2>&1 || true
    else
        fail "Docker image build failed"
    fi
else
    fail "Docker is not installed or unavailable"
fi

echo
echo "Running student tests..."

if [[ -x ./tests/test.sh ]]; then
    if ./tests/test.sh; then
        pass "Student test suite passed"
    else
        fail "Student test suite failed"
    fi
else
    fail "Student test script is missing or not executable"
fi

echo
echo "Checking Git history..."

if command -v git >/dev/null 2>&1 && git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    commits=$(git rev-list --count HEAD 2>/dev/null || echo 0)

    if [[ "$commits" -ge 5 ]]; then
        pass "Git has at least 5 commits"
    else
        echo "WARN: Fewer than 5 Git commits; create meaningful commits."
    fi

    branch_count=$(git for-each-ref --format='%(refname:short)' refs/heads 2>/dev/null | grep -vE '^(main|master)$' | wc -l | tr -d ' ')

    if [[ "$branch_count" -ge 1 ]]; then
        pass "A non-main branch exists locally"
    else
        echo "WARN: No local feature branch found."
    fi
else
    echo "WARN: Git checks skipped because this is not a Git repository."
fi

echo
echo "======================================"
echo "Passed: $PASS"
echo "Failed: $FAIL"
echo "======================================"

[[ "$FAIL" -eq 0 ]]
