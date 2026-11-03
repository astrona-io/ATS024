---
draft: true
exam_objectives:
- Understand the primitives used to create robust, self-healing, application deployments
---
# Solution

Solve this lab on `terminal`. Each step ends with `astrona submit`. The `--keep` flag keeps the lab running so you can continue after a failed check. Outputs below are described in words, not copied from a run.

Start the lab if it is not running, then point `kubectl` at it:

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS024.git -c sections/section-040/module-03/labs/lab-01
export KUBECONFIG="$(astrona kubeconfig ats-024-lab-040-03-01)"
```

## Step 1: Read the failure of bridge

List the Pods and read the log of the previous run of one `bridge` Pod:

```sh
kubectl -n starfleet get pods -l app=bridge
kubectl -n starfleet logs deployment/bridge --previous
```

The Pods show `CrashLoopBackOff`. The log line says that `/work/config.txt` is missing. The container exits with code 1, and the kubelet restarts it with a growing delay. A restart cannot create the file, so the Deployment never recovers by itself.

## Step 2: Add an init container that writes the file

An init container runs to completion before the main containers start. It can write into the same `emptyDir` volume. Save this as `bridge-init-patch.yaml`:

```yaml
spec:
  template:
    spec:
      initContainers:
        - name: write-config
          image: docker.io/library/busybox:1.37.0
          command: ["sh", "-c", "echo mode=survey > /work/config.txt"]
          volumeMounts:
            - name: work
              mountPath: /work
```

Apply it as a strategic merge patch and wait for the rollout:

```sh
kubectl -n starfleet patch deployment bridge --type=strategic --patch-file bridge-init-patch.yaml
kubectl -n starfleet rollout status deployment/bridge --timeout=120s
```

The patch changes the Pod template, so the Deployment controller starts a rolling update. Each new Pod runs `write-config`, then the `bridge` container finds the file and keeps running. Submit to check:

```sh
astrona submit --git ssh://git@github.com/astrona-io/ATS024.git -c sections/section-040/module-03/labs/lab-01 --keep
```

The init container checks, the availability check and the main container check pass.

## Step 3: Recreate drifter-survey with a restart policy that fits a task

`restartPolicy` of a Pod cannot be changed in place, so the Pod must be deleted and created again. Save this as `pod-drifter-survey.yaml`:

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: drifter-survey
  namespace: outpost
spec:
  restartPolicy: OnFailure
  containers:
    - name: survey
      image: docker.io/library/busybox:1.37.0
      command: ["sh", "-c", "echo survey-complete"]
```

Delete the old Pod, apply the new one and read its phase:

```sh
kubectl -n outpost delete pod drifter-survey
kubectl apply -f pod-drifter-survey.yaml
kubectl -n outpost get pod drifter-survey -o jsonpath='{.status.phase}{"\n"}'
```

With `OnFailure` the kubelet restarts the container only after a non-zero exit. The container exits with code 0, so the phase becomes `Succeeded`. If the command prints `Pending` or `Running`, run it again after a few seconds. `Never` also passes the check.

## Step 4: Submit

```sh
astrona submit --git ssh://git@github.com/astrona-io/ATS024.git -c sections/section-040/module-03/labs/lab-01
astrona destroy ats-024-lab-040-03-01
```

All five checks pass. A fix that removes the check for `/work/config.txt` or replaces the `bridge` container fails the check that keeps the main container.
