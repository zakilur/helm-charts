{{- define "cluster" }}
{
  "cluster_key": "cluster-{{.serviceName}}",
  "zone_key": "zone-{{.zone}}",
  "name": "{{.serviceName}}",
  "instances": [],
  "circuit_breakers": null,
  "outlier_detection": null,
  "health_checks": []
}
{{- end }}