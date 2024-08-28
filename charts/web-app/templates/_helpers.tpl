
{{- define "lifecycle" -}}
  {{- required "REQUIRED: lifecycle" .Values.lifecycle -}}
{{- end }}


{{- define "domain" -}}
  {{- required "REQUIRED: domain" .Values.domain }}
{{- end }}


{{- define "extra_domain" -}}
  {{- if eq .Values.lifecycle "prod" }}
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
  {{- include "lifecycle" $ -}}-{{- required "REQUIRED: app_code" .Values.app_code }}
{{- end }}


{{- define "app_microservice_name" -}}
  {{- required "REQUIRED: app_code" .Values.app_code -}}-{{ required "REQUIRED: microservice_name" .Values.microservice_name }}
{{- end }}


{{- define "microservice_label" -}}
  {{- include "lifecycle" $ -}}-{{- include "app_microservice_name" $ }}
{{- end }}


{{- define "sa_app_label" -}}
  {{- if .Values.sa_microservice_name }}
    {{- required "REQUIRED: app_code" .Values.app_code -}}-{{- .Values.sa_microservice_name }}
  {{- else }}
    {{- required "REQUIRED: app_code" .Values.app_code }}
  {{- end }}
{{- end }}


{{- define "registry_name" -}}
  {{- include "lifecycle" $ -}}
{{- end -}}


{{- define "pubsub_topic_name_suffix" -}}
  {{- if .Values.google.pubsub.add_label }}
    {{- include "microservice_label" $ -}}-topic
  {{- else }}
    {{- include "app_label" $ -}}-topic
  {{- end -}}
{{- end -}}


{{- define "pubsub_topic_name" -}}
  {{- if ne $.Values.cpl_cluster_name $.Values.cluster_name }}
    {{- $.Values.cluster_name -}}-{{- include "pubsub_topic_name_suffix" $ }}
  {{- else }}
    {{- include "pubsub_topic_name_suffix" $ }}
  {{- end -}}
{{- end -}}


{{- define "pubsub_subscription_name_suffix" -}}
  {{- include "pubsub_topic_name" $ -}}-sub
{{- end -}}


{{- define "pubsub_subscription_name" -}}
  {{- if ne $.Values.cpl_cluster_name $.Values.cluster_name }}
    {{- $.Values.cluster_name -}}-{{- include "pubsub_subscription_name_suffix" $ }}
  {{- else }}
    {{- include "pubsub_subscription_name_suffix" $ }}
  {{- end -}}
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


{{- define "cron_image" -}}
  {{- if .Values.deployment.enabled }}
    {{- .Values.cronjob.image.name }}:{{ .Values.cronjob.image.tag }}
  {{- else }}
    {{- include "image" . }}
  {{- end }}
{{- end -}}


{{- define "db_name" -}}
  {{- if $.Values.db_name }}
    {{- include "lifecycle" $ -}}-{{- .Values.db_name -}}-db
  {{- else }}
    {{- include "lifecycle" $ -}}-db
  {{- end }}
{{- end -}}


{{- define "kms_owner_service_label" -}}
  {{- if .Values.google.kms.owner }}
    {{- include "lifecycle" $ -}}-{{- required "REQUIRED: app_code" .Values.app_code -}}-{{- .Values.google.kms.owner }}
  {{- else }}
    {{- include "microservice_label" $ }}
  {{- end }}
{{- end -}}


{{- define "kms_keyring_name" -}}
  {{- include "kms_owner_service_label" $ -}}-keyring
{{- end -}}


{{- define "kms_key_name" -}}
  {{- include "kms_owner_service_label" $ -}}-key
{{- end -}}


{{- define "kms_key_ref" -}}
 projects/{{- include "app_project_id" $ -}}/locations/{{- .Values.google.kms.ring.location -}}/keyRings/{{- include "kms_keyring_name" $ -}}/cryptoKeys/{{- include "kms_key_name" $ -}}
{{- end }}


{{- define "instance_name_suffix" -}}
  {{- if $.Values.instance_name }}
    {{- .Values.instance_name }}
  {{- else }}
    {{- .Values.lifecycle -}}-{{- required "REQUIRED: app_code" .Values.app_code -}}-instance
  {{- end }}
{{- end -}}


