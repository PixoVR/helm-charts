
{{- define "fullname" -}}
  {{- if .Values.fullname }}
    {{- .Values.fullname }}
  {{- else }}
    {{- .Release.Name -}}-tenant-apps
  {{- end -}}
{{- end -}}


{{- define "services_filepath" -}}
  {{- if .Values.services_filepath }}
    {{- .Values.services_filepath }}
  {{- else }}
    {{- .Values.pre_tenant_services_filepath -}}/{{- required "app_name" .Values.app_name -}}/{{- .Values.post_tenant_services_filepath -}}/{{- .Values.lifecycle -}}-{{- .Values.post_tenant_services_filename }}
  {{- end -}}
{{- end -}}


{{- define "deploy_namespace" -}}
  {{- if .Values.app.namespace }}
    {{- .Values.app.namespace }}
  {{- else }}
    {{- .Values.lifecycle -}}-{{- .Values.app_name -}}
  {{- end -}}
{{- end -}}


{{- define "infra_namespace" -}}
  {{- if .Values.infra.namespace }}
    {{- .Values.infra.namespace }}
  {{- else }}
    {{- include "deploy_namespace" $ -}}
  {{- end -}}
{{- end -}}


{{- define "iam_namespace" -}}
  {{- if .Values.iam.namespace }}
    {{- .Values.iam.namespace }}
  {{- else }}
    {{- include "infra_namespace" $ -}}
  {{- end -}}
{{- end -}}


