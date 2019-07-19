{{- define "listener" }}
{
  "listener_key": "listener-{{.serviceName}}",
  "zone_key": "zone-{{.zone}}",
  "name": "{{.serviceName}}",
  "ip": "0.0.0.0",
  "port": {{ .port | default 8080 }},
  "protocol": "http_auto",
  "domain_keys": ["domain-*"],
  "tracing_config": null
}
{{- end }}