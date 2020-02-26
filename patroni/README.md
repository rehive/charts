# Patroni Helm Chart

This chart deploys a [Patroni](https://github.com/zalando/patroni/) cluster using a StatefulSet. It is based on
an image which allows Patroni to be run without an external DCS (Consul, Etcd, Zookeeper).

See https://github.com/zalando/spilo/pull/198 and https://github.com/zalando/patroni/pull/500.

## Prerequisites Details

* Kubernetes 1.9+
* PV support on the underlying infrastructure

## Installing the Chart

To install the chart with the release name `my-release`:

```console
$ helm repo add rehive https://rehive.github.io/charts
$ helm repo update
$ helm dependency update
$ helm install --name my-release incubator/patroni-k8s
```

## Configuration

The following tables lists the configurable parameters of the patroni-k8s chart and their default values.

| Parameter | Description | Default |
|-------------------------|-------------------------------------|-----------------------------------------------------|
| `image.repository` | Spilo image repository | `eu.gcr.io/rehive-services/spilo` |
| `image.tag` | Spilo image tag | `1.6.1` |
| `image.pullPolicy` | Spilo image pull policy | `IfNotPresent` |
| `init.command` | Spilo command to run on startup | `['bin/sh']` |
| `init.args` | Spilo command's arguments to run on startup | `['/launch.sh', 'init']` |
| `replicas` | number of statefulset replicas | `3` |
| `debug` | toggle to print debug messages | `false` |
| `nodeSelector` | nodeSelector map | `{}` |
| `tolerations` | node taints to tolerate  | `[]` |
| `podAntiAffinity` | Set the pod antiaffinity to either `(hard|soft)` | `soft` |
| `resources` | CPU and Memory requests and limits for each pod | `[]` |
| `useConfigMaps` | default patroni to create an endpoint for the postgres settings else an endpoint of the settings will be used | `false` |
| `postgresParamaters` | Postgres parameters for Patroni https://github.com/zalando/patroni/blob/master/docs/SETTINGS.rst#postgresql | `{'bin_dir': '/usr/lib/postgresql/9.6/bin' }` |
| `bootstrapParameters` | Patroni bootstrap parameters https://patroni.readthedocs.io/en/latest/SETTINGS.html#bootstrap-configuration | `{'dcs' : {'ttl': 70, 'loop_wait': 10, 'retry_timeout': 30 } }` |
| `walE.enabled` | use of wal-e tool for backing up postgres data | `false` |
| `walE.envDir` | directory to store the wal-E environment variables | `/home/postgres/etc/wal-e.d/env` |
| `walE.scheduleCronJob` | crontab schedule of wal-e backup | `00 01 * * *` |
| `walE.retainBackups` | number of base backups to retain | `2` |
| `walE.s3Bucket` | Amazon S3 bucket used for wal-e backups | `` |
| `walE.gcsBucket` | Google Cloud Platform (GCP) Storage bucket  used for wal-e backups | `` |
| `walE.gcloudCredentials` | name of the Google Applications Credentials file for wal-E backup. This file name would be in the `gcloudCredentials.secretName` k8s secret | `gcloud-wale.json` |
| `walE.backupThresholdMegabytes` | maximum size of the WAL segments accumulated after the base backup to consider WAL-E restore instead of pg_basebackup | `1024` |
| `walE.backupThresholdPercentage` | maximum ratio (in percents) of the accumulated WAL files to the base backup to consider WAL-E restore instead of pg_basebackup | `30` |
| `persistentVolume.enabled` | specifies whether persistent volumes are used | `true` |
| `persistentVolume.accessModes` | persistent volume access modes | `[ReadWriteOnce]` |
| `persistentVolume.annotations` | annotations for persistent volume claim | `{}` |
| `persistentVolume.size` | persistent volume size | `1Gi` |
| `persistentVolume.storageClass` | persistent volume storage class | `patroni-standard` |
| `gcloudCredentials.enabled` | enable k8s secrets to store backup and restore credentials | `false` |
| `gcloudCredentials.secretName` | name of the k8s secret containing the credentials files for backup and restore | `google-credentials-postgres` |
| `cleanup.image.repository` | cleanup image repository | `gcr.io/google-containers/hyperkube` |
| `cleanup.image.tag` | cleanup image tag | `v1.13.7` |
| `cleanup.image.pullPolicy` | cleanup image pull policy | `IfNotPresent` |
| `rbac.create` | create rolebinding and roles manifest for k8s | `true` |
| `serviceAccount.create` | create k8s service account for running the k8s statefulsets | `true` |
| `serviceAccount.name` | name of the service account. If none given a default is created. | `""` |

Specify each parameter using the `--set key=value[,key=value]` argument to `helm install`.

Alternatively, a YAML file that specifies the values for the parameters can be provided while installing the chart. For example,

```console
$ helm install --name my-release -f values.yaml rehive/patroni
```

> **Tip**: You can use the default [values.yaml](values.yaml)
