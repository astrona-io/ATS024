#!/usr/bin/env bash
# Check: builder lists registry-creds and the admission controller copies it into a new Pod.
set -uo pipefail
if [[ "$(kubectl config current-context)" != "kind-astro-ats-024-lab-020-03-01" ]]; then
  echo "FAIL: wrong Kubernetes context"
  exit 1
fi
fail=0
list="$(kubectl -n starfleet get serviceaccount builder -o jsonpath='{.imagePullSecrets[*].name}' 2>/dev/null || true)"
case " $list " in
  *" registry-creds "*) ;;
  *) echo "FAIL: ServiceAccount builder does not list registry-creds"; exit 1 ;;
esac
injected="$(kubectl -n starfleet run grader-check --image=docker.io/library/busybox:1.37.0 --overrides='{"spec":{"serviceAccountName":"builder"}}' --dry-run=server -o jsonpath='{.spec.imagePullSecrets[*].name}' 2>/dev/null || true)"
if [ "$injected" != "registry-creds" ]; then
  echo "FAIL: a new Pod running as builder does not receive registry-creds"
  fail=1
fi
[ "$fail" -eq 0 ] && echo "PASS: builder carries registry-creds"
exit "$fail"
