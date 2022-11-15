
{{- define "sa_email" }}
  {{- .Values.app-iam.sa_name -}}@{{- required "app-iam.sa_project_id" .Values.app-iam.sa_project_id -}}.iam.gserviceaccount.com
{{- end }}
