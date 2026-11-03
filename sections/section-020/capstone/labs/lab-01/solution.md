---
draft: true
exam_objectives:
- Use ConfigMaps and Secrets to configure applications
---
# Solution

UNTESTED: not yet run against a live environment.

Solve this lab on `terminal`. Each step ends with `astrona submit`, which shows which checks pass. Start the lab if it is not running, and select its kubeconfig:

```sh
export KUBECONFIG="$(astrona kubeconfig ats-024-lab-020-cap)"
test "$(kubectl config current-context)" = "kind-astro-ats-024-lab-020-cap" || exit 1
```

## Step 1: Look at the starting state

```sh
kubectl -n outpost get deployment beacon -o yaml
kubectl -n outpost get secret registry-creds
kubectl -n outpost get serviceaccount beacon -o yaml
```

The container has two literal variables and no volume. The Secret has the type `Opaque`, and the ServiceAccount has no `imagePullSecrets`. All checks fail now.

## Step 2: Fix the registry credentials

The type of a Secret cannot change, so delete the Secret and create it again. Then add it to the ServiceAccount. The ServiceAccount admission controller copies the list into each new Pod, so the Pod template stays as it is:

```sh
kubectl -n outpost delete secret registry-creds
kubectl -n outpost create secret docker-registry registry-creds \
  --docker-server=registry.starfleet.example \
  --docker-username=beacon \
  --docker-password=disposable-pass
kubectl -n outpost patch serviceaccount beacon -p '{"imagePullSecrets":[{"name":"registry-creds"}]}'
```

Run `astrona submit`. The check `registry-credentials` should pass.

## Step 3: Make the ConfigMap immutable

Changing the `immutable` field to true is allowed on an existing object. Afterwards the data cannot change any more:

```sh
kubectl -n outpost patch configmap beacon-settings --type merge -p '{"immutable":true}'
```

Run `astrona submit`. The check `settings-immutable` should pass.

## Step 4: Rewrite the Pod template

One manifest covers the environment, the downward API variable and the projected volume. The `envFrom` entry carries the prefix, `DB_PASSWORD` uses `secretKeyRef`, and the volume has three sources. Save this as `deployment-beacon.yaml`:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: beacon
  namespace: outpost
spec:
  replicas: 2
  selector:
    matchLabels:
      app: beacon
  template:
    metadata:
      labels:
        app: beacon
    spec:
      serviceAccountName: beacon
      containers:
      - name: beacon
        image: docker.io/library/busybox:1.37.0
        command:
        - sh
        - -c
        - sleep 3600
        envFrom:
        - configMapRef:
            name: beacon-settings
          prefix: BEACON_
        env:
        - name: DB_PASSWORD
          valueFrom:
            secretKeyRef:
              name: beacon-db
              key: password
        - name: POD_NAMESPACE
          valueFrom:
            fieldRef:
              fieldPath: metadata.namespace
        volumeMounts:
        - name: beacon-files
          mountPath: /etc/beacon
          readOnly: true
      volumes:
      - name: beacon-files
        projected:
          sources:
          - configMap:
              name: beacon-settings
              items:
              - key: banner
                path: banner.txt
          - secret:
              name: beacon-db
              items:
              - key: password
                path: secrets/db-password
                mode: 0400
          - downwardAPI:
              items:
              - path: pod/labels
                fieldRef:
                  fieldPath: metadata.labels
```

Apply it:

```sh
kubectl apply -f deployment-beacon.yaml
```

Then check the result:

```sh
kubectl -n outpost rollout status deployment/beacon --timeout=120s
```

Run `astrona submit`. All five checks should pass.
