
{{- define "sftpgo.admin_service" -}}
  {{- include "microservice_label" $ -}}-admin
{{- end }}


{{- define "sftpgo.cluster_prefix" -}}
  {{- if ne .Values.cpl_cluster_name .Values.cluster_name }}
    {{- .Values.cluster_name -}}-
  {{- end }}
{{- end }}


{{- define "sftpgo.bucket" -}}
  {{- $name := "" }}
  {{- range .Values.google.storage.bucket_list }}
    {{- if eq .key "SFTP" }}{{- $name = .name }}{{- end }}
  {{- end }}
  {{- include "sftpgo.cluster_prefix" $ -}}{{- include "microservice_label" $ -}}-{{- required "REQUIRED: a google.storage.bucket_list entry with key SFTP" $name }}
{{- end }}


{{- define "sftpgo.admin_username" -}}
  {{- $name := "" }}
  {{- range .Values.env }}
    {{- if eq .name "SFTPGO_DEFAULT_ADMIN_USERNAME" }}{{- $name = .value }}{{- end }}
  {{- end }}
  {{- required "REQUIRED: SFTPGO_DEFAULT_ADMIN_USERNAME in env" $name }}
{{- end }}


{{- define "sftpgo.accounts" -}}
  {{- $cluster := required "REQUIRED: cluster_name" .Values.cluster_name }}
  {{- $lifecycle := required "REQUIRED: lifecycle" .Values.lifecycle }}
  {{- $byLifecycle := index .Values.sftpgo.accounts $cluster }}
  {{- if not (kindIs "map" $byLifecycle) }}
    {{- fail (printf "no sftpgo accounts are declared for cluster %s; add sftpgo.accounts.%s, using an empty list for none" $cluster $cluster) }}
  {{- end }}
  {{- $declared := index $byLifecycle $lifecycle }}
  {{- if not (kindIs "slice" $declared) }}
    {{- fail (printf "no sftpgo accounts are declared for cluster %s, lifecycle %s; use an empty list for none" $cluster $lifecycle) }}
  {{- end }}
  {{- $accounts := list }}
  {{- $seen := dict }}
  {{- range $declared }}
    {{- $username := required "REQUIRED: sftpgo account username" .username | toString }}
    {{- if not (regexMatch "^[a-z0-9][a-z0-9-]{1,61}[a-z0-9]$" $username) }}
      {{- fail (printf "sftpgo account %q: username must be lowercase letters, digits and hyphens" $username) }}
    {{- end }}
    {{- if hasKey $seen $username }}
      {{- fail (printf "sftpgo account %q is declared twice" $username) }}
    {{- end }}
    {{- $_ := set $seen $username true }}
    {{- $keys := .public_keys | default (list) }}
    {{- $password := .password | default false }}
    {{- if and (not $password) (not $keys) }}
      {{- fail (printf "sftpgo account %q needs a password, a public key, or both" $username) }}
    {{- end }}
    {{- if not (hasKey . "org_id") }}
      {{- fail (printf "sftpgo account %q needs an org_id" $username) }}
    {{- end }}
    {{- $org := toString .org_id }}
    {{- if not (regexMatch "^[1-9][0-9]*$" $org) }}
      {{- fail (printf "sftpgo account %q: org_id must be a positive whole number" $username) }}
    {{- end }}
    {{- $accounts = append $accounts (dict "username" $username "key_prefix" (printf "%s/" $org) "password" $password "public_keys" $keys) }}
  {{- end }}
  {{- dict "accounts" $accounts | toJson }}
{{- end }}


{{- define "sftpgo.host_keys_enabled" -}}
  {{- if and .Values.sftpgo.enabled .Values.sftpgo.host_keys.enabled (not .Values.local) }}true{{- end }}
{{- end }}


{{- define "sftpgo.host_keys_dir" -}}
/etc/sftpgo/host-keys
{{- end }}


{{- define "sftpgo.host_key_types" -}}
ed25519 rsa
{{- end }}
