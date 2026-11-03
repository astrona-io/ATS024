#!/usr/bin/env bash
# Check: the Job scan-report retries failed attempts inside the same Pod.
set -uo pipefail


policy="$(kubectl -n starfleet get job scan-report -o jsonpath="{.spec.template.spec.restartPolicy}" 2>/dev/null || true)"
limit="$(kubectl -n starfleet get job scan-report -o jsonpath="{.spec.backoffLimit}" 2>/dev/null || true)"
fail=0
if [ "$policy" != "OnFailure" ]; then
  echo "FAIL: restartPolicy is \"$policy\", expected OnFailure"
  fail=1
fi
if [ -z "$limit" ] || [ "$limit" -lt 1 ] 2>/dev/null; then
  echo "FAIL: backoffLimit is \"$limit\", expected at least 1"
  fail=1
fi
[ "$fail" -eq 0 ] && echo "PASS: scan-report uses OnFailure with backoffLimit $limit"
exit "$fail"
