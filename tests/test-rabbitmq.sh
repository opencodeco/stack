#!/usr/bin/env bash
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
# shellcheck source=tests/lib.sh
source "$SCRIPT_DIR/lib.sh"

COMPONENT="rabbitmq"
trap 'stack rabbitmq down -v > /dev/null 2>&1' EXIT

echo "▶ $COMPONENT"

source "$REPO_ROOT/.env.dist"
RABBITMQ_PORT="${RABBITMQ_PORT:-5672}"
if port_in_use "$RABBITMQ_PORT"; then
    echo "  ⚠ skipped: port $RABBITMQ_PORT already in use"
    exit 0
fi

if ! start_component rabbitmq; then report; exit 1; fi
if ! wait_healthy opencodeco-rabbitmq; then fail "rabbitmq did not become healthy"; report; exit 1; fi

ping=$(docker exec opencodeco-rabbitmq rabbitmq-diagnostics -q ping 2>&1)
assert_contains "broker ping" "Ping succeeded" "$ping"

docker exec opencodeco-rabbitmq rabbitmqadmin -u opencodeco -p opencodeco \
  declare queue --name stack-test-queue --durable false > /dev/null 2>&1
ok "declare queue"

docker exec opencodeco-rabbitmq rabbitmqadmin -u opencodeco -p opencodeco \
  publish message --routing-key stack-test-queue --payload "hello" > /dev/null 2>&1
ok "publish message"

message=$(docker exec opencodeco-rabbitmq rabbitmqadmin -u opencodeco -p opencodeco \
  get messages --queue stack-test-queue 2>&1)
assert_contains "get message from queue" "hello" "$message"

docker exec opencodeco-rabbitmq rabbitmqadmin -u opencodeco -p opencodeco \
  delete queue --name stack-test-queue > /dev/null 2>&1
ok "delete queue"

report
