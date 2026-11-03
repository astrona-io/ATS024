#!/usr/bin/env bash
# Applies the reference solution. Run only by `astrona test`.
set -euo pipefail

kubectl -n starfleet patch deployment scout --type=json -p='[
  {"op":"replace","path":"/spec/template/spec/containers/0/readinessProbe/httpGet/port","value":"http"},
  {"op":"add","path":"/spec/template/spec/topologySpreadConstraints","value":[
    {"maxSkew":1,"topologyKey":"kubernetes.io/hostname","whenUnsatisfiable":"ScheduleAnyway","labelSelector":{"matchLabels":{"app":"scout"}}}]}
]'

kubectl -n starfleet patch pdb scout --type=merge -p '{"spec":{"minAvailable":null,"maxUnavailable":1}}'

kubectl -n starfleet patch deployment bridge --type=json -p='[
  {"op":"add","path":"/spec/template/spec/initContainers","value":[
    {"name":"prepare-config","image":"docker.io/library/busybox:1.37.0","command":["sh","-c","touch /work/config.ready"],"volumeMounts":[{"name":"work","mountPath":"/work"}]}]}
]'

kubectl -n starfleet patch cronjob sweep --type=merge -p '{"spec":{"concurrencyPolicy":"Forbid","successfulJobsHistoryLimit":1,"failedJobsHistoryLimit":1,"jobTemplate":{"spec":{"ttlSecondsAfterFinished":120}}}}'

kubectl -n starfleet rollout status deployment/scout --timeout=180s
kubectl -n starfleet rollout status deployment/bridge --timeout=180s
echo "[solution] Applied."
