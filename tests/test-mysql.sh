#!/usr/bin/env bash
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
# shellcheck source=tests/lib.sh
source "$SCRIPT_DIR/lib.sh"

COMPONENT="mysql"
trap 'stack mysql down -v > /dev/null 2>&1' EXIT

echo "▶ $COMPONENT"

source "$REPO_ROOT/.env.dist"
MYSQL_PORT="${MYSQL_PORT:-3306}"
if port_in_use "$MYSQL_PORT"; then
    echo "  ⚠ skipped: port $MYSQL_PORT already in use"
    exit 0
fi

if ! start_component mysql; then report; exit 1; fi
if ! wait_healthy opencodeco-mysql; then fail "mysql did not become healthy"; report; exit 1; fi

result=$(docker exec opencodeco-mysql mysql -u root -popencodeco -tNe "
  CREATE DATABASE IF NOT EXISTS stack_test;
  USE stack_test;
  CREATE TABLE IF NOT EXISTS items (id INT AUTO_INCREMENT PRIMARY KEY, val VARCHAR(255));
  INSERT INTO items (val) VALUES ('hello');
  SELECT val FROM items WHERE val = 'hello';
  DROP DATABASE stack_test;
" 2>/dev/null)
assert_contains "create db, table, insert, and select" "hello" "$result"

version=$(docker exec opencodeco-mysql mysql -u root -popencodeco -tNe "SELECT VERSION();" 2>/dev/null)
assert_contains "MySQL 9.x is running" "9." "$version"

report
