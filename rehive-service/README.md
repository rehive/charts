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
| `deployment.resources` | CPU/Memory limits of the deployment pods | |
| `deployment.command` | Command array to run after the deployment pods are ready | |
| `image.repository` | Docker image containing the service's source | `gcr.io/rehive-services/service-test` |
| `image.tag` | Docker image tag to use for the deployment. This is usually set to a version. | `latest` |
| `image.pullPolicy` | Image pull policy | `IfNotPresent` |
| `service.name` | Service name for the nginx-ingress service | `nginx` |
| `service.type` | Load balancer service type | `ClusterIP` |
| `service.externalPort` | Public facing port for the load balancer service | `80` |
| `service.internalPort` | Internal service port for the pods | `8000` |
| `service.livenessProbe` | Liveness Probe for the pods. (See [docs](https://kubernetes.io/docs/tasks/configure-pod-container/configure-liveness-readiness-probes/)) | |
| `service.readinessProbe` | Readiness Probe for pods. (See [docs](https://kubernetes.io/docs/tasks/configure-pod-container/configure-liveness-readiness-probes/)) | |
| `envFromSecret.enabled` | Load environment from secrets with the same name `Release.Name` | `true` |
| `management.enabled` | Create management pod | `true` |
| `ingress.enabled` | Create ingress resource | `true` |
| `ingress.hosts` | List of ingress host URLs | `[example.services.rehive.io]` |
| `ingress.annotations` | Annotations for the ingress resources | `{kubernetes.io/ingress.class: "nginx", kubernetes.io/tls-acme: "true" }` |


Specify each parameter using the `--set key=value[,key=value]` argument to `helm install`.

Alternatively, a YAML file that specifies the values for the above parameters can be provided while installing the chart. For example,

```console
$ helm install --name service-example -f values.yaml rehive/rehive-service
```
> **Tip**: You can use the default [values.yaml](values.yaml)
