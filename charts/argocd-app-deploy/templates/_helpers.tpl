
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
    {{- .Values.pre_tenant_services_filepath -}}/{{ "{{ path.basename }}" }}/{{- .Values.post_tenant_services_filepath -}}
  {{- end -}}
{{- end -}}



