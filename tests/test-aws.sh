#!/usr/bin/env bash
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
# shellcheck source=tests/lib.sh
source "$SCRIPT_DIR/lib.sh"

COMPONENT="aws"
trap 'stack aws down -v > /dev/null 2>&1' EXIT

echo "▶ $COMPONENT"

source "$REPO_ROOT/.env.dist"
AWS_PORT="${AWS_PORT:-4566}"

if ! start_component aws; then report; exit 1; fi
if ! wait_http "http://localhost:${AWS_PORT}/_localstack/health"; then
    fail "LocalStack health endpoint timed out"
    report; exit 1
fi

health=$(curl -s "http://localhost:${AWS_PORT}/_localstack/health")
assert_contains "LocalStack health endpoint responds" "available" "$health"

_aws() {
    local tmpconf
    tmpconf=$(mktemp)
    printf '[default]\nregion = us-east-1\n' > "$tmpconf"
    env -u AWS_DEFAULT_PROFILE -u AWS_PROFILE -u AWS_CA_BUNDLE \
        AWS_CONFIG_FILE="$tmpconf" AWS_ACCESS_KEY_ID=test AWS_SECRET_ACCESS_KEY=test \
        aws --endpoint-url="http://localhost:${AWS_PORT}" "$@"
    local ret=$?
    rm -f "$tmpconf"
    return $ret
}

if command -v aws > /dev/null 2>&1; then
    _aws s3 mb s3://stack-test-bucket > /dev/null 2>&1
    ok "create S3 bucket"

    buckets=$(_aws s3 ls 2>&1)
    assert_contains "list S3 buckets" "stack-test-bucket" "$buckets"

    _aws s3 rb s3://stack-test-bucket > /dev/null 2>&1
    ok "delete S3 bucket"
else
    echo "  (skipping S3 operations: 'aws' CLI not found on host)"
fi

report