{{- define "instance_name" -}}
  {{- if ne $.Values.cpl_cluster_name $.Values.cluster_name }}
    {{- $.Values.cluster_name -}}-{{- include "instance_name_suffix" $ }}
  {{- else }}
    {{- include "instance_name_suffix" $ }}
  {{- end }}
{{- end }}


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


{{- define "pixo_sa_name" -}}
  {{- if .Values.pixo_service_account.name }}
    {{- .Values.pixo_service_account.name }}
  {{- else }}
    {{- include "microservice_label" . }}-service
  {{- end }}
{{- end -}}


{{- define "pixo_sa_org_id" -}}
  {{- required "REQUIRED: pixo_service_account.org_id" .Values.pixo_service_account.org_id }}
{{- end -}}


{{- define "pixo_sa_first_name" -}}
  {{- if .Values.pixo_service_account.first_name }}
    {{- .Values.pixo_service_account.first_name }}
  {{- else }}
    {{- .Values.microservice_name | title }}
  {{- end -}}
{{- end -}}


{{- define "pixo_sa_last_name" -}}
  {{- if .Values.pixo_service_account.last_name }}
    {{- .Values.pixo_service_account.last_name }}
  {{- else }}
    {{- "Service" }}
  {{- end -}}
{{- end -}}


{{- define "deployment_name" -}}
  {{- include "microservice_label" . }}
{{- end -}}


{{- define "pvc_name" -}}
  {{- include "microservice_label" . }}-pvc
{{- end -}}


{{- define "cronjob_name" -}}
  {{- include "microservice_label" . }}
{{- end -}}


{{- define "service_name" -}}
  {{- include "microservice_label" . }}
{{- end -}}


{{- define "ip_name" -}}
  {{- if .Values.ip_name }}
    {{- .Values.ip_name }}
  {{- else }}
    {{- include "microservice_label" $ -}}-ip
  {{- end }}
{{- end -}}


{{- define "secret_store" -}}
  {{- if .Values.external_secrets.secret_store.name }}
    {{- .Values.external_secrets.secret_store.name }}
  {{- else }}
    {{- .Release.Name -}}-secret-store
  {{- end }}
{{- end }}

{{- define "secrets_prefix" -}}
  {{- if .Values.external_secrets.remote_prefix }}
    {{- .Values.external_secrets.remote_prefix -}}-{{- .Values.app_code }}
  {{- else }}
    {{- .Values.app_code }}
  {{- end }}
{{- end }}


{{- define "dockerfile" -}}
  {{- if .Values.debug.enabled }}
    {{- .Values.dockerfile }}.debug
  {{- else }}
    {{- .Values.dockerfile }}
  {{- end }}
{{- end }}


{{- define "custom_storage_pubsub_push_domain" -}}
  {{- if .Values.google.storage.notification_endpoint }}
    {{- .Values.google.storage.notification_endpoint }}
  {{- else }}
    {{- .Values.google.pubsub.subscription.push.custom_endpoint.prefix -}}.{{- include "lifecycle_domain" $ }}
  {{- end }}
{{- end }}



{{- define "workflows_artifact_bucket_suffix" -}}
  {{- if .Values.workflows.artifacts.bucket_prefix }}
    {{- .Values.lifecycle -}}-{{- .Values.workflows.artifacts.bucket_prefix -}}-{{- .Values.workflows.artifacts.bucket_name }}
  {{- else }}
    {{- include "microservice_label" $ -}}-{{- .Values.workflows.artifacts.bucket_name }}
  {{- end }}
{{- end }}

{{- define "workflows_artifact_bucket" -}}
  {{- if ne $.Values.cpl_cluster_name $.Values.cluster_name }}
    {{- $.Values.cluster_name -}}-{{- include "workflows_artifact_bucket_suffix" $ }}
  {{- else }}
    {{- include "workflows_artifact_bucket_suffix" $ }}
  {{- end }}
{{- end }}


{{- define "external_submodule_secret_name" -}}
  {{- .Values.microservice_name -}}-submodule-reader-key
{{- end }}


{{- define "submodule_secret_name" -}}
  {{- include "microservice_label" $ -}}-git-pk
{{- end }}


{{- define "submodule_secret_version_name" -}}
  {{- include "microservice_label" $ -}}-git-pk-v
{{- end }}



