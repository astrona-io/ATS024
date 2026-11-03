#!/usr/bin/env bash
# Check: every bridge replica is ready and no bridge container waits in CrashLoopBackOff.
set -uo pipefail

fail=0
for i in $(seq 1 30); do
  desired="$(kubectl -n starfleet get deployment bridge -o jsonpath='{.spec.replicas}' 2>/dev/null || true)"
  ready="$(kubectl -n starfleet get deployment bridge -o jsonpath='{.status.readyReplicas}' 2>/dev/null || true)"
  if [ -n "$desired" ] && [ "${ready:-0}" = "$desired" ]; then
    break
  fi
  sleep 2
done

if [ -z "${desired:-}" ]; then
  echo "FAIL: the bridge Deployment does not exist"
  exit 1
fi
if [ "${desired}" -lt 2 ]; then
  echo "FAIL: bridge has fewer than 2 replicas ($desired)"
  fail=1
fi
if [ "${ready:-0}" != "$desired" ]; then
  echo "FAIL: bridge has ${ready:-0} of $desired replicas ready"
  fail=1
fi

reasons="$(kubectl -n starfleet get pods -l app=bridge -o jsonpath='{range .items[*]}{.status.containerStatuses[*].state.waiting.reason}{"\n"}{end}' 2>/dev/null || true)"
if echo "$reasons" | grep -q "CrashLoopBackOff"; then
  echo "FAIL: a bridge container is still in CrashLoopBackOff"
  fail=1
fi

if [ "$fail" -eq 0 ]; then
  echo "PASS: bridge has $ready of $desired replicas ready"
fi
exit "$fail"
