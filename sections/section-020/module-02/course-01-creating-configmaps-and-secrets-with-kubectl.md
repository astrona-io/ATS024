---
draft: true
exam_objectives:
- Use ConfigMaps and Secrets to configure applications
---
# Creating ConfigMaps And Secrets With kubectl

Writing a ConfigMap by hand means writing YAML, indenting it correctly and encoding Secret values. On the exam and in daily work, `kubectl create` is faster and has fewer mistakes. This part shows the three ways to feed data into `kubectl create configmap` and `kubectl create secret generic`, and how each way names the keys.

## Three sources of data

A key in a ConfigMap or Secret comes from one of three places. A literal is a value typed on the command line. A file is read from disk, and the file content becomes the value. An environment file holds many `KEY=value` lines, and each line becomes one key.

| Flag | Key name | Value |
| --- | --- | --- |
| `--from-literal=key=value` | the text before `=` | the text after `=` |
| `--from-file=path` | the file name | the whole file content |
| `--from-file=key=path` | the name you choose | the whole file content |
| `--from-env-file=path` | the name on each line | the text after `=` on that line |

You can repeat a flag and combine different flags in one command. If two flags produce the same key name, the command fails, so choose names carefully.

## Create from literals

A literal is best for a few short values. Create a ConfigMap for the `scout` application with two settings:

<!-- astrona:playground:renew -->

```sh
kubectl -n starfleet create configmap scout-literal --from-literal=LOG_LEVEL=info --from-literal=REGION=alpha
```

The command prints `configmap/scout-literal created`. The ConfigMap has two keys, `LOG_LEVEL` and `REGION`. Check them with `kubectl -n starfleet get configmap scout-literal -o yaml`. The `data` block lists both keys with the values as plain text.

## Create from a file

A file is best for a configuration document that the application reads whole, such as a properties file. Save this as `scout.properties`:

```ini
log.level=debug
feature.radar=true
```

Create the ConfigMap with the file:

```sh
kubectl -n starfleet create configmap scout-file --from-file=scout.properties
kubectl -n starfleet create configmap scout-file-renamed --from-file=app.conf=scout.properties
```

The first ConfigMap has one key named `scout.properties`, and its value is the two lines. The second ConfigMap has the same content under the key `app.conf`. When a Pod mounts the ConfigMap as a volume, the key becomes the file name, so the second form decides the file name the application sees. You can also pass a directory: `--from-file=./config-dir` creates one key for each regular file in the directory.

## Create from an environment file

An environment file is made for variables. Each line has the form `NAME=value`. Empty lines and lines that start with `#` are ignored. Save this as `scout.env`:

```ini
# settings for scout
LOG_LEVEL=warn
REGION=beta
```

Create the ConfigMap:

```sh
kubectl -n starfleet create configmap scout-env --from-env-file=scout.env
```

This ConfigMap has the keys `LOG_LEVEL` and `REGION`, not one key that holds the whole file. That is the difference from `--from-file`. Use `--from-env-file` when you plan to inject the keys as environment variables.

## Create a Secret the same way

`kubectl create secret generic` accepts the same three flags. It creates a Secret of type `Opaque`. The command encodes the values in base64 for you.

```sh
kubectl -n starfleet create secret generic scout-credentials --from-literal=username=scout --from-literal=password=disposable-pass
kubectl -n starfleet get secret scout-credentials -o jsonpath='{.data.username}' | base64 -d
```

The second command decodes the `username` key and prints `scout`. The shell history keeps a password typed with `--from-literal`, so on real systems prefer `--from-file` with a file that you remove afterwards. Other Secret types have their own subcommands, and a later module covers them.

## Generate a manifest instead of creating

The option `--dry-run=client -o yaml` builds the object locally and prints it without sending it to the cluster. This gives you a manifest to edit, store in a file or apply later. It works for ConfigMaps, Secrets, Pods and most other `kubectl create` and `kubectl run` commands.

```sh
kubectl -n starfleet create configmap scout-generated --from-literal=LOG_LEVEL=error --dry-run=client -o yaml
```

The output is a complete ConfigMap with `apiVersion: v1`, `kind: ConfigMap`, the `data` block and the name and namespace. Nothing exists in the cluster yet. Redirect the output into `configmap-scout-generated.yaml`, add fields such as labels or `immutable: true`, and apply the file with `kubectl apply -f`. The exam rewards this habit because it avoids typing the structure from memory.

## Replace an existing object

`kubectl create` fails with `AlreadyExists` when the name is taken. To update an object from the same flags, pipe the generated manifest into `kubectl apply`:

```sh
kubectl -n starfleet create configmap scout-literal --from-literal=LOG_LEVEL=debug --from-literal=REGION=alpha --dry-run=client -o yaml | kubectl apply -f -
```

The command updates the existing ConfigMap in place. The `kubectl apply` step may print a warning that the object has no `last-applied-configuration` annotation, because the object was first made with `create`. The warning is harmless, and `apply` adds the annotation.

## Clean up

```sh
kubectl -n starfleet delete configmap scout-literal scout-file scout-file-renamed scout-env
kubectl -n starfleet delete secret scout-credentials
```

You now create ConfigMaps and Secrets from literals, files and environment files, and you can generate a manifest from any of them. The open question is how a container receives those keys as environment variables, and what happens when a name or key does not match.

## Common pitfalls

> [!WARNING]
> `--from-file=name` makes one key named after the file, while `--from-env-file` makes one key for each line. A literal password stays in the shell history. `kubectl create` does not update an existing object, so use the dry-run output with `kubectl apply`.
