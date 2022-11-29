
{{- define "lifecycle" -}}
  {{- required "REQUIRED: lifecycle" .Values.lifecycle -}}
{{- end }}


{{- define "domain" -}}
  {{- required "REQUIRED: domain" .Values.domain }}
{{- end }}



{{- define "extra_domain" -}}
  {{- if or (eq .Values.lifecycle "prod") (not .Values.add_lifecycle_to_domain) }}
    {{- required "REQUIRED: extra_domain" .Values.extra_domain }}
  {{- else }}
    {{- include "lifecycle" $ -}}.{{- required "REQUIRED: extra_domain" .Values.extra_domain }}
  {{- end }}
{{- end }}


{{- define "extra_subdomain" -}}
  {{- if .Values.extra_subdomain }}
    {{- .Values.extra_subdomain }}.{{- include "extra_domain" $ -}}
  {{- else }}
    {{- include "extra_domain" $ -}}
  {{- end }}
{{- end }}


{{- define "lifecycle_domain" -}}
  {{- if or (eq .Values.lifecycle "prod") (not .Values.add_lifecycle_to_domain) }}
    {{- include "domain" . -}}
  {{- else }}
    {{- include "lifecycle" $ -}}.{{- include "domain" . -}}
  {{- end }}
{{- end }}


{{- define "app_domain" -}}
  {{- .Values.app_code -}}.{{- include "lifecycle_domain" . }}
{{- end }}


{{- define "sub_domain" -}}
  {{- if .Values.subdomain }}
    {{- .Values.subdomain -}}.{{- include "app_domain" . }}
  {{- else }}
    {{- include "app_domain" . }}
  {{- end }}
{{- end }}


{{- define "full_domain" -}}
  {{- if or (not .Values.multi_cluster) (eq .Values.cpl_cluster_name .Values.cluster_name) }}
    {{- include "sub_domain" . }}
  {{- else }}
    {{- .Values.cluster_name -}}.{{- include "sub_domain" . }}
  {{- end }}
{{- end }}


{{- define "api_domain" -}}
  {{- if or (not .Values.multi_cluster) (eq .Values.cpl_cluster_name .Values.cluster_name) }}
    {{- "api" -}}.{{- include "app_domain" $ -}}
  {{- else }}
    {{- .Values.cluster_name -}}.{{- "api" -}}.{{- include "app_domain" $ -}}
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
  {{- required "REQUIRED: app_code" .Values.app_code -}}-{{- .Values.sa_microservice_name }}
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
    {{- $.Values.app_admin_sa -}}
  {{- else }}
    {{- .Values.infra.sa_name -}}@{{- include "sa_project_id" $ -}}.iam.gserviceaccount.com
  {{- end }}
{{- end -}}


{{- define "app_sa" -}}
  {{- if $.Values.app_sa }}
    {{- $.Values.app_sa }}
  {{- else if $.Values.sa_microservice_name }}
    {{- include "sa_app_label" $ -}}@{{- include "sa_project_id" $ -}}.iam
  {{- else }}
    {{- .Values.sa_name -}}@{{- include "sa_project_id" $ -}}.iam
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






