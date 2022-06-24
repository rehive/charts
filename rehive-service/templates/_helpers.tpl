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
helm.sh/chart: {{ include "rehive-service.chart" . }}
helm.sh/release: {{ include "rehive-service.fullname" . }}
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
