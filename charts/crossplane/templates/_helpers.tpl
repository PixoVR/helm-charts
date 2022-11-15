
{{- define "sa_email" }}
  {{- .Values.app-iam.sa_name }}@{{- required "sa_project_id" .Values.project_id -}}.iam.gserviceaccount.com
{{- end }}
