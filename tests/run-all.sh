#!/usr/bin/env bash
set -e
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
# shellcheck source=tests/lib.sh
source "$SCRIPT_DIR/lib.sh"

echo "══════════════════════════════════════════════"
echo "  stack e2e test suite"
echo "══════════════════════════════════════════════"
echo ""

# Ensure the shared Docker network exists before running any test
echo "▶ Ensuring 'opencodeco' network exists..."
stack network > /dev/null 2>&1
echo "  ✓ network ready"
echo ""

TESTS=(
    "test-postgres.sh"
    "test-mysql.sh"
    "test-redis.sh"
    "test-mongo.sh"
    "test-kafka.sh"
    "test-rabbitmq.sh"
    "test-aws.sh"
    "test-aws-ministack.sh"
    "test-hyperdx.sh"
    "test-o11y.sh"
)

SUITE_PASS=0
SUITE_FAIL=0
FAILED_TESTS=()

for test in "${TESTS[@]}"; do
    test_path="$SCRIPT_DIR/$test"
    if bash "$test_path"; then
        SUITE_PASS=$((SUITE_PASS + 1))
    else
        SUITE_FAIL=$((SUITE_FAIL + 1))
        FAILED_TESTS+=("$test")
    fi
    echo ""
done

echo "══════════════════════════════════════════════"
echo "  Suite results: $SUITE_PASS passed, $SUITE_FAIL failed"
if [ ${#FAILED_TESTS[@]} -gt 0 ]; then
    echo ""
    echo "  Failed:"
    for t in "${FAILED_TESTS[@]}"; do
        echo "    - $t"
    done
fi
echo "══════════════════════════════════════════════"

[ $SUITE_FAIL -eq 0 ]
