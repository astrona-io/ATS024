---
draft: true
exam_objectives:
- Use ConfigMaps and Secrets to configure applications
---
# Solution

UNTESTED: not yet run against a live environment.

Solve this lab on `terminal`. Each step ends with `astrona submit`, which shows which checks pass. Start the lab if it is not running, and select its kubeconfig:

```sh
export KUBECONFIG="$(astrona kubeconfig ats-024-lab-020-04-01)"
test "$(kubectl config current-context)" = "kind-astro-ats-024-lab-020-04-01" || exit 1
```

## Step 1: Look at the Deployment

```sh
kubectl -n starfleet get deployment shuttle -o yaml
kubectl -n starfleet get configmap shuttle-config -o yaml
```

The container has a CPU limit of `500m`, no volume, and two literal variables. All checks fail now.

## Step 2: Replace the Pod template

Apply a full manifest to the same Deployment. The edit keeps the identity of the object, so the `same-deployment` check can pass. The projected volume has three sources, and the token item has its own `mode`. Save this as `deployment-shuttle.yaml`:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: shuttle
  namespace: starfleet
spec:
  replicas: 2
  selector:
    matchLabels:
      app: shuttle
  template:
    metadata:
      labels:
        app: shuttle
    spec:
      containers:
      - name: shuttle
        image: docker.io/library/busybox:1.37.0
        command:
        - sh
        - -c
        - sleep 3600
        resources:
          requests:
            cpu: 100m
            memory: 64Mi
          limits:
            cpu: 500m
            memory: 128Mi
        env:
        - name: POD_NAME
          valueFrom:
            fieldRef:
              fieldPath: metadata.name
        - name: CPU_MILLI
          valueFrom:
            resourceFieldRef:
              resource: limits.cpu
              divisor: 1m
        volumeMounts:
        - name: shuttle-files
          mountPath: /etc/shuttle
          readOnly: true
      volumes:
      - name: shuttle-files
        projected:
          sources:
          - configMap:
              name: shuttle-config
              items:
              - key: flags
                path: flags.conf
          - secret:
              name: shuttle-token
              items:
              - key: token
                path: secrets/token
                mode: 0400
          - downwardAPI:
              items:
              - path: pod/labels
                fieldRef:
                  fieldPath: metadata.labels
```

Apply it:

```sh
kubectl apply -f deployment-shuttle.yaml
```

Then check the result:

```sh
kubectl -n starfleet rollout status deployment/shuttle --timeout=120s
```

The two literal `value` fields are replaced by references in the same step. Run `astrona submit`. All four checks should pass.

## Step 3: Check the content yourself

```sh
pod="$(kubectl -n starfleet get pods -l app=shuttle -o jsonpath='{.items[0].metadata.name}')"
kubectl -n starfleet exec "$pod" -- printenv POD_NAME CPU_MILLI
kubectl -n starfleet exec "$pod" -- cat /etc/shuttle/flags.conf /etc/shuttle/pod/labels
```

The Pod name appears, then `500`. The settings file shows the two lines of the ConfigMap, and the labels file shows `app="shuttle"`. Do not print `/etc/shuttle/secrets/token` in a shared terminal.
