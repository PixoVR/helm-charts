
{{- define "sa_project_id" -}}
  {{- if .Values.sa_project_id }}
    {{- .Values.sa_project_id }}
  {{- else if .Values.project_id }}
    {{- .Values.project_id }}
  {{- else }}
    {{- required "REQUIRED: sa_project_id" $.Values.sa_project_id -}}
  {{- end -}}
{{- end -}}


{{- define "gke_project_id" -}}
  {{- if .Values.gke_project_id }}
    {{- .Values.gke_project_id }}
  {{- else if .Values.project_id }}
    {{- .Values.project_id }}
  {{- else }}
    {{- required "REQUIRED: gke_project_id" $.Values.gke_project_id -}}
  {{- end -}}
{{- end -}}


{{- define "db_project_id" -}}
  {{- if .Values.db_project_id }}
    {{- .Values.db_project_id }}
  {{- else if .Values.project_id }}
    {{- .Values.project_id }}
  {{- else }}
    {{- required "REQUIRED: db_project_id" $.Values.db_project_id -}}
  {{- end -}}
{{- end -}}


{{- define "app_project_id" -}}
  {{- if .Values.app_project_id }}
    {{- .Values.app_project_id }}
  {{- else if .Values.project_id }}
    {{- .Values.project_id }}
  {{- else }}
    {{- required "REQUIRED: app_project_id" $.Values.app_project_id -}}
  {{- end -}}
{{- end -}}


{{- define "sa_name" -}}
  {{- if .Values.sa_name }}
    {{- .Values.sa_name }}
  {{- else }}
    {{- required "REQUIRED: app.ksa_name" $.Values.app.ksa_name -}}
  {{- end -}}
{{- end -}}


{{- define "infra_sa_name" -}}
  {{- if .Values.sa_name }}-infra
    {{- .Values.sa_name }}-infra
  {{- else }}
    {{- required "REQUIRED: infra.ksa_name" $.Values.infra.ksa_name -}}
  {{- end -}}
{{- end -}}
