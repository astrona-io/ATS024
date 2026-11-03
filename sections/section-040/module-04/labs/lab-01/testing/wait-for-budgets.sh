#!/usr/bin/env bash
# Waits (bounded) until the disruption controller has refreshed both budgets.
set -uo pipefail

for _ in $(seq 1 30); do
  scout="$(kubectl -n starfleet get pdb scout-pdb -o jsonpath='{.status.disruptionsAllowed}' 2>/dev/null || true)"
  probe="$(kubectl -n starfleet get pdb probe-pdb -o jsonpath='{.status.expectedPods}' 2>/dev/null || true)"
  if [ "$scout" = "1" ] && [ "$probe" = "2" ]; then
    break
  fi
  sleep 2
done
echo "[test] Budgets refreshed."
