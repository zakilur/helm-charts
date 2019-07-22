{{- define "mesh_svc_config" }}
apiVersion: v1
kind: ConfigMap
metadata:
  name: {{.serviceName}}-mesh-config
  namespace: default
  mesh-config: {{.serviceName}}
data:
  cluster.json: |
    {{- include "cluster" . | indent 4 }}
  listener.json: |
    {{- include "listener" . | indent 4 }}
  proxy.json: |
    {{- include "proxy" . | indent 4 }}
  shared_rules.json: |
    {{- include "shared_rules" . | indent 4 }}
  {{- $top := . }}
  {{- range $index, $route := .routes }}
  route-{{$index}}.json: |
     {{- include "route" (dict "serviceName" $top.serviceName "route" (tpl $route $top.top)) | indent 4 }}
  {{- end }}
{{- end }}