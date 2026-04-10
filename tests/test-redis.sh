#!/usr/bin/env bash
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
# shellcheck source=tests/lib.sh
source "$SCRIPT_DIR/lib.sh"

COMPONENT="redis"
trap 'stack redis down -v > /dev/null 2>&1' EXIT

echo "▶ $COMPONENT"

source "$REPO_ROOT/.env.dist"
REDIS_PORT="${REDIS_PORT:-6379}"
if port_in_use "$REDIS_PORT"; then
    echo "  ⚠ skipped: port $REDIS_PORT already in use"
    exit 0
fi

if ! start_component redis; then report; exit 1; fi
if ! wait_healthy opencodeco-redis; then fail "redis did not become healthy"; report; exit 1; fi

set_result=$(docker exec opencodeco-redis redis-cli SET stack:test "hello" 2>&1)
assert_eq "SET key" "OK" "$set_result"

get_result=$(docker exec opencodeco-redis redis-cli GET stack:test 2>&1)
assert_eq "GET key returns value" "hello" "$get_result"

del_result=$(docker exec opencodeco-redis redis-cli DEL stack:test 2>&1)
assert_eq "DEL key" "1" "$del_result"

ping=$(docker exec opencodeco-redis redis-cli PING 2>&1)
assert_eq "PING returns PONG" "PONG" "$ping"

report
