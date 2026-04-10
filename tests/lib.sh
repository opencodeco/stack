#!/usr/bin/env bash
# Shared utilities for e2e tests

PASS=0
FAIL=0
COMPONENT=""

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

stack() {
    (cd "$REPO_ROOT" && "$REPO_ROOT/stack" "$@")
}
export -f stack

ok() {
    echo "  ✓ $1"
    PASS=$((PASS + 1))
}

fail() {
    echo "  ✗ $1"
    FAIL=$((FAIL + 1))
}

assert_eq() {
    local desc="$1" expected="$2" actual="$3"
    if [ "$expected" = "$actual" ]; then
        ok "$desc"
    else
        fail "$desc (expected: '$expected', got: '$actual')"
    fi
}

assert_contains() {
    local desc="$1" needle="$2" haystack="$3"
    if echo "$haystack" | grep -q "$needle"; then
        ok "$desc"
    else
        fail "$desc (expected to contain '$needle', got: '$haystack')"
    fi
}

# Check if a host port is already bound by something other than Docker
port_in_use() {
    local port="$1"
    lsof -i ":$port" -sTCP:LISTEN 2>/dev/null | grep -qv "com.docker\|Docker"
}

# Start a component; on failure print the error and return 1
start_component() {
    local component="$1"
    local output
    output=$(stack "$component" 2>&1)
    local exit_code=$?
    if [ $exit_code -ne 0 ]; then
        echo "  ✗ failed to start '$component':"
        echo "$output" | sed 's/^/    /'
        return 1
    fi
}

# Wait for a container with a Docker healthcheck to become healthy
wait_healthy() {
    local container="$1"
    local timeout="${2:-120}"
    echo "  Waiting for $container to be healthy..."
    local elapsed=0
    while [ "$elapsed" -lt "$timeout" ]; do
        local status
        status=$(docker inspect --format='{{.State.Health.Status}}' "$container" 2>/dev/null)
        if [ "$status" = "healthy" ]; then
            return 0
        fi
        sleep 3
        elapsed=$((elapsed + 3))
    done
    echo "  Timeout: $container did not become healthy within ${timeout}s"
    return 1
}

# Wait for an HTTP endpoint to return a 2xx status
wait_http() {
    local url="$1"
    local timeout="${2:-180}"
    echo "  Waiting for $url..."
    local elapsed=0
    while [ "$elapsed" -lt "$timeout" ]; do
        local code
        code=$(curl -s -o /dev/null -w "%{http_code}" --connect-timeout 2 "$url" 2>/dev/null)
        if [[ "$code" =~ ^2 ]]; then
            return 0
        fi
        sleep 3
        elapsed=$((elapsed + 3))
    done
    echo "  Timeout: $url did not respond within ${timeout}s"
    return 1
}

# Wait for a TCP port to be open
wait_port() {
    local host="$1" port="$2"
    local timeout="${3:-180}"
    echo "  Waiting for $host:$port..."
    local elapsed=0
    while [ "$elapsed" -lt "$timeout" ]; do
        if bash -c "echo > /dev/tcp/$host/$port" 2>/dev/null; then
            return 0
        fi
        sleep 3
        elapsed=$((elapsed + 3))
    done
    echo "  Timeout: $host:$port did not open within ${timeout}s"
    return 1
}

report() {
    echo ""
    if [ $FAIL -eq 0 ]; then
        echo "  ✅ $COMPONENT: $PASS passed, 0 failed"
    else
        echo "  ❌ $COMPONENT: $PASS passed, $FAIL failed"
    fi
    [ $FAIL -eq 0 ]
}
