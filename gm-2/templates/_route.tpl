{{- define "route" }}
{
  "route_key": "route-{{ .route }}",
  "domain_key": "domain-*",
  "zone_key": "zone-default-zone",
  "path": {{ .route | quote }},
  "prefix_rewrite": "/",
  "shared_rules_key": "shared-rules-{{ .serviceName }}",
  "rules": null,
  "response_data": {},
  "cohort_seed": null,
  "retry_policy": null
}
{{- end }}