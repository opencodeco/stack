#!/usr/bin/env bash
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
# shellcheck source=tests/lib.sh
source "$SCRIPT_DIR/lib.sh"

COMPONENT="o11y"
trap 'stack o11y down -v > /dev/null 2>&1' EXIT

echo "▶ $COMPONENT"

source "$REPO_ROOT/.env.dist"
JAEGER_UI_PORT="${JAEGER_UI_PORT:-8034}"
PROMETHEUS_PORT="${PROMETHEUS_PORT:-8035}"
GRAFANA_PORT="${GRAFANA_PORT:-8036}"
OTLP_HTTP_PORT="${OTLP_HTTP_PORT:-4318}"

if ! start_component o11y; then report; exit 1; fi

# None of the o11y services have Docker healthchecks — wait via HTTP
if ! wait_http "http://localhost:${JAEGER_UI_PORT}"; then
    fail "Jaeger UI did not respond"; report; exit 1
fi
if ! wait_http "http://localhost:${PROMETHEUS_PORT}/-/healthy"; then
    fail "Prometheus did not respond"; report; exit 1
fi
if ! wait_http "http://localhost:${GRAFANA_PORT}/api/health"; then
    fail "Grafana did not respond"; report; exit 1
fi

jaeger_code=$(curl -s -o /dev/null -w "%{http_code}" "http://localhost:${JAEGER_UI_PORT}" 2>/dev/null)
assert_contains "Jaeger UI responds with 2xx" "2" "$jaeger_code"

prom_health=$(curl -s "http://localhost:${PROMETHEUS_PORT}/-/healthy" 2>/dev/null)
assert_contains "Prometheus is healthy" "Healthy" "$prom_health"

prom_config=$(curl -s "http://localhost:${PROMETHEUS_PORT}/api/v1/status/config" 2>/dev/null)
assert_contains "Prometheus scrape job is configured" "opencodeco" "$prom_config"

grafana_health=$(curl -s "http://localhost:${GRAFANA_PORT}/api/health" 2>/dev/null)
assert_contains "Grafana is healthy" "ok" "$grafana_health"

otlp_code=$(curl -s -o /dev/null -w "%{http_code}" \
    --connect-timeout 3 \
    "http://localhost:${OTLP_HTTP_PORT}/" 2>/dev/null)
ok "OTel Collector OTLP HTTP is reachable (got HTTP $otlp_code)"

report
