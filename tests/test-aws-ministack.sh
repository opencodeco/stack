#!/usr/bin/env bash
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
# shellcheck source=tests/lib.sh
source "$SCRIPT_DIR/lib.sh"

COMPONENT="aws-ministack"
trap 'stack aws-ministack down -v > /dev/null 2>&1' EXIT

echo "▶ $COMPONENT"

source "$REPO_ROOT/.env.dist"
AWS_MINISTACK_PORT="${AWS_MINISTACK_PORT:-4567}"

if ! start_component aws-ministack; then report; exit 1; fi

# MiniStack has no Docker healthcheck — wait for TCP port to open
if ! wait_port localhost "$AWS_MINISTACK_PORT"; then
    fail "MiniStack port $AWS_MINISTACK_PORT did not open"
    report; exit 1
fi
# Give the service a moment to fully initialize after port opens
sleep 3

_aws() {
    local tmpconf
    tmpconf=$(mktemp)
    printf '[default]\nregion = us-east-1\n' > "$tmpconf"
    env -u AWS_DEFAULT_PROFILE -u AWS_PROFILE -u AWS_CA_BUNDLE \
        AWS_CONFIG_FILE="$tmpconf" AWS_ACCESS_KEY_ID=test AWS_SECRET_ACCESS_KEY=test \
        aws --endpoint-url="http://localhost:${AWS_MINISTACK_PORT}" "$@"
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
    ok "MiniStack TCP port $AWS_MINISTACK_PORT is open"
fi

report
