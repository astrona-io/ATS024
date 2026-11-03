#!/usr/bin/env bash
# Check: finished scan-report Jobs are removed automatically after a safe delay.
set -uo pipefail


ttl="$(kubectl -n starfleet get job scan-report -o jsonpath="{.spec.ttlSecondsAfterFinished}" 2>/dev/null || true)"
if [ -z "$ttl" ]; then
  echo "FAIL: ttlSecondsAfterFinished is not set on scan-report"
  exit 1
fi
if [ "$ttl" -lt 900 ] || [ "$ttl" -gt 86400 ]; then
  echo "FAIL: ttlSecondsAfterFinished is $ttl, expected 900 to 86400"
  exit 1
fi
echo "PASS: scan-report is removed $ttl seconds after it finishes"
