#!/usr/bin/env bash
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
# shellcheck source=tests/lib.sh
source "$SCRIPT_DIR/lib.sh"

COMPONENT="kafka"
trap 'stack kafka down -v > /dev/null 2>&1' EXIT

echo "▶ $COMPONENT"

source "$REPO_ROOT/.env.dist"
KAFKA_PORT="${KAFKA_PORT:-9092}"
if port_in_use "$KAFKA_PORT"; then
    echo "  ⚠ skipped: port $KAFKA_PORT already in use"
    exit 0
fi

if ! start_component kafka; then report; exit 1; fi
if ! wait_healthy opencodeco-kafka; then fail "kafka did not become healthy"; report; exit 1; fi

TOPIC="stack-test-topic-$$"

create=$(docker exec opencodeco-kafka /opt/kafka/bin/kafka-topics.sh \
  --bootstrap-server localhost:9092 \
  --create --topic "$TOPIC" --partitions 1 --replication-factor 1 2>&1)
assert_contains "create topic" "Created topic" "$create"

echo "hello-from-stack" | docker exec -i opencodeco-kafka /opt/kafka/bin/kafka-console-producer.sh \
  --bootstrap-server localhost:9092 \
  --topic "$TOPIC" > /dev/null 2>&1
ok "produce message"

consumed=$(docker exec opencodeco-kafka /opt/kafka/bin/kafka-console-consumer.sh \
  --bootstrap-server localhost:9092 \
  --topic "$TOPIC" \
  --from-beginning \
  --max-messages 1 \
  --timeout-ms 10000 2>/dev/null)
assert_contains "consume message" "hello-from-stack" "$consumed"

docker exec opencodeco-kafka /opt/kafka/bin/kafka-topics.sh \
  --bootstrap-server localhost:9092 \
  --delete --topic "$TOPIC" > /dev/null 2>&1
ok "delete topic"

report
