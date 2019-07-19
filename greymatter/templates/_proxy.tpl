{{- define "proxy" }}
{
  "proxy_key": "proxy-{{.serviceName}}",
  "zone_key": "zone-{{.zone}}",
  "name": "{{.serviceName}}",
  "domain_keys": [
    "domain-*"
  ],
  "listener_keys": [
      "listener-{{.serviceName}}"
  ],
  "listeners": []
}
{{- end }}