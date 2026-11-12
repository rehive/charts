# rehive-service

rehive-service is a chart that deploys a rehive service on Kubernetes.

## Prerequisites

- Kubernetes 1.9+
- Helm 3

## Installing the Chart

To install the chart with the release name `service-example`:

```console
## Add the rehive charts repository
$ helm repo add rehive https://rehive.github.io/charts

## Install the rehive-service helm chart
$ helm install service-example rehive/rehive-service
```

> **Tip**: List all releases using `helm list`

## Upgrading the Chart


## Uninstalling the Chart

To uninstall/delete the `service-example` deployment:

```console
$ helm uninstall service-example
```

The command removes all the Kubernetes components associated with the chart and deletes the release.

## Configuration

The following table lists the configurable parameters of the rehive-service chart and their default values.

| Parameter | Description | Default |
| --------- | ----------- | ------- |
| `deployment.replicaCount` | Number of pods for the deployment | `3` |
| `deployment.resources` | CPU/Memory limits of the deployment pods | `{}` |
| `deployment.command` | Command array to run after the deployment pods are ready | `['gunicorn', 'config.wsgi:application']` |
| `deployment.args` | Args for the command to run. These are key-value pairs for kwargs and null keys for args. | `{'config': 'file:config/gunicorn.py'}` |
| `deployment.nodeSelector` | Node labels for scheduling the deployment pods (e.g. pin to a node pool) | `{}` |
| `deployment.tolerations` | Tolerations for the deployment pods (e.g. tolerate a dedicated node pool taint) | `[]` |
| `workers.deployments[].nodeSelector` | Optional per-worker node labels for scheduling | `{}` |
| `workers.deployments[].tolerations` | Optional per-worker tolerations | `[]` |
| `workers.deployments[].strategy` | Optional per-worker rollout strategy. Set `{type: Recreate}` for singletons like celery beat schedulers so two copies never run concurrently. | RollingUpdate, `maxUnavailable: 0`, `maxSurge: 2` |
| `image.repository` | Docker image containing the service's source | `rehive/example` |
| `image.tag` | Docker image tag to use for the deployment. This is usually set to a version. | `latest` |
| `image.pullPolicy` | Image pull policy | `IfNotPresent` |
| `imagePullSecrets` | Secret for pulling images from a private registry, e.g. `{name: my-registry-secret}` | `{}` |
| `podSecurityContext` | Pod-level securityContext applied to web and worker pods | `{}` |
| `containerSecurityContext` | Container-level securityContext applied to web and worker containers | `{}` |
| `service.name` | Service name for the nginx-ingress service | `nginx` |
| `service.type` | Load balancer service type | `ClusterIP` |
| `service.externalPort` | Public facing port for the load balancer service | `80` |
| `service.internalPort` | Internal service port for the pods | `8000` |
| `service.livenessProbe` | Liveness Probe for the pods. (See [docs](https://kubernetes.io/docs/tasks/configure-pod-container/configure-liveness-readiness-probes/)) | |
| `service.readinessProbe` | Readiness Probe for pods. (See [docs](https://kubernetes.io/docs/tasks/configure-pod-container/configure-liveness-readiness-probes/)) | |
| `envFromSecret.enabled` | Load environment from secrets with the same name `Release.Name` (applies to web and worker pods) | `true` |
| `envFromSecret.name` | Name of the secret to load environment variables from. If empty string given then k8s secret with the name of `Release.Name` is used | `""` |
| `env` | Plain, non-secret environment variables for web and worker pods, as a map (e.g. `{ALLOWED_HOSTS: "*"}`) | `{}` |
| `secretManager.enabled` | Load secrets from Google Secret Manager (see below) | `false` |
| `secretManager.environment` | `staging` or `production`, the first part of each secret name. Required when enabled | `""` |
| `secretManager.service` | Second part of each secret name | `Release.Name` |
| `secretManager.prefix` | Overrides the whole `<environment>--<service>--` prefix | `""` |
| `secretManager.project` | Google Cloud project holding the secrets | `rehive-services` |
| `secretManager.location` | Region of the regional secrets; must match the cluster's | `europe-west4` |
| `secretManager.keys` | Environment variable names to load, one secret each | `[]` |
| `secretManager.mountPath` | Where the secrets are mounted as files | `/var/run/secrets/rehive` |
| `secretManager.loaderPath` | Path of the `with-secrets` loader that wraps every command | `/opt/rehive/bin/with-secrets` |
| `secretManager.minRdeploy` | Oldest rdeploy whose `manage`/`shell` support this setup (Deployment annotation) | `0.5.0` |
| `serviceAccount.create` | Create a ServiceAccount for the pods | `true` |
| `serviceAccount.name` | ServiceAccount name. Defaults to the release name when empty; with `create: false` and no name, pods use the namespace `default` account | `""` |
| `vendor.name` | Name of the vendor to install the manifest. `(aws|gcp|azure)` | `gcp` |
| `httpRoute.enabled` | Create a Gateway API HTTPRoute attached to a shared Gateway (the standard routing path for new services; e.g. GKE Gateway with a Google Application Load Balancer) | `false` |
| `httpRoute.gateway.name` | Name of the shared Gateway to attach to | `external-http` |
| `httpRoute.gateway.namespace` | Namespace of the shared Gateway | `gateway` |
| `httpRoute.hostnames` | Hostnames routed to the service | `[example.services.rehive.com]` |
| `httpRoute.rules` | Custom routing rules; when empty a single rule routes `/` to the service on `service.externalPort` | `[]` |
| `httpRoute.labels` | Extra labels for the HTTPRoute, e.g. `{gateway: external-http}` | `{}` |
| `httpRoute.healthCheckPolicy` | GKE HealthCheckPolicy `spec.default` passthrough targeting the Service (e.g. `{config: {type: HTTP, httpHealthCheck: {requestPath: /readiness}}}`); empty disables it | `{}` |
| `httpRoute.backendPolicy` | GKE GCPBackendPolicy `spec.default` passthrough targeting the Service (e.g. Cloud Armor `securityPolicy`, `timeoutSec`, `logging`); empty disables it | `{}` |
| `httpRoute.nameOverride` | HTTPRoute name, mainly for adopting pre-existing resources | `<release>-external` |
| `httpRoute.healthCheckPolicyName` | HealthCheckPolicy name override | `<release>-health` |
| `httpRoute.backendPolicyName` | GCPBackendPolicy name override | `<release>-backend` |
| `ingress.enabled` | Create ingress resource (legacy nginx-ingress routing) | `false` |
| `ingress.className` | Ingress class (`spec.ingressClassName`) | `nginx` |
| `ingress.hosts` | List of ingress host URLs | `[example.services.rehive.io]` |
| `ingress.annotations` | Annotations for the ingress resources | `{kubernetes.io/tls-acme: "true" }` |
| `ingress.tls` | TLS Settings for Ingress | `[{"hosts": ["example.services.rehive.io"], "secretName": "example-service-tls" }]` |



Specify each parameter using the `--set key=value[,key=value]` argument to `helm install`.

Alternatively, a YAML file that specifies the values for the above parameters can be provided while installing the chart. For example,

```console
$ helm install --name service-example -f values.yaml rehive/rehive-service
```
> **Tip**: You can use the default [values.yaml](values.yaml)

## Secrets from Google Secret Manager

With `secretManager.enabled`, each key in `secretManager.keys` is read from its own regional secret, `projects/<project>/locations/<location>/secrets/<environment>--<service>--<KEY>/versions/latest`, for example `staging--rehive-resources--SECRET_KEY`. No Kubernetes Secret is involved.

1. A `SecretProviderClass` lists the secrets, and the GKE Secret Manager add-on mounts each one as a file named after its key.
2. Every web and worker command is prefixed with the `with-secrets` loader (a ConfigMap script). It exports each file as an environment variable, then `exec`s the command. Values are read once, at startup: restart the pods after changing a secret.
3. The pods authenticate as the chart's ServiceAccount through Workload Identity, and are scheduled on nodes with the GKE metadata server.

Requirements:

- The cluster has the Secret Manager add-on (`gcloud container clusters update <cluster> --enable-secret-manager`) and Workload Identity.
- The ServiceAccount's principal, `principal://iam.googleapis.com/projects/<project number>/locations/global/workloadIdentityPools/<project>.svc.id.goog/subject/ns/<namespace>/sa/<service account>`, has `roles/secretmanager.secretAccessor` on the secrets.
- Every deployment and worker sets an explicit `command`, which the loader wraps.
- One-off commands need the loader too: `kubectl exec deploy/<name> -- /opt/rehive/bin/with-secrets python manage.py ...`. `rdeploy manage` and `rdeploy shell` from 0.5.0 handle this from the Deployment's `rehive.com/entrypoint` annotation.

`secretManager` and `envFromSecret` can both be on; values from Secret Manager win. When moving a service over, turn `envFromSecret` off in the same release so a key missing from Secret Manager fails at startup instead of being filled in from the old Secret.

## Compatibility check

Before publishing, check that existing values files render the same as the last published version:

```console
make login-gcloud
python scripts/compat_check.py --base 1.3.0 ../*/etc/helm/*/values.yaml
```

It needs PyYAML and ignores the `helm.sh/chart` label; any other difference fails. `tests/rehive-service/secret-manager-values.yaml` exercises the Secret Manager path:

```console
helm lint rehive-service -f tests/rehive-service/secret-manager-values.yaml
```
