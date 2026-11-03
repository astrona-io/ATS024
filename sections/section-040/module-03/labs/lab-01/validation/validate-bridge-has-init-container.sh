#!/usr/bin/env bash
# Check: the bridge Deployment has a run-to-completion init container that
# mounts the work volume, and its Pods show that it finished with exit code 0.
set -uo pipefail

fail=0
names="$(kubectl -n starfleet get deployment bridge -o jsonpath='{.spec.template.spec.initContainers[*].name}' 2>/dev/null || true)"
if [ -z "$names" ]; then
  echo "FAIL: the bridge Deployment has no init container"
  exit 1
fi

policies="$(kubectl -n starfleet get deployment bridge -o jsonpath='{range .spec.template.spec.initContainers[*]}{.restartPolicy}{"\n"}{end}' 2>/dev/null || true)"
if echo "$policies" | grep -qx "Always"; then
  echo "FAIL: an init container has restartPolicy Always (a native sidecar); the task needs a run-to-completion init container"
  fail=1
fi

mounts="$(kubectl -n starfleet get deployment bridge -o jsonpath='{range .spec.template.spec.initContainers[*]}{range .volumeMounts[*]}{.name}{"\n"}{end}{end}' 2>/dev/null || true)"
if ! echo "$mounts" | grep -qx "work"; then
  echo "FAIL: no init container mounts the work volume"
  fail=1
fi

codes="$(kubectl -n starfleet get pods -l app=bridge -o jsonpath='{range .items[*]}{.status.initContainerStatuses[*].state.terminated.exitCode}{"\n"}{end}' 2>/dev/null | grep -v '^$' || true)"
if [ -z "$codes" ] || echo "$codes" | grep -qv '^0$'; then
  echo "FAIL: not every bridge Pod shows an init container that finished with exit code 0"
  fail=1
fi

if [ "$fail" -eq 0 ]; then
  echo "PASS: bridge uses a run-to-completion init container that finished successfully"
fi
exit "$fail"
