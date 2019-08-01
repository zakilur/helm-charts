{{- define "sidecar_volumes" }}
volumes:
  - name: sidecar
    secret:
      secretName: sidecar
  - name: spire-agent-socket
    hostPath:
      path: /run/spire/sockets
      type: Directory
{{- end }}