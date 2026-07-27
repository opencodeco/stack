#!/usr/bin/env bash
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
# shellcheck source=tests/lib.sh
source "$SCRIPT_DIR/lib.sh"

COMPONENT="postgres"
trap 'stack postgres down -v > /dev/null 2>&1' EXIT

echo "▶ $COMPONENT"

source "$REPO_ROOT/.env.dist"
POSTGRES_PORT="${POSTGRES_PORT:-5432}"
if port_in_use "$POSTGRES_PORT"; then
    echo "  ⚠ skipped: port $POSTGRES_PORT already in use"
    exit 0
fi

if ! start_component postgres; then report; exit 1; fi
if ! wait_healthy opencodeco-postgres; then fail "postgres did not become healthy"; report; exit 1; fi

result=$(docker exec opencodeco-postgres psql -U postgres -tAc "
  CREATE TABLE IF NOT EXISTS stack_test (id SERIAL PRIMARY KEY, val TEXT);
  INSERT INTO stack_test (val) VALUES ('hello');
  SELECT val FROM stack_test WHERE val = 'hello';
  DROP TABLE stack_test;
" 2>&1)
assert_contains "create table, insert, and select" "hello" "$result"

db_list=$(docker exec opencodeco-postgres psql -U postgres -tAc "SELECT datname FROM pg_database;" 2>&1)
assert_contains "default postgres database exists" "postgres" "$db_list"

vector_result=$(docker exec opencodeco-postgres psql -v ON_ERROR_STOP=1 -U postgres -tAc "
  CREATE EXTENSION IF NOT EXISTS vector;
  CREATE TABLE stack_vector_test (id SERIAL PRIMARY KEY, embedding vector(3));
  INSERT INTO stack_vector_test (embedding) VALUES ('[1,2,3]'), ('[4,5,6]');
  SELECT id FROM stack_vector_test ORDER BY embedding <-> '[1,2,3]' LIMIT 1;
  DROP TABLE stack_vector_test;
" 2>&1)
assert_eq "pgvector nearest-neighbor query" "1" "$vector_result"

report
