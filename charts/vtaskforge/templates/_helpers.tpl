{{- define "vtaskforge.fullname" -}}{{ .Release.Name }}{{- end -}}

{{- define "vtaskforge.labels" -}}
app.kubernetes.io/name: vtaskforge
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end -}}
