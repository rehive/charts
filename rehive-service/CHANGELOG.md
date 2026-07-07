# Change Log

This file documents all notable changes to Rehive Service Helm Chart. The release
numbering uses [semantic versioning](http://semver.org).

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

