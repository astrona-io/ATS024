# Update Strategies Playground

The `starfleet` namespace has a `probe` Deployment with two replicas and a `probe` Service, a `shuttle` client Pod, a StatefulSet named `crew` with three Pods on the image `busybox:1.36.1`, and a DaemonSet named `scanner` that runs on both nodes of the environment.

The environment is private and not graded. It has its own context and a pinned node image. Select it with `export KUBECONFIG="$(astrona kubeconfig ats-024-playground-010-03)"`.
