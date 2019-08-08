{{- define "route" }}
{
  "route_key": "route-{{ .route }}",
  "domain_key": "edge",
  "zone_key": "zone-default-zone",
  "path": "/",
  "shared_rules_key": "shared-rules-{{ .serviceName }}",
  "rules": null,
  "response_data": {},
  "cohort_seed": null,
  "retry_policy": null
}
{{- end }}