---
draft: true
exam_objectives:
- Configure Pod admission and scheduling (limits, node affinity, etc.)
---
# Repair An Impossible Node Selector Solution

Use a host shell with this lab's private kubeconfig. A kubeconfig identifies the cluster and credentials used by kubectl, the Kubernetes command-line tool. This environment is separate from the ungraded playground.

```sh
export KUBECONFIG="$(astrona kubeconfig ats-024-lab-050-01-01)"
test "$(kubectl config current-context)" = "kind-astro-ats-024-lab-050-01-01" || exit 1
```

Keep this connection selected throughout the task. Every script supplied by the lab refuses a different context.

## Inspect And Explain

The Deployment template selects a node label that no node has. Replacement Pods cannot schedule, while older replicas may still respond.

Inspect the relevant evidence:

```sh
kubectl get nodes --show-labels
kubectl -n starfleet describe pods -l app=probe
```

The scheduler chooses nodes that satisfy the Pod constraints. An image or application change cannot fix an impossible node selector. Compare the template selector with real node labels, then restore a satisfiable rule. Checking the current generation prevents healthy older replicas from hiding the fault.


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
          value: v1
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
      nodeSelector:
        kubernetes.io/os: linux
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

Replace the impossible node selector on `probe` with `kubernetes.io/os: linux`. Keep two replicas, the application command, image, resources and readiness probe. The current generation must fully roll out and the original client must receive version one. Do not label a node to satisfy the intentional missing selector.

After recording the result, remove this independent lab with `astrona destroy ats-024-lab-050-01-01`.

## Common pitfalls

> [!WARNING]
> Compare the selector with real node labels. Healthy older replicas do not prove the new template scheduled. Do not label a node to disguise the intentional constraint error.
