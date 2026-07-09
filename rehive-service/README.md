# rehive-service

rehive-service is a chart that deploys a rehive service on Kubernetes.

## Prerequisites

- Kubernetes 1.9+

## Installing the Chart

To install the chart with the release name `service-example`:

```console
## Add the rehive charts repository
$ helm repo add rehive https://rehive.github.io/charts

## Install the rehive-service helm chart
$ helm install --name service-example rehive/rehive-service
```

> **Tip**: List all releases using `helm list`

## Upgrading the Chart


## Uninstalling the Chart

To uninstall/delete the `service-example` deployment:

```console
$ helm delete --purge service-example
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
