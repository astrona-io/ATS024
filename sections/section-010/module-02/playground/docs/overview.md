# Revision History And Rollbacks Playground

The `starfleet` namespace has a `probe` Deployment with two replicas, a `probe` Service and a `shuttle` client Pod. Setup changed `probe` twice, so the Deployment has three revisions. Revisions 2 and 3 carry a change-cause annotation.

The environment is private and not graded. It has its own context and a pinned node image. Select it with `export KUBECONFIG="$(astrona kubeconfig ats-024-playground-010-02)"`.
