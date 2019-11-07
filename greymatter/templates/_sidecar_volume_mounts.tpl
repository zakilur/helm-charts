{{- define "sidecar_volume_mounts" }}
- name: spire-agent-socket
  mountPath: /run/spire/sockets
  readOnly: true
{{- end }}

{{- define "sidecar_volume_certs_mount" }}
- name: sidecar-certs
  mountPath: /etc/proxy/tls/sidecar
  readOnly: true
{{- end }}

{{- define "sidecar_kafka_volume_certs_mount" }}
- name: kafka-certs
  mountPath: /etc/proxy/tls/kafka
  readOnly: true
{{- end }}