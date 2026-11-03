---
draft: true
exam_objectives:
- Configure Pod admission and scheduling (limits, node affinity, etc.)
---
# Filtering, Scoring And Placement Rules

A Pod needs an accelerator, but the only idle node lacks its required label. Free CPU does not make that node eligible. Scheduling first satisfies mandatory requirements, then evaluates preferences.

## Learning objectives

- Explain scheduling filters and preferences.
- Compare required and preferred affinity.
- Interpret taints and tolerations.

## Before you start

You need `kubectl` and the module playground, a kind cluster with one control plane node and one worker node. A Pod is the Kubernetes unit for running one or more containers, and a namespace groups namespaced objects. The commands in this chapter create their own small objects, so they work whatever the playground already contains.

## Responsible components and behavior

The `scout` Pod requires a node with an attached accelerator. The scheduler cannot pick any idle machine. It examines unscheduled Pods and first filters out nodes that fail mandatory requirements. It then scores eligible nodes according to configured preferences and selects a suitable node.

A node selector requires matching node labels. Node affinity expresses richer conditions and can distinguish required rules from preferred rules. Required affinity removes unsuitable nodes from consideration. Preferred affinity influences scores but allows placement elsewhere when the preference cannot be satisfied.

Pod affinity and anti-affinity describe placement relative to other Pods. Affinity can keep related workloads near each other; anti-affinity can separate replicas. A topology domain is a grouping such as a node or availability zone, identified through node labels. The rule's topology key determines what “near” or “separate” means.

Topology spread constraints control how Pods are distributed across eligible topology domains. They can help keep all application replicas from concentrating in one failure domain. Required spreading and anti-affinity can also leave Pods Pending when the available cluster cannot satisfy them. A desired availability pattern still needs enough suitable nodes.

The scheduler normally chooses a node once for a Pod. It does not continuously move the running Pod to a better-scoring node whenever circumstances change. A replacement Pod can receive a new assignment. Placement rules also do not guarantee that external storage or network dependencies are available.

Suppose three nodes have ample CPU but none has the required accelerator label. Adding replicas or reducing the image size will not solve the mandatory label mismatch. Identify each hard constraint before considering preferences or runtime symptoms.

## Working Through Required And Preferred Rules

Assume the cluster has three nodes. Node A has an accelerator label and enough requested capacity. Node B has capacity but no accelerator label. Node C has the label but lacks enough available requested CPU. A Pod requiring the accelerator label and sufficient CPU can use A; B and C fail different mandatory checks.

Adding a preference for zone B does not make node B eligible if it still lacks the required label. Preferences rank the nodes that survive filtering. If only A survives, a preference cannot manufacture another valid candidate. If no node survives, the Pod remains unassigned even when some nodes score well on an irrelevant preference.

A node affinity requirement acts on node labels. A Pod affinity requirement acts on the location of other Pods selected by their labels, interpreted through a topology key. These are different inputs. Wanting a database and client in the same zone is not the same as wanting the client on a node with a particular disk label.

## Availability Versus Placement Flexibility

Hard anti-affinity can require replicas to occupy separate nodes. That supports resilience against one node loss but also requires enough eligible nodes. If the application asks for four replicas and only three nodes satisfy the other constraints, the fourth can remain Pending. Relaxing the rule changes the availability contract, so it is a design decision rather than a harmless workaround.

Topology spread constraints offer a way to express distribution across domains and a tolerated imbalance. Their behavior still depends on available domains and whether the rule permits scheduling when its desired balance cannot be met. The important associate-level concept is that distribution is an explicit constraint or preference, not an automatic consequence of increasing replica count.

Evaluate placement by listing the hard filters first, then the preferences among eligible nodes. Include resources and storage topology alongside labels. This makes it possible to explain why a seemingly idle cluster still cannot place a particular workload.

## Work through the decision

Required node affinity and selectors remove non-matching nodes from consideration. Preferred affinity influences scores among feasible choices without making the preference mandatory. Pod affinity and anti-affinity instead relate placement to other Pods under a declared topology key.

Consider a preferred separation across zones with all replicas still able to fit one zone. That is different from a required separation that makes an additional replica unschedulable when no other eligible domain exists. Review node labels, existing Pod placement and resource demand together. Changing a required hardware constraint to force placement can violate the application requirement even when the status becomes Running.

```mermaid
flowchart TB
    N0["Pod mandatory requirements"]
    N1["Feasible node filtering"]
    N2["Preference scoring"]
    N3["Node assignment"]
    N4["Kubelet execution"]
    N0 --> N1
    N1 --> N2
    N2 --> N3
    N3 --> N4
```

A placement fix must preserve the requirement that made a node suitable, rather than merely produce an assignment.

## Watch the filter phase work

The scheduler is the control plane component that assigns every new Pod to a node. It runs two phases for each Pod: filter, which removes nodes that fail a hard requirement, and score, which ranks the nodes that remain. The scheduler writes its decision into the Pod and, when no node passes the filter phase, writes a `FailedScheduling` event instead. You can see both outcomes with two small Pods.

<!-- astrona:playground:renew -->

Save this as `pod-filter-fail.yaml`. It requires a node label that no node has:

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: filter-fail
  namespace: starfleet
spec:
  nodeSelector:
    training.astrona.io/accelerator: "true"
  containers:
  - name: scout
    image: docker.io/library/busybox:1.37.0
    command: ["sh", "-c", "sleep 3600"]
```

Apply it:

```sh
kubectl apply -f pod-filter-fail.yaml
```

Then read the events:

```sh
kubectl -n starfleet describe pod filter-fail
```

The Pod is `Pending`. The event is a `FailedScheduling` warning from `default-scheduler`. It says that no node is available and counts the nodes that did not match the Pod's node affinity or selector. The scheduler did not fail: it tested every node, found none that satisfies the mandatory rule, and left the Pod unassigned. Free CPU on the worker does not matter, because the filter runs before any resource preference.

A rule that a node satisfies produces a different result. Save this as `pod-filter-pass.yaml`:

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: filter-pass
  namespace: starfleet
spec:
  nodeSelector:
    kubernetes.io/os: linux
  containers:
  - name: scout
    image: docker.io/library/busybox:1.37.0
    command: ["sh", "-c", "sleep 3600"]
```

Apply it and check the node:

```sh
kubectl apply -f pod-filter-pass.yaml
kubectl -n starfleet get pod filter-pass -o wide
```

The Pod runs on the worker. Both nodes carry the label `kubernetes.io/os=linux`, so both pass this rule, but the control plane node fails a different filter: its taint. The scheduler therefore left one candidate and chose it. Delete both Pods when you are done:

```sh
kubectl -n starfleet delete pod filter-fail filter-pass
```

### What the exam expects

The exam gives a Pod that does not start and asks you to find the rule that excludes every node. Read the event first, compare it with the node labels and taints, and change the Pod only if the rule is wrong. Never relabel a node to make a mistaken rule pass unless the label is the real fault.

The two Pods show the filter phase from the outside. What they cannot show is scoring, because a single candidate has nothing to rank against. Scoring matters once several nodes pass, and the preferred rules of the next topics feed it.

## Common pitfalls

> [!WARNING]
> A preferred affinity rule is not a requirement. Required rules can prevent placement even when a node has enough unused resources.
