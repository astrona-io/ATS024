# Solution

Solve this lab on `terminal`. Each step ends with `astrona submit`. The `--keep` flag keeps the lab running so you can continue after a failed check. This lab has not been run against a live cluster, so the walkthrough describes results in words.

Start the lab if it is not running:

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS024.git -c sections/section-040/module-02/labs/lab-01
export KUBECONFIG="$(astrona kubeconfig ats-024-lab-040-02-01)"
```

Run `astrona submit` once before you change anything. Six of the seven checks fail, because the Job is failed and the CronJob has the wrong settings. Only `scan-report-task-kept` passes, because the task is still the original one.

## Step 1: Find out why the Job failed

Look at the Job and its Pod:

```sh
kubectl -n starfleet get job scan-report -o jsonpath='{.spec.backoffLimit} {.spec.template.spec.restartPolicy}{"\n"}'
kubectl -n starfleet get pods -l job-name=scan-report
```

The Job has `backoffLimit: 0` and `restartPolicy: Never`. The task writes a marker file and exits with an error on the first attempt. With `Never`, a retry would be a new Pod with an empty `emptyDir`, so the marker would be gone. With `OnFailure`, the container restarts in the same Pod and finds the marker.

## Step 2: Recreate the Job with a retry and cleanup

The Pod template of a Job cannot be edited. Save this as `scan-report.yaml`:

```yaml
apiVersion: batch/v1
kind: Job
metadata:
  name: scan-report
  namespace: starfleet
spec:
  backoffLimit: 3
  ttlSecondsAfterFinished: 3600
  template:
    spec:
      restartPolicy: OnFailure
      volumes:
      - name: data
        emptyDir: {}
      containers:
      - name: scan
        image: docker.io/library/busybox:1.37.0
        command:
        - sh
        - -c
        - 'if [ -f /data/attempt ]; then echo scan finished; exit 0; fi; touch /data/attempt; echo first attempt fails; exit 1'
        volumeMounts:
        - name: data
          mountPath: /data
```

Delete the failed Job and apply the new one:

```sh
kubectl -n starfleet delete job scan-report
kubectl apply -f scan-report.yaml
```

Then wait for the Job to complete. The wait ends after the first retry, which can take about ten seconds:

```sh
kubectl -n starfleet wait --for=condition=complete job/scan-report --timeout=120s
astrona submit --git ssh://git@github.com/astrona-io/ATS024.git -c sections/section-040/module-02/labs/lab-01 --keep
```

The four `scan-report` checks now pass.

## Step 3: Repair the CronJob in place

A CronJob spec can be patched, so keep the original object. Apply the four changes with one patch:

```sh
kubectl -n starfleet patch cronjob fleet-report --type merge -p '{"spec":{"suspend":false,"concurrencyPolicy":"Forbid","startingDeadlineSeconds":120,"successfulJobsHistoryLimit":2,"failedJobsHistoryLimit":2}}'
```

Then check the fields:

```sh
kubectl -n starfleet get cronjob fleet-report -o jsonpath='{.spec.suspend} {.spec.concurrencyPolicy} {.spec.startingDeadlineSeconds}{"\n"}'
astrona submit --git ssh://git@github.com/astrona-io/ATS024.git -c sections/section-040/module-02/labs/lab-01
```

The command prints `false Forbid 120`, and all seven checks pass.

## Why the checks look the way they do

The `fleet-report-history-and-identity` check compares the CronJob uid with the one recorded at the start. A deleted and recreated CronJob has a new uid and fails. The `scan-report-task-kept` check fails if you replace the task with a command that cannot fail.

Clean up when you are done:

```sh
astrona destroy ats-024-lab-040-02-01
```
