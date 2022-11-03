
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


{{- define "app_project" -}}
  {{- required "REQUIRED: project_id" .Values.project_id }}
{{- end -}}


{{- define "registry" -}}
  {{- if .Values.demo.enabled }}
    {{- .Values.demo.image -}}
  {{- else if .Values.image.name }}
    {{- .Values.image.name -}}
  {{- else -}}
    {{- required "REQUIRED: google.registry" .Values.google.registry -}}/{{- include "app_project" . -}}/{{- .Values.app_code -}}/{{- include "registry_name" . -}}/{{- .Values.microservice_name }}
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
  {{- if $.Values.sa }}
    {{- $.Values.app_sa }}
  {{- else }}
    {{- required "REQUIRED: app_code" .Values.app_code -}}-admin@{{- include "sa_project_id" . -}}.iam.gserviceaccount.com
  {{- end }}
{{- end -}}


{{- define "cicd_sa" -}}
  {{- "projects/" -}}{{- include "app_project" $ }}/serviceAccounts/{{- include "app_label" $ -}}-cicd@{{- include "app_project" . }}.iam.gserviceaccount.com
{{- end -}}


{{- define "app_sa" -}}
  {{- if $.Values.sa }}
    {{- $.Values.app_sa }}
  {{- else if $.Values.sa_microservice_name }}
    {{- include "sa_app_label" $ -}}-iam-workload@{{- include "app_project" . -}}.iam
  {{- else }}
    {{- include "app_label" $ -}}-iam-workload@{{- include "app_project" . -}}.iam
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


{{- define "bucket" -}}
  {{- include "app_label" $ -}}-v2-web-static
{{- end -}}


{{- define "ingest_bucket" -}}
  {{- include "app_label" $ -}}-v2-ingest
{{- end -}}


{{- define "clean_data_bucket" -}}
  {{- include "app_label" $ -}}-v2-cleaned-data
{{- end -}}


{{- define "ip_name" -}}
  {{- if .Values.ip_name }}
    {{- .Values.ip_name }}
  {{- else }}
    {{- include "app_label" $ -}}-ip
  {{- end }}
{{- end -}}


{{- define "cluster_secret_store" -}}
  {{- if .Values.external_secrets.cluster_secret_store.name }}
    {{- .Values.external_secrets.cluster_secret_store.name }}
  {{- else }}
    {{- "cluster" -}}-secret-store
  {{- end }}
{{- end }}


{{- define "secret_store" -}}
  {{- if .Values.external_secrets.secret_store.name }}
    {{- .Values.external_secrets.secret_store.name }}
  {{- else }}
    {{- .Release.Name -}}-secret-store
  {{- end }}
{{- end }}






