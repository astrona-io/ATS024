#!/usr/bin/env bash
# Check: a Deployment without a team label is rejected in starfleet by the policy require-team-label.
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
out="$(dry_run_expect reject starfleet 1 '')" || { echo "FAIL: a Deployment without a team label was accepted in starfleet"; fail=1; }
if [ "$fail" -eq 0 ] && ! grep -q "require-team-label" <<<"$out"; then echo "FAIL: the rejection does not come from the policy require-team-label"; fail=1; fi
dry_run_expect accept outpost 1 '' >/dev/null || { echo "FAIL: the rule must apply to starfleet only"; fail=1; }
[ "$fail" -eq 0 ] && echo "PASS: the team label is required in starfleet"
exit "$fail"
