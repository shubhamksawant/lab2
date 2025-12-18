{{/* Common chart helpers */}}
{{- define "gitops-safe-copy.fullname" -}}
{{- printf "%s-%s" .Release.Name .Chart.Name | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "gitops-safe-copy.labels" -}}
app.kubernetes.io/name: {{ include "gitops-safe-copy.fullname" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- with .Values.labels }}
{{ toYaml . | nindent 0 }}
{{- end -}}
{{- end -}}
