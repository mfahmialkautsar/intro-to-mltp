{{/*
Expand the name of the chart.
*/}}
{{- define "grafana-mltp-stack.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "grafana-mltp-stack.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Chart.Name .Values.nameOverride }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "grafana-mltp-stack.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "grafana-mltp-stack.labels" -}}
helm.sh/chart: {{ include "grafana-mltp-stack.chart" . }}
{{ include "grafana-mltp-stack.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
app.kubernetes.io/part-of: grafana-mltp-stack
{{- end }}

{{/*
Selector labels
*/}}
{{- define "grafana-mltp-stack.selectorLabels" -}}
app.kubernetes.io/name: {{ include "grafana-mltp-stack.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "grafana-mltp-stack.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "grafana-mltp-stack.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
Create component labels
*/}}
{{- define "grafana-mltp-stack.componentLabels" -}}
{{- $component := . -}}
app.kubernetes.io/component: {{ $component }}
{{- end }}

{{/*
Create component selector labels
*/}}
{{- define "grafana-mltp-stack.componentSelectorLabels" -}}
{{- $root := index . 0 -}}
{{- $component := index . 1 -}}
app.kubernetes.io/name: {{ include "grafana-mltp-stack.name" $root }}
app.kubernetes.io/instance: {{ $root.Release.Name }}
app.kubernetes.io/component: {{ $component }}
{{- end }}

{{/*
Create security context
*/}}
{{- define "grafana-mltp-stack.securityContext" -}}
{{- with .Values.securityContext }}
securityContext:
  {{- toYaml . | nindent 2 }}
{{- end }}
{{- end }}

{{/*
Create pod security context
*/}}
{{- define "grafana-mltp-stack.podSecurityContext" -}}
{{- with .Values.podSecurityContext }}
securityContext:
  {{- toYaml . | nindent 2 }}
{{- end }}
{{- end }}

{{/*
Create node selector
*/}}
{{- define "grafana-mltp-stack.nodeSelector" -}}
{{- with .Values.global.nodeSelector }}
nodeSelector:
  {{- toYaml . | nindent 2 }}
{{- end }}
{{- end }}

{{/*
Create tolerations
*/}}
{{- define "grafana-mltp-stack.tolerations" -}}
{{- with .Values.global.tolerations }}
tolerations:
  {{- toYaml . | nindent 2 }}
{{- end }}
{{- end }}

{{/*
Create affinity
*/}}
{{- define "grafana-mltp-stack.affinity" -}}
{{- with .Values.global.affinity }}
affinity:
  {{- toYaml . | nindent 2 }}
{{- end }}
{{- end }}

{{/*
Create image pull secrets
*/}}
{{- define "grafana-mltp-stack.imagePullSecrets" -}}
{{- with .Values.imagePullSecrets }}
imagePullSecrets:
  {{- toYaml . | nindent 2 }}
{{- end }}
{{- end }}
