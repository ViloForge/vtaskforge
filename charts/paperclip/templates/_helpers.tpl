{{- define "paperclip.fullname" -}}{{ .Release.Name }}{{- end -}}

{{/*
The app.kubernetes.io/name selector-label value. Defaults to the chart name
(paperclip). Selector labels are IMMUTABLE, so a release that predates the
vtaskforge->paperclip rename pins nameOverride to its legacy value (vtaskforge)
to upgrade in place without recreating the StatefulSet (= without data loss).
*/}}
{{- define "paperclip.name" -}}{{ .Values.nameOverride | default "paperclip" }}{{- end -}}

{{- define "paperclip.labels" -}}
app.kubernetes.io/name: {{ include "paperclip.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end -}}
