#!/usr/bin/env bash
# Check: drifter-survey finished its task once and ended in phase Succeeded
# (not Running, not restarted over and over).
set -uo pipefail

phase=""
for i in $(seq 1 30); do
  phase="$(kubectl -n outpost get pod drifter-survey -o jsonpath='{.status.phase}' 2>/dev/null || true)"
  if [ "$phase" = "Succeeded" ]; then
    break
  fi
  sleep 2
done

if [ "$phase" != "Succeeded" ]; then
  echo "FAIL: drifter-survey is in phase '${phase:-missing}', expected Succeeded"
  exit 1
fi

restarts="$(kubectl -n outpost get pod drifter-survey -o jsonpath='{.status.containerStatuses[0].restartCount}' 2>/dev/null || true)"
if [ "${restarts:-0}" != "0" ]; then
  echo "FAIL: the survey container restarted $restarts times"
  exit 1
fi

echo "PASS: drifter-survey ended in phase Succeeded without a restart"
exit 0
