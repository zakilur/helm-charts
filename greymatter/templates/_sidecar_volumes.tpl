{{- define "sidecar_volumes" }}
- name: spire-agent-socket
  hostPath:
    path: /run/spire/sockets
    type: Directory
{{- end }}