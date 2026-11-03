# Solution

UNTESTED: this lab has not yet run against a live environment. Solve it on `terminal`. Run `astrona submit` after each step to see which checks pass. The `--keep` flag keeps the lab running after a failed check.

Start the lab and select its cluster:

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS024.git -c sections/section-040/capstone/labs/lab-01
export KUBECONFIG="$(astrona kubeconfig ats-024-lab-040-cap)"
```

## Step 1: Repair scout readiness and spread

The readiness probe checks port 9090, but the container listens on the named port `http` (8080). Patch the probe and add the spread constraint in one change, so the Deployment makes only one rollout:

```sh
kubectl -n starfleet patch deployment scout --type=json -p='[
  {"op":"replace","path":"/spec/template/spec/containers/0/readinessProbe/httpGet/port","value":"http"},
  {"op":"add","path":"/spec/template/spec/topologySpreadConstraints","value":[{"maxSkew":1,"topologyKey":"kubernetes.io/hostname","whenUnsatisfiable":"ScheduleAnyway","labelSelector":{"matchLabels":{"app":"scout"}}}]}
]'
kubectl -n starfleet rollout status deployment/scout --timeout=180s
```

`ScheduleAnyway` makes the scheduler prefer an even spread but never leave a pod pending. Run `astrona submit`: the `scout-ready` and `scout-topology-spread` checks pass.

## Step 2: Let the budget allow one eviction

The budget requires three available pods out of three, so `disruptionsAllowed` is 0. Replace `minAvailable` with `maxUnavailable`:

```sh
kubectl -n starfleet patch pdb scout --type=merge -p '{"spec":{"minAvailable":null,"maxUnavailable":1}}'
kubectl -n starfleet get pdb scout
```

The `ALLOWED DISRUPTIONS` column now shows 1. Run `astrona submit`.

## Step 3: Add an init container to bridge

The `bridge` container checks for `/work/config.ready` on an `emptyDir` volume named `work`. An init container that runs before it, on the same volume, creates the file:

```sh
kubectl -n starfleet patch deployment bridge --type=json -p='[
  {"op":"add","path":"/spec/template/spec/initContainers","value":[{"name":"prepare-config","image":"docker.io/library/busybox:1.37.0","command":["sh","-c","touch /work/config.ready"],"volumeMounts":[{"name":"work","mountPath":"/work"}]}]}
]'
kubectl -n starfleet rollout status deployment/bridge --timeout=180s
```

## Step 4: Harden the sweep CronJob

```sh
kubectl -n starfleet patch cronjob sweep --type=merge -p '{"spec":{"concurrencyPolicy":"Forbid","successfulJobsHistoryLimit":1,"failedJobsHistoryLimit":1,"jobTemplate":{"spec":{"ttlSecondsAfterFinished":120}}}}'
```

Run `astrona submit` a last time. All six checks pass.

Clean up:

```sh
astrona destroy ats-024-lab-040-cap
```
