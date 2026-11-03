---
draft: true
exam_objectives:
- Configure Pod admission and scheduling (limits, node affinity, etc.)
---
# Rolling Updates, matchLabelKeys And Domain Selection

During a rolling update the `probe` Deployment runs old and new Pods at the same time. A spread constraint that counts all Pods with `app: probe` mixes the two revisions, so the new Pods can end up unevenly spread once the old ones are gone. Kubernetes gives two fields to control what is counted and which nodes form domains.

This chapter covers `matchLabelKeys`, the node inclusion policies and `minDomains`, and ends with how to prove a spread result.

## matchLabelKeys

`matchLabelKeys` is a list of label keys inside a topology spread constraint. For each key, the scheduler reads the value from the incoming Pod's own labels and adds that pair to the `labelSelector`. Deployments add the label `pod-template-hash` to the Pods of each ReplicaSet, and the value is different for each revision. Listing `pod-template-hash` in `matchLabelKeys` means that a new Pod is counted only against Pods of its own revision.

The field exists on Pod affinity terms too, with `matchLabelKeys` and `mismatchLabelKeys`, for the same reason. Use the keys when the selector alone cannot tell the revisions apart.

<!-- astrona:playground:renew -->

Save this as `deployment-probe-revision.yaml`:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: probe
  namespace: starfleet
spec:
  replicas: 4
  selector:
    matchLabels:
      app: probe
  template:
    metadata:
      labels:
        app: probe
    spec:
      topologySpreadConstraints:
      - maxSkew: 1
        topologyKey: topology.kubernetes.io/zone
        whenUnsatisfiable: DoNotSchedule
        labelSelector:
          matchLabels:
            app: probe
        matchLabelKeys:
        - pod-template-hash
      containers:
      - name: probe
        image: docker.io/library/busybox:1.37.0
        command: ["sh", "-c", "sleep 3600"]
        resources:
          requests:
            cpu: 10m
            memory: 16Mi
```

Apply it and wait:

```sh
kubectl apply -f deployment-probe-revision.yaml
kubectl -n starfleet rollout status deployment/probe --timeout=120s
```

Each revision's Pods are now balanced on their own. When the rollout finishes, the new Pods are two in each zone.

## Which nodes are domains

By default the scheduler counts every node that has the topology label as a domain, even when the Pod cannot run there. Two fields change this. `nodeAffinityPolicy: Honor` (the default) ignores nodes that the Pod's node affinity or node selector excludes. `nodeTaintsPolicy: Ignore` (the default) keeps tainted nodes as domains, while `Honor` removes tainted nodes that the Pod does not tolerate.

The default matters with the hostname key. A kind cluster has a tainted control plane node that carries `kubernetes.io/hostname`. With `nodeTaintsPolicy: Ignore` it is a domain with zero Pods that can never take a Pod. The minimum is always zero, so with `maxSkew: 1` a worker can hold at most one Pod and the others stay Pending. Setting `nodeTaintsPolicy: Honor` removes the control plane node from the count.

Save this as `deployment-probe-hostname.yaml`, which spreads over nodes instead of zones:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: probe
  namespace: starfleet
spec:
  replicas: 4
  selector:
    matchLabels:
      app: probe
  template:
    metadata:
      labels:
        app: probe
    spec:
      topologySpreadConstraints:
      - maxSkew: 1
        topologyKey: kubernetes.io/hostname
        whenUnsatisfiable: DoNotSchedule
        nodeTaintsPolicy: Honor
        labelSelector:
          matchLabels:
            app: probe
      containers:
      - name: probe
        image: docker.io/library/busybox:1.37.0
        command: ["sh", "-c", "sleep 3600"]
```

Apply it and check the spread:

```sh
kubectl apply -f deployment-probe-hostname.yaml
kubectl -n starfleet get pods -l app=probe -o wide
```

Four Pods run, two on each worker. Remove the `nodeTaintsPolicy` line and the result changes, which is a good experiment for the playground.

## minDomains and proof

`minDomains` tells the scheduler how many domains the rule expects. While fewer domains exist, the global minimum is treated as zero, so a `maxSkew` of 1 allows at most one Pod per domain until more domains appear. It makes the hard rule safe for autoscaled clusters that start small.

To prove a spread result, list the Pods with `-o wide` and count by node, then read the zone label of each node with `kubectl get nodes -L topology.kubernetes.io/zone`. A constraint in the Pod spec proves intent. Only the placement proves the outcome.

You now know how the counts are scoped and how domains are chosen. The next step is to use these rules together with taints, requests and admission in one workload.

## Common pitfalls

> [!WARNING]
> Without `matchLabelKeys`, a rolling update counts old and new Pods together. With the hostname key and the default `nodeTaintsPolicy`, a tainted control plane node is a domain with zero Pods and can block placement. Check the placement with `-o wide`, not the manifest alone.
