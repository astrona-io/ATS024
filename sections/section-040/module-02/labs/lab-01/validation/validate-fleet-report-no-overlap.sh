#!/usr/bin/env bash
# Check: the CronJob fleet-report never starts a run while the previous one is active.
set -uo pipefail


policy="$(kubectl -n starfleet get cronjob fleet-report -o jsonpath="{.spec.concurrencyPolicy}" 2>/dev/null || true)"
if [ "$policy" = "Forbid" ]; then
  echo "PASS: fleet-report uses concurrencyPolicy Forbid"
  exit 0
fi
echo "FAIL: concurrencyPolicy is \"$policy\", expected Forbid"
exit 1
