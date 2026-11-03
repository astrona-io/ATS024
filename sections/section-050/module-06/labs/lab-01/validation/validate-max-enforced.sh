#!/usr/bin/env bash
# Check: admission rejects a container above the maximum and accepts a valid one.
set -uo pipefail
fail=0
pod() { cat <<YAML
apiVersion: v1
kind: Pod
metadata:
  name: grader-$1
  namespace: outpost
spec:
  containers:
    - name: c
      image: docker.io/library/busybox:1.37.0
      command: ["sleep", "60"]
      resources:
        requests: {cpu: 100m, memory: 64Mi}
        limits: {cpu: "$2", memory: 128Mi}
YAML
}
out="$(pod big 1 | kubectl create --dry-run=server -f - 2>&1)"; code=$?
if [ "$code" -eq 0 ] || ! grep -q "maximum cpu usage per Container" <<<"$out"; then
  echo "FAIL: a container with cpu limit 1 was not rejected by the LimitRange maximum"; fail=1
fi
if ! pod ok 200m | kubectl create --dry-run=server -f - >/dev/null 2>&1; then
  echo "FAIL: a valid container was rejected"; fail=1
fi
[ "$fail" -eq 0 ] && echo "PASS: the maximum is enforced and valid pods are accepted"
exit "$fail"
