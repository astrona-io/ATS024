# Pod Lifecycle And Restart Behavior - Playground

- **Slug:** ats-024-playground-040-03
- **Type:** Astrona playground - clean environment, no task, no grading

A single-node kind cluster (Kubernetes 1.35, `kindest/node:v1.35.0`) with four example Pods:

- `shuttle` (`starfleet`) crash-loops under `restartPolicy: Always`; `drifter` (`outpost`) fails once under `restartPolicy: Never`.
- `scout` (`starfleet`) has two init containers that prepare a shared volume.
- `probe` (`starfleet`) has a native sidecar container.
- `bridge` (`starfleet`) has `postStart` and `preStop` hooks and a 45 second grace period.

## Run it

```sh
astrona run -c .
astrona destroy ats-024-playground-040-03
```

`astrona destroy` takes the environment name, not the config path. `astrona submit` does not apply: there is no grading.

## Layout

| Path | Purpose |
| --- | --- |
| `config.yaml` | Environment definition (runtime, preloaded image, starting manifests) |
| `manifests/` | Namespaces and the four example Pods |
| `docs/overview.md` | What the environment contains and ideas to try |
