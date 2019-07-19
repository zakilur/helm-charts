{{- define "mesh_svc_config" }}
apiVersion: v1
kind: ConfigMap
metadata:
  name: {{.serviceName}}-mesh-config
  namespace: default
  mesh-config: {{.serviceName}}
data:
  {{.serviceName}}-cluster.json: |
    {{- include "cluster" . | indent 4 }}
  {{.serviceName}}-listener.json: |
    {{- include "listener" . | indent 4 }}
  {{.serviceName}}-proxy.json: |
    {{- include "proxy" . | indent 4 }}
  shared-rules-{{.serviceName}}.json: |
    {{- include "shared-rules" . | indent 4 }}
  route-{{.serviceName}}.json: |
    {{- include "route" . | indent 4 }}
  route-{{.serviceName}}-2.json: |
  {{- /*{{- $a := list (dir .route) (base .route)}}
  {{$a}} */}}
    {{- $b := dict "route"  (dir .route) }}
    {{- $c := merge $b .  }}
    {{- include "route" $c | indent 4 }}
{{- end }}