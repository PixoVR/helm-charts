
{{- define "lifecycle" -}}
  {{- required "REQUIRED: lifecycle" .Values.lifecycle -}}
{{- end }}


{{- define "branch" -}}
  {{- if .Values.branch }}
    {{- .Values.branch }} 
  {{- else }}
    {{- if eq .Values.lifecycle "prod" }}
      {{- .Values.default_branch }}
    {{- else }}
      {{- include "lifecycle" $ -}}
    {{- end }}
  {{- end }}
{{- end }}


{{- define "app_label" -}}
  {{- include "lifecycle" $ -}}-{{- required "REQUIRED: app_code" .Values.app_code -}}-{{ required "REQUIRED: microservice_name" .Values.microservice_name }}
{{- end }}


{{- define "registry_name" -}}
  {{- include "lifecycle" $ -}}
{{- end -}}


{{- define "primary_cluster_name" -}}
  {{- required "REQUIRED: primary_cluster_name" .Values.primary_cluster_name }}
{{- end -}}


{{- define "primary_cluster" -}}
  {{- required "REQUIRED: primary_cluster" .Values.primary_cluster }}
{{- end -}}


{{- define "sa_project_id" -}}
  {{- if .Values.sa_project_id }}
    {{- .Values.sa_project_id }}
  {{- else if .Values.project_id }}
    {{- .Values.project_id }}
  {{- else }}
    {{- required "sa_project_id" $.Values.sa_project_id -}}
  {{- end -}}
{{- end -}}


{{- define "gke_project_id" -}}
  {{- if .Values.gke_project_id }}
    {{- .Values.gke_project_id }}
  {{- else if .Values.project_id }}
    {{- .Values.project_id }}
  {{- else }}
    {{- required "gke_project_id" $.Values.gke_project_id -}}
  {{- end -}}
{{- end -}}


{{- define "app_project_id" -}}
  {{- if .Values.app_project_id }}
    {{- .Values.app_project_id }}
  {{- else if .Values.project_id }}
    {{- .Values.project_id }}
  {{- else }}
    {{- required "app_project_id" $.Values.app_project_id -}}
  {{- end -}}
{{- end -}}


{{- define "registry" -}}
  {{- if .Values.web-app.image.name }}
    {{- .Values.web-app.image.name -}}
  {{- else -}}
    {{- required "REQUIRED: google.registry" .Values.google.registry -}}/{{- include "app_project_id" . -}}/{{- .Values.app_code -}}/{{- include "registry_name" . -}}/{{- .Values.microservice_name }}
  {{- end -}}
{{- end -}}


{{- define "image" -}}
  {{- include "registry" . -}}:{{- .Values.web-app.image.tag }}
{{- end -}}


{{- define "fleet_name" -}}
  {{- include "app_label" . }}
{{- end -}}


{{- define "app_admin_sa" -}}
  {{- if $.Values.app_admin_sa }}
    {{- $.Values.app_admin_sa -}}
  {{- else }}
    {{- .Values.infra.sa_name -}}@{{- include "sa_project_id" $ -}}.iam.gserviceaccount.com
  {{- end }}
{{- end -}}


