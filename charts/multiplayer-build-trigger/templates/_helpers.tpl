
{{- define "label" -}}
  {{- if .Values.lifecycle }}
    {{- .Values.lifecycle -}}-{{- required "trigger_id is required" .Values.trigger_id }}
  {{- else }}
    {{- required "trigger_id is required" .Values.trigger_id }}
  {{- end }}
{{- end }}

{{- define "domain" -}}
  {{ "es" }}-{{- .Values.trigger_id -}}.{{- required "REQUIRED: event_source_domain" .Values.event_source_domain }}
{{- end -}}