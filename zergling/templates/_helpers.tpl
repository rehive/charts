{{/* vim: set filetype=mustache: */}}
{{/*
Expand the name of the chart.
*/}}
{{- define "zergling.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "zergling.fullname" -}}
{{- $name := default .Chart.Name .Values.nameOverride -}}
{{- if contains $name .Release.Name -}}
{{- .Release.Name | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "zergling.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Common labels
*/}}
{{- define "zergling.labels" -}}
app.kubernetes.io/name: {{ include "zergling.name" . }}
helm.sh/chart: {{ include "zergling.chart" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/component: server
rehive.io/environment: {{ .Values.environment }}
release: {{ .Release.Name }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end -}}


{{/*
Environment Variables
*/}}
{{- define "zergling.plugins" -}}
{{- if .Values.postgres.enabled }}
- name: POSTGRES_HOST
  value: {{ .Values.postgres.host }}
- name: POSTGRES_PORT
  value: {{ .Values.postgres.port | quote }}
- name: POSTGRES_USER
  value: {{ .Values.postgres.user }}
- name: POSTGRES_PASSWORD
  valueFrom:
    secretKeyRef:
      name: {{ .Values.postgres.secret.name }}
      key: {{ .Values.postgres.secret.key }}
{{- end }}
{{- if .Values.continuousDeployment.enabled }}
- name: REPOSITORY_IMAGE
  value: {{ .Values.continuousDeployment.repository }}
- name: REPOSITORY_TAG
  value: {{ .Values.continuousDeployment.tag }}
{{- end }}
{{- if .Values.rabbitmq.enabled }}
- name: RABBITMQ_HOST
  value: {{ .Values.rabbitmq.host }}
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
{{- end -}}

