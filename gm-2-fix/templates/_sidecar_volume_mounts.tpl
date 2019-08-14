{{- define "sidecar_volume_mounts" }}
- name: spire-config
  mountPath: /run/spire/config
  readOnly: true
- name: spire-agent-socket
  mountPath: /run/spire/sockets
  readOnly: false
{{- end }}