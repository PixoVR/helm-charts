
{{- define "fullname" -}}
  {{- if .Values.fullname }}
    {{- .Values.fullname }}
  {{- else }}
    {{- .Release.Name -}}-tenant-apps
  {{- end -}}
{{- end -}}



{{- define "app_domain" -}}
  {{- if .Values.domain }}
    {{- .Values.domain }}
  {{- else }}
    {{- "{{ app.domain }}" }}
  {{- end -}}
{{- end -}}



