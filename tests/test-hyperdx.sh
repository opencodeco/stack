#!/usr/bin/env bash
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
# shellcheck source=tests/lib.sh
source "$SCRIPT_DIR/lib.sh"

COMPONENT="hyperdx"
trap 'stack hyperdx down -v > /dev/null 2>&1' EXIT

echo "▶ $COMPONENT"

source "$REPO_ROOT/.env.dist"
HYPERDX_APP_PORT="${HYPERDX_APP_PORT:-8080}"

if ! start_component hyperdx; then report; exit 1; fi

# HyperDX has no Docker healthcheck — wait for the app UI port
if ! wait_http "http://localhost:${HYPERDX_APP_PORT}"; then
    fail "HyperDX UI did not respond"
    report; exit 1
fi

code=$(curl -s -o /dev/null -w "%{http_code}" "http://localhost:${HYPERDX_APP_PORT}" 2>/dev/null)
assert_contains "HyperDX UI responds with 2xx" "2" "$code"

# Container name is opencodeco-hyperx (not opencodeco-hyperdx)
running=$(docker inspect --format='{{.State.Status}}' opencodeco-hyperx 2>/dev/null)
assert_eq "container is running" "running" "$running"

report
