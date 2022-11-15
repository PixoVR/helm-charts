
{{- define "sa_project_id" -}}
  {{- if .Values.sa_project_id }}
    {{- .Values.sa_project_id }}
  {{- else if .Values.project_id }}
    {{- .Values.project_id }}
  {{- else }}
    {{- required "sa_project_id or project_id" $.Values.sa_project_id -}}
  {{- end -}}
{{- end -}}


{{- define "gke_project_id" -}}
  {{- if .Values.gke_project_id }}
    {{- .Values.gke_project_id }}
  {{- else if .Values.project_id }}
    {{- .Values.project_id }}
  {{- else }}
    {{- required "gke_project_id or project_id" $.Values.gke_project_id -}}
  {{- end -}}
{{- end -}}


{{- define "app_project_id" -}}
  {{- if .Values.app_project_id }}
    {{- .Values.app_project_id }}
  {{- else if .Values.project_id }}
    {{- .Values.project_id }}
  {{- else }}
    {{- required "app_project_id or project_id" $.Values.app_project_id -}}
  {{- end -}}
{{- end -}}


{{- define "sa_email" -}}
  {{- if .Values.config_connector.sa_email }}
    {{- .Values.config_connector.sa_email }}
  {{- else if .Values.sa_project_id }}
    {{- .Values.config_connector.sa_name -}}@{{- .Values.sa_project_id -}}.iam.gserviceaccount.com
  {{- else }}
    {{- .Values.config_connector.sa_name -}}@{{- required "sa_project_id OR config_connector.sa_project_id" .Values.config_connector.sa_project_id -}}.iam.gserviceaccount.com
  {{- end -}}
{{- end -}}



