{{- define "sidecar_volumes" }}
- name: spire-config
  configMap:
    name: spire-agent
- name: spire-agent-socket
  emptyDir: {}
{{- end }}