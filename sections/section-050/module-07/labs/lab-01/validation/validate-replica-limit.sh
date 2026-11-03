#!/usr/bin/env bash
# Check: the replica limit is enforced in starfleet and only there.
set -uo pipefail
# Helper: print a Deployment manifest. Arguments: namespace, replicas, labels line (may be empty).
deployment_yaml() {
  cat <<YAML
apiVersion: apps/v1
kind: Deployment
metadata:
  name: grader-check
  namespace: $1
  $3
spec:
  replicas: $2
  selector:
    matchLabels: {app: grader-check}
  template:
    metadata:
      labels: {app: grader-check}
    spec:
      containers:
        - name: c
          image: docker.io/library/busybox:1.37.0
          command: ["sleep", "60"]
YAML
}
# Try the dry run up to 10 times while the policy becomes active. Prints the last output.
# Arguments: expect (reject or accept), namespace, replicas, labels line.
dry_run_expect() {
  local expect="$1" out code i
  for i in $(seq 1 10); do
    out="$(deployment_yaml "$2" "$3" "$4" | kubectl create --dry-run=server -f - 2>&1)"; code=$?
    if [ "$expect" = "reject" ] && [ "$code" -ne 0 ]; then echo "$out"; return 0; fi
    if [ "$expect" = "accept" ] && [ "$code" -eq 0 ]; then echo "$out"; return 0; fi
    sleep 2
  done
  echo "$out"; return 1
}
fail=0
out="$(dry_run_expect reject starfleet 5 'labels: {team: x}')" || { echo "FAIL: 5 replicas were accepted in starfleet"; fail=1; }
if [ "$fail" -eq 0 ] && ! grep -q "replica-limit" <<<"$out"; then echo "FAIL: the rejection does not come from the policy replica-limit"; fail=1; fi
dry_run_expect accept outpost 5 'labels: {team: x}' >/dev/null || { echo "FAIL: 5 replicas were rejected in outpost; the binding must select starfleet only"; fail=1; }
dry_run_expect accept starfleet 2 'labels: {team: x}' >/dev/null || { echo "FAIL: 2 replicas with a team label were rejected in starfleet"; fail=1; }
[ "$fail" -eq 0 ] && echo "PASS: the replica limit is enforced in starfleet only"
exit "$fail"
