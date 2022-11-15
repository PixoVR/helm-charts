
{{- define "sa_email" }}
  {{- .Values.app_iam.sa_name -}}@{{- required "app_iam.sa_project_id" .Values.app_iam.sa_project_id -}}.iam.gserviceaccount.com
{{- end }}
