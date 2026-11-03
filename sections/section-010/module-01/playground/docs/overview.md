---
draft: true
exam_objectives:
- Understand application deployments and how to perform rolling update and rollbacks
---
# Guided Practice: Perform A Rolling Template Update

Use a host shell with this lab's private kubeconfig. A kubeconfig identifies the cluster and credentials used by kubectl, the Kubernetes command-line tool. This environment is separate from the ungraded playground.

<!-- astrona:playground:renew -->

```sh
export KUBECONFIG="$(astrona kubeconfig ats-024-playground-010-01)"
test "$(kubectl config current-context)" = "kind-astro-ats-024-playground-010-01" || exit 1
```

Keep this connection selected throughout the task. Every script supplied by the lab refuses a different context.

## Inspect And Explain

The application and client fixtures are healthy. Complete the required change without replacing unrelated resources.

Inspect the relevant evidence:

```sh
kubectl -n starfleet get pods
kubectl -n starfleet get deployment probe -o yaml
```

Changing the Pod template starts a rollout. The Deployment controller may add one extra Pod, but the zero unavailability budget retains ready capacity while new Pods start. Current-generation status and the version returned by the Service establish different parts of the result.


Save this as `deployment-probe.yaml`:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: probe
  namespace: starfleet
spec:
  replicas: 2
  selector:
    matchLabels:
      app: probe
      release: probe
  template:
    metadata:
      labels:
        app: probe
        release: probe
    spec:
      containers:
      - name: probe
        image: docker.io/library/python:3.13-alpine
        command:
        - python
        - /app/server.py
        env:
        - name: VERSION
          value: v2
        ports:
        - name: http
          containerPort: 8080
        readinessProbe:
          httpGet:
            path: /ready
            port: http
          periodSeconds: 2
        resources:
          requests:
            cpu: 10m
            memory: 32Mi
          limits:
            memory: 128Mi
        volumeMounts:
        - name: app
          mountPath: /app
          readOnly: true
      volumes:
      - name: app
        configMap:
          name: probe-code
  strategy:
    type: RollingUpdate
    rollingUpdate:
      maxSurge: 1
      maxUnavailable: 0
```

Apply the required change:

```sh
kubectl apply -f deployment-probe.yaml
```

## Verify The Result

Observe the actual result. A denied-request command returns a nonzero status when the denial works. Run denial checks separately from a shell sequence that stops on the first nonzero status.

```sh
kubectl -n starfleet rollout status deployment/probe --timeout=180s
kubectl -n starfleet exec shuttle -- wget -q -T 3 -O- http://probe/
```

Update `probe` to version `v2` through its `VERSION` environment value. Keep two replicas, a RollingUpdate strategy with `maxSurge: 1` and `maxUnavailable: 0`, and the readiness probe. The current generation must have two updated, ready and available replicas. The client must receive version two.


## Common pitfalls

> [!WARNING]
> A working older replica can hide an incomplete rollout. Check the observed generation and updated replica count. Removing readiness changes the availability contract.
