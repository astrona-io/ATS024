---
draft: true
exam_objectives:
- Understand application deployments and how to perform rolling update and rollbacks
---
# Prerequisites

Use a host shell with astrona, kubectl and Python 3. Understand the resource fields and diagnostic commands taught before this task.

Use this lab's private kubeconfig. A kubeconfig contains the cluster address and credentials used by kubectl, the Kubernetes command-line tool. The lab has a separate kind cluster from the module playground.

```sh
export KUBECONFIG="$(astrona kubeconfig ats-024-lab-010-01-02)"
test "$(kubectl config current-context)" = "kind-astro-ats-024-lab-010-01-02" || exit 1
```

Keep this connection selected for every command below.
