
{{- define "lifecycle" -}}
  {{- required "REQUIRED: lifecycle" .Values.lifecycle -}}
{{- end }}


{{- define "domain" -}}
  {{- required "REQUIRED: domain" .Values.domain }}
{{- end }}


{{- define "app_domain" -}}
  {{- if eq .Values.lifecycle "prod" }}
    {{- include "domain" . }}
  {{- else }}
    {{- include "lifecycle" $ -}}.{{- include "domain" . }}
  {{- end }}
{{- end }}


{{- define "api_domain" -}}
  {{- if eq .Values.lifecycle "prod" }}
    {{- "api" -}}.{{- include "domain" . -}}
  {{- else }}
    {{- include "lifecycle" $ -}}.api.{{- include "domain" . -}}
  {{- end }}
{{- end }}


{{- define "subdomain" -}}
  {{- if .Values.subdomain -}}
    {{- .Values.subdomain }}.{{- include "domain" $ -}}
  {{- else }}
    {{- include "domain" $ }}
  {{- end }}
{{- end }}


{{- define "full_domain" -}}
  {{- if eq .Values.lifecycle "prod" }}
    {{- include "subdomain" . }}
  {{- else }}
    {{- include "lifecycle" $ -}}.{{- include "subdomain" . -}}
  {{- end }}
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


{{- define "sa_app_label" -}}
  {{- include "lifecycle" $ -}}-{{- required "REQUIRED: app_code" .Values.app_code -}}-{{- .Values.sa_microservice_name }}
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


{{- define "db_project_id" -}}
  {{- if .Values.db_project_id }}
    {{- .Values.db_project_id }}
  {{- else if .Values.project_id }}
    {{- .Values.project_id }}
  {{- else }}
    {{- required "db_project_id" $.Values.db_project_id -}}
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
  {{- if .Values.demo.enabled }}
    {{- .Values.demo.image -}}
  {{- else if .Values.image.name }}
    {{- .Values.image.name -}}
  {{- else -}}
    {{- required "REQUIRED: google.registry" .Values.google.registry -}}/{{- include "app_project_id" . -}}/{{- .Values.app_code -}}/{{- include "registry_name" . -}}/{{- .Values.microservice_name }}
  {{- end -}}
{{- end -}}


{{- define "image" -}}
  {{- include "registry" . -}}:{{- .Values.image.tag }}
{{- end -}}


{{- define "db_name" -}}
  {{- if $.Values.db_name }}
    {{- .Values.db_name }}
  {{- else }}
    {{- include "lifecycle" $ -}}-db
  {{- end }}
{{- end -}}


{{- define "instance_name" -}}
  {{- if $.Values.instance_name }}
    {{- .Values.instance_name }}
  {{- else }}
    {{- .Values.lifecycle -}}-{{- required "REQUIRED: app_code" .Values.app_code -}}-instance
  {{- end }}
{{- end -}}


{{- define "app_admin_sa" -}}
  {{- if $.Values.app_admin_sa }}
    {{- $.Values.app_admin_sa }}
  {{- else }}
    {{- .Values.ksa_name -}}@{{- include "sa_project_id" $ -}}.iam
  {{- end }}
{{- end -}}


{{- define "app_sa" -}}
  {{- if $.Values.app_sa }}
    {{- $.Values.app_sa }}
  {{- else }}
    {{- .Values.ksa_name -}}@{{- include "sa_project_id" $ -}}.iam
  {{- end }}
{{- end -}}


{{- define "ksa_name" -}}
  {{- .Values.ksa_name }}
{{- end -}}


{{- define "deployment_name" -}}
  {{- include "app_label" . }}
{{- end -}}


{{- define "service_name" -}}
  {{- include "app_label" . }}
{{- end -}}


{{- define "ip_name" -}}
  {{- if .Values.ip_name }}
    {{- .Values.ip_name }}
  {{- else }}
    {{- include "app_label" $ -}}-ip
  {{- end }}
{{- end -}}


{{- define "secret_store" -}}
  {{- if .Values.external_secrets.secret_store.name }}
    {{- .Values.external_secrets.secret_store.name }}
  {{- else }}
    {{- .Release.Name -}}-secret-store
  {{- end }}
{{- end }}






