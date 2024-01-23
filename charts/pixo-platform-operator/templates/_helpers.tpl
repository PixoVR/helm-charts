
{{- define "lifecycle" -}}
  {{- required "REQUIRED: pixoPlatform.lifecycle" .Values.pixoPlatform.lifecycle -}}
{{- end }}

{{- define "manager.imageTag" -}}
    {{- if .Values.manager.image.tag -}}
      {{- .Values.manager.image.tag -}}
    {{- else -}}
      {{- .Chart.AppVersion -}}
    {{- end }}
{{- end  }}