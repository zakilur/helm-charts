{{- define "sidecar_volume_mounts" }}
volumeMounts:
  # - name: sidecar
  #   mountPath: /etc/proxy/tls/sidecar
  - name: spire-agent-socket
    mountPath: /run/spire/sockets
    readOnly: true
{{- end }}