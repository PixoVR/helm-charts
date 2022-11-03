
{{- define "project_id" -}}
  {{- required "REQUIRED: project_id " $.Values.project_id -}}
{{- end -}}

{{- define "sa_name" -}}
  {{- if .Values.sa_name }}
    {{- .Values.sa_name }}
  {{- else }}
    {{- .Release.Name -}}-workload
  {{- end -}}
{{- end -}}



