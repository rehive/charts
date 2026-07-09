# Change Log

This file documents all notable changes to Rehive Service Helm Chart. The release
numbering uses [semantic versioning](http://semver.org).

## v2.0.0 - 2026-07-10

### Changed
- **Breaking:** every worker Deployment's selector now includes a unique `rehive.io/worker: <worker name>` label. Previously all workers in a release shared an identical selector (`app.kubernetes.io/name` + `app.kubernetes.io/component: worker`), which violates the Kubernetes requirement that controller selectors not overlap and made it impossible to target a single worker with a Service, PDB, or HPA.

### Upgrading from 1.x
Selectors are immutable, so each existing worker Deployment must be deleted and recreated once. `helm upgrade` alone will fail with a field-immutability error. Two options per worker:

- **Zero consumer downtime** (recommended for busy queues): `kubectl delete deployment <worker> --cascade=orphan`, run `helm upgrade`, wait for the new pods to become Ready, then delete the orphaned old ReplicaSet **by name** (never by label — old and new share labels).
- **Simple, brief consumption gap** (fine for low-traffic queues and required for beat schedulers, where overlap would duplicate scheduled tasks): `kubectl delete deployment <worker>`, then `helm upgrade`. Tasks queue in the broker during the gap; nothing is lost.

The web Deployment, Service, and PDB are untouched — web traffic is unaffected throughout.

## v1.3.0 - 2026-07-10

### Added
- Gateway API support (`httpRoute`, disabled by default): renders an HTTPRoute attached to a shared Gateway (e.g. GKE Gateway with a Google Application Load Balancer), plus optional GKE `HealthCheckPolicy` and `GCPBackendPolicy` passthroughs targeting the Service. This is the standard routing path for new services; existing hand-applied routes can be adopted into a release later via Helm ownership labels/annotations (name overrides are provided for resources whose names don't match the chart's defaults).
- Optional per-worker `strategy` override. The default remains the zero-downtime RollingUpdate (`maxUnavailable: 0`, `maxSurge: 2`). Singleton workers such as celery beat schedulers should set `strategy: {type: Recreate}` so two copies never run concurrently during an upgrade.
- `podSecurityContext` and `containerSecurityContext` passthroughs applied to both the web and worker pods (empty by default).
- `serviceAccount.name` value and a `serviceAccountName` helper: pods fall back to the namespace `default` ServiceAccount when `serviceAccount.create` is `false` and no name is given (previously they referenced a ServiceAccount that might not exist).
- `ingress.className` value that sets `spec.ingressClassName`, replacing the deprecated `kubernetes.io/ingress.class` annotation in the default values.
- Documented `imagePullSecrets` in values.yaml.

### Changed
- `ingress.enabled` now defaults to `false` (was `true`). Routing is opt-in: new services should enable `httpRoute`, legacy services enable `ingress`. All known consumers set `ingress.enabled` explicitly, but double-check any values file that relied on the old default.
- Worker deployments now honour `envFromSecret.enabled` and `envFromSecret.name` (previously the secret name was hardcoded to the release name and always mounted).
- Worker pods now run as the chart's ServiceAccount, matching the web deployment (previously they ran as the namespace `default` ServiceAccount). No permission change with default values, but note this if your workers rely on the `default` account's bindings or Workload Identity annotations.
- Worker `ports.containerPort` is now only rendered when `internalPort` is set (celery workers don't listen on a port).
- Common labels now include the standard `app.kubernetes.io/instance` instead of the non-standard `helm.sh/release`. No selectors reference these labels, so this is metadata-only.
- Chart.yaml upgraded to `apiVersion: v2` (requires Helm 3).
- NOTES.txt now prints a compact deploy summary (image, replicas, workers, hosts) plus quick status/log commands instead of the boilerplate "get the application URL" instructions.

### Fixed
- Worker manifests rendered a malformed YAML document separator (`---` joined to the next document's first line), which broke `helm lint` and strict YAML parsers. Helm's own splitter tolerated it, so deploys were unaffected.
- Default values: `redis.secret.key` mistakenly defaulted to `rabbitmq-password`; `rabbitmq.host` example pointed at a patroni host; `vhost`/`user` sat under `redis` (unused) instead of `rabbitmq` (used by the templates).

## v1.2.0 - 2026-07-07

### Added
- PodDisruptionBudget for the web deployment (`deployment.podDisruptionBudget`, enabled by default, `maxUnavailable: 1`) so node drains can't evict all replicas at once. Safe for single-replica deployments.
- Default soft `topologySpreadConstraints` (whenUnsatisfiable: ScheduleAnyway) on the web deployment so replicas spread across nodes; overridable via `deployment.topologySpreadConstraints`. Optional `deployment.affinity` passthrough.
- `service.startupProbe` passthrough so slow-booting pods get a startup grace window (empty by default; configure per service).
- Worker deployments: optional per-worker `lifecycle` (preStop) and `terminationGracePeriodSeconds` (default 60).

### Changed
- Worker `imagePullPolicy` now follows `image.pullPolicy` (was hardcoded `IfNotPresent`).

## v1.1.4 - 2026-06-11
### Added
- Added optional `deployment.nodeSelector` and `deployment.tolerations` values to the main deployment.
- Added optional per-worker `nodeSelector` and `tolerations` values to worker deployments.

## v1.1.3 - 2024-05-10
### Added
- Added default lifecycle hook to the Helm chart to prevent 503 during deployment.
- Updated default rolling update values to speed up deployments.

## v1.1.2 - 2024-05-03

### Removed
- Removed the default lifecycle configuration from the Helm chart.

## v1.1.1 - 2024-10-05

### Added
- Introduced lifecycle configuration in the Helm chart to manage container states more effectively.
- Added a default pre-stop hook to the deployment configuration to help prevent downtime during deployments. This pre-stop hook includes a default `sleep 10` command to delay the termination.

## v1.1.0 - 2023-10-02

### Major Changes

* Added `VERSION` environment variable to the pod to specify the current version of the application.

## v0.1.40

### Major Changes

* Changed the way `command` and `args` are stored in the values file.
  `command` is stored as an array of strings, while `args` are stored as
  key-value pairs of strings (`kwargs`). If an argument is needed to run without
  a value, then explicitly set the value of the argument key to `null`.

* Renamed `envFromSecret.secretName` to `envFromSecret.name` due to redundancy

* Added `vendor` settings to accomodate `azure` specific deployment settings

* Reverted the deployment labels `app=webapp` and `app=$worker.name` for backward
  compatibility.

### Minor Changes

* Added maintainers to Chart.yaml

* Coalesced redis, postgres and rabbitmq settings to plugin settings.

## v0.1.39

### Minor changes

* Reverted our deployments back to the extensions/v1beta1 because chart upgrade
  from extensions/v1beta1 to apps/v1 Deployment is not possible as documented
  [here](https://github.com/helm/helm/issues/6583)

