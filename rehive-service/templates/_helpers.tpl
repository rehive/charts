{{/* vim: set filetype=mustache: */}}
{{/*
Expand the name of the chart.
*/}}
{{- define "rehive-service.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "rehive-service.fullname" -}}
{{- .Release.Name | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "rehive-service.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Common labels
*/}}
{{- define "rehive-service.labels" -}}
app.kubernetes.io/managed-by: {{ .Release.Service | quote }}
app.kubernetes.io/instance: {{ .Release.Name }}
helm.sh/chart: {{ include "rehive-service.chart" . }}
{{- end -}}

{{/*
Name of the ServiceAccount the pods run as. Falls back to the namespace
default SA when the chart neither creates one nor is given a name.
*/}}
{{- define "rehive-service.serviceAccountName" -}}
{{- if .Values.serviceAccount.create -}}
{{- default (include "rehive-service.fullname" .) .Values.serviceAccount.name -}}
{{- else -}}
{{- default "default" .Values.serviceAccount.name -}}
{{- end -}}
{{- end -}}


{{/*
Environment Variables
*/}}
{{- define "rehive-service.plugins" -}}
{{- if .Values.postgres.enabled }}
- name: POSTGRES_HOST
  value: {{ .Values.postgres.host }}
- name: POSTGRES_PORT
  value: {{ .Values.postgres.port | quote }}
- name: POSTGRES_USER
  value: {{ .Values.postgres.user }}
- name: POSTGRES_DB
  value: {{ .Values.postgres.db }}
- name: POSTGRES_PASSWORD
  valueFrom:
    secretKeyRef:
      name: {{ .Values.postgres.secret.name }}
      key: {{ .Values.postgres.secret.key }}
{{- end }}
{{- if .Values.rabbitmq.enabled }}
- name: RABBITMQ_HOST
  value: {{ .Values.rabbitmq.host }}
- name: RABBITMQ_VHOST
  value: {{ .Values.rabbitmq.vhost }}
- name: RABBITMQ_PORT
  value: {{ .Values.rabbitmq.port | quote }}
- name: RABBITMQ_USER
  value: {{ .Values.rabbitmq.user }}
- name: RABBITMQ_PASSWORD
  valueFrom:
    secretKeyRef:
      name: {{ .Values.rabbitmq.secret.name }}
      key: {{ .Values.rabbitmq.secret.key }}
{{- end }}
{{- if .Values.redis.enabled }}
- name: REDIS_HOST
  value: {{ .Values.redis.host }}
- name: REDIS_PORT
  value: {{ .Values.redis.port | quote }}
- name: REDIS_PASSWORD
  valueFrom:
    secretKeyRef:
      name: {{ .Values.redis.secret.name }}
      key: {{ .Values.redis.secret.key }}
{{- end }}
{{- end -}}

{{/*
Plain, non-secret environment variables from .Values.env (sorted by name).
*/}}
{{- define "rehive-service.env" -}}
{{- range $name, $value := .Values.env }}
- name: {{ $name }}
  value: {{ $value | toString | quote }}
{{- end }}
{{- end -}}

{{/*
Secret Manager: checks the values once and returns the secret name prefix,
"<environment>--<service>--" unless secretManager.prefix overrides it.
*/}}
{{- define "rehive-service.secretManager.prefix" -}}
{{- $sm := .Values.secretManager -}}
{{- if not $sm.keys }}{{ fail "secretManager.keys must list at least one key" }}{{ end -}}
{{- range $sm.keys }}
{{- if not (regexMatch "^[A-Za-z_][A-Za-z0-9_]*$" .) }}{{ fail (printf "secretManager.keys: %q is not a valid environment variable name" .) }}{{ end }}
{{- end -}}
{{- if $sm.prefix -}}
{{- $sm.prefix -}}
{{- else -}}
{{- $env := required "secretManager.environment is required (e.g. staging or production)" $sm.environment -}}
{{- printf "%s--%s--" $env (default (include "rehive-service.fullname" .) $sm.service) -}}
{{- end -}}
{{- end -}}

{{- define "rehive-service.secretManager.className" -}}
{{- printf "%s-secret-manager" (include "rehive-service.fullname" .) -}}
{{- end -}}

{{- define "rehive-service.secretManager.loaderName" -}}
{{- printf "%s-with-secrets" (include "rehive-service.fullname" .) -}}
{{- end -}}

{{/*
A container command, prefixed with the with-secrets loader when Secret
Manager is on. Call with (dict "root" $ "command" <list>).
*/}}
{{- define "rehive-service.command" -}}
{{- $sm := .root.Values.secretManager -}}
{{- if $sm.enabled -}}
{{- if not .command }}{{ fail "secretManager needs an explicit command on every deployment and worker (the loader wraps it)" }}{{ end -}}
{{- toYaml (prepend .command $sm.loaderPath) -}}
{{- else -}}
{{- toYaml .command -}}
{{- end -}}
{{- end -}}

{{/*
Node selector: the given one, plus the Workload Identity node label the
Secret Manager add-on needs when it is on. Call with (dict "root" $ "nodeSelector" <map>).
*/}}
{{- define "rehive-service.nodeSelector" -}}
{{- $selector := deepCopy (.nodeSelector | default dict) -}}
{{- if .root.Values.secretManager.enabled -}}
{{- $_ := set $selector "iam.gke.io/gke-metadata-server-enabled" "true" -}}
{{- end -}}
{{- if $selector -}}
{{- toYaml $selector -}}
{{- end -}}
{{- end -}}

{{/*
Volume mounts and volumes for gcloud credentials and Secret Manager.
Empty when neither is on.
*/}}
{{- define "rehive-service.volumeMounts" -}}
{{- if .Values.gcloudCredentials.enabled }}
- name: {{ .Values.gcloudCredentials.kubernetesSecret }}
  mountPath: /etc/credentials
  readOnly: true
{{- end }}
{{- if .Values.secretManager.enabled }}
- name: secret-manager
  mountPath: {{ .Values.secretManager.mountPath }}
  readOnly: true
- name: with-secrets
  mountPath: {{ dir .Values.secretManager.loaderPath }}
  readOnly: true
{{- end }}
{{- end -}}

{{- define "rehive-service.volumes" -}}
{{- if .Values.gcloudCredentials.enabled }}
- name: {{ .Values.gcloudCredentials.kubernetesSecret }}
  secret:
    secretName: {{ .Values.gcloudCredentials.kubernetesSecret }}
{{- end }}
{{- if .Values.secretManager.enabled }}
- name: secret-manager
  csi:
    driver: secrets-store-gke.csi.k8s.io
    readOnly: true
    volumeAttributes:
      secretProviderClass: {{ include "rehive-service.secretManager.className" . }}
- name: with-secrets
  configMap:
    name: {{ include "rehive-service.secretManager.loaderName" . }}
    defaultMode: 0555
{{- end }}
{{- end -}}

{{/*
Annotations on the web Deployment that tell rdeploy manage/shell how to run
a one-off pod. Empty when Secret Manager is off.
*/}}
{{- define "rehive-service.deploymentAnnotations" -}}
{{- if .Values.secretManager.enabled }}
rehive.com/entrypoint: {{ .Values.secretManager.loaderPath | quote }}
rehive.com/min-rdeploy: {{ .Values.secretManager.minRdeploy | quote }}
{{- end }}
{{- end -}}
