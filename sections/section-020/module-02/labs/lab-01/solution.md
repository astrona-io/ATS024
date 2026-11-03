---
draft: true
exam_objectives:
- Use ConfigMaps and Secrets to configure applications
---
# Solution

UNTESTED: not yet run against a live environment.

Solve this lab on `terminal`. Each step ends with `astrona submit`, which shows which checks pass. Start the lab if it is not running, and select its kubeconfig:

```sh
export KUBECONFIG="$(astrona kubeconfig ats-024-lab-020-02-01)"
test "$(kubectl config current-context)" = "kind-astro-ats-024-lab-020-02-01" || exit 1
```

## Step 1: Look at the Deployment

The container has two `env` entries with literal values. Read them and the objects they should come from:

```sh
kubectl -n starfleet get deployment scout -o yaml
kubectl -n starfleet get configmap scout-settings -o yaml
kubectl -n starfleet get secret scout-db
```

The ConfigMap has three keys, and the Secret has the key `password`. All checks fail now because the Deployment has no references.

## Step 2: Replace the environment

The simplest way is to apply a corrected manifest to the same Deployment. The Deployment was created with `kubectl apply`, so the apply removes the old literal `LOG_LEVEL` entry and updates `DB_PASSWORD`. Save this as `deployment-scout.yaml`:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: scout
  namespace: starfleet
spec:
  replicas: 2
  selector:
    matchLabels:
      app: scout
  template:
    metadata:
      labels:
        app: scout
    spec:
      containers:
      - name: scout
        image: docker.io/library/busybox:1.37.0
        command:
        - sh
        - -c
        - sleep 3600
        env:
        - name: APP_MODE
          valueFrom:
            configMapKeyRef:
              name: scout-settings
              key: mode
        - name: DB_PASSWORD
          valueFrom:
            secretKeyRef:
              name: scout-db
              key: password
        envFrom:
        - configMapRef:
            name: scout-settings
          prefix: SCOUT_
```

Apply the file:

```sh
kubectl apply -f deployment-scout.yaml
kubectl -n starfleet rollout status deployment/scout --timeout=180s
```

## Step 3: Check the environment

```sh
kubectl -n starfleet exec deploy/scout -- printenv SCOUT_LOG_LEVEL SCOUT_REGION APP_MODE
```

The three values are `info`, `alpha` and `standby`. Check the password without printing it:

```sh
kubectl -n starfleet exec deploy/scout -- sh -c 'test -n "$DB_PASSWORD" && echo set'
```

The command prints `set`. Grade it:

```sh
astrona submit -c .
```

All four checks pass. Remove the lab with `astrona destroy ats-024-lab-020-02-01`.

## Common pitfalls

> [!WARNING]
> A literal `value` next to a `valueFrom` in one `env` entry is rejected by the API server, so use one or the other. Do not delete the Deployment: the grader compares its identity. Do not print the password.
