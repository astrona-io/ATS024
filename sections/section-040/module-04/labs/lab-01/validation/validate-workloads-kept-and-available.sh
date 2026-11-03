#!/usr/bin/env bash
# Check: the fix did not take a shortcut. The seeded objects still exist (they
# keep the seed annotation), scout still has 3 ready replicas and probe 2.
set -uo pipefail

fail=0

for object in deployment/scout deployment/probe pdb/scout-pdb pdb/probe-pdb; do
  seeded="$(kubectl -n starfleet get "$object" -o jsonpath='{.metadata.annotations.lab\.astrona\.io/seeded}' 2>/dev/null || true)"
  if [ "$seeded" != "true" ]; then
    echo "FAIL: $object is missing or was deleted and recreated"
    fail=1
  fi
done

for pair in scout:3 probe:2; do
  name="${pair%%:*}"
  want="${pair##*:}"
  for _ in $(seq 1 30); do
    ready="$(kubectl -n starfleet get deployment "$name" -o jsonpath='{.status.readyReplicas}' 2>/dev/null || true)"
    [ "${ready:-0}" = "$want" ] && break
    sleep 2
  done
  replicas="$(kubectl -n starfleet get deployment "$name" -o jsonpath='{.spec.replicas}' 2>/dev/null || true)"
  ready="$(kubectl -n starfleet get deployment "$name" -o jsonpath='{.status.readyReplicas}' 2>/dev/null || true)"
  if [ "$replicas" != "$want" ] || [ "${ready:-0}" != "$want" ]; then
    echo "FAIL: $name has replicas=$replicas readyReplicas=${ready:-0}, expected $want"
    fail=1
  fi
done

if [ "$fail" -eq 0 ]; then
  echo "PASS: scout and probe and both budgets are kept and available"
fi
exit "$fail"
