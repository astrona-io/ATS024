# Kustomize And Helm Playground

The `starfleet` namespace has a running `probe` Deployment with two replicas, a `probe` Service and a `shuttle` client Pod. The `outpost` namespace is empty apart from the `drifter` client Pod. Create the Kustomize directories in the current directory of your shell. Helm is not installed in this environment.

The environment is private and not graded. It has its own context and a pinned node image. Select it with `export KUBECONFIG="$(astrona kubeconfig ats-024-playground-010-04)"`.
