#!/usr/bin/env bash

set -u

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR" || exit 1

IMAGE="devops-tool"

echo "=================================="
echo " Assignment 3: Docker Build"
echo "=================================="

if ! command -v docker >/dev/null 2>&1; then
    echo "ERROR: Docker is not installed or unavailable."
    exit 1
fi

echo "Building Docker image..."
if ! docker build -t "$IMAGE" .; then
    echo "ERROR: Docker image build failed."
    exit 1
fi

echo
echo "Testing help command..."
if ! docker run --rm "$IMAGE" help; then
    echo "ERROR: Help command failed."
    exit 1
fi

echo
echo "Testing system-info command..."
if ! docker run --rm "$IMAGE" system-info; then
    echo "ERROR: System-info command failed."
    exit 1
fi

echo
echo "Testing invalid command..."
docker run --rm "$IMAGE" invalid-command >/dev/null 2>&1
STATUS=$?

if [[ "$STATUS" -eq 2 ]]; then
    echo "PASS: Invalid command returned exit code 2."
else
    echo "FAIL: Expected exit code 2, received $STATUS."
    exit 1
fi

echo
echo "SUCCESS: Docker build and smoke tests passed."
