#!/usr/bin/env bash
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
# shellcheck source=tests/lib.sh
source "$SCRIPT_DIR/lib.sh"

COMPONENT="mongo"
trap 'stack mongo down -v > /dev/null 2>&1' EXIT

echo "▶ $COMPONENT"

source "$REPO_ROOT/.env.dist"
MONGO_PORT="${MONGO_PORT:-27017}"
if port_in_use "$MONGO_PORT"; then
    echo "  ⚠ skipped: port $MONGO_PORT already in use"
    exit 0
fi

if ! start_component mongo; then report; exit 1; fi
if ! wait_healthy opencodeco-mongo; then fail "mongo did not become healthy"; report; exit 1; fi

insert=$(docker exec opencodeco-mongo mongosh --quiet --eval "
  db = db.getSiblingDB('stack_test');
  db.items.insertOne({ val: 'hello' });
  JSON.stringify(db.items.findOne({ val: 'hello' }));
" 2>&1)
assert_contains "insertOne and findOne" "hello" "$insert"

cleanup=$(docker exec opencodeco-mongo mongosh --quiet --eval "
  db.getSiblingDB('stack_test').dropDatabase();
" 2>&1)
assert_contains "drop test database" "ok" "$cleanup"

report
