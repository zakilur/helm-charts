{{- define "shared_rules" }}
{
  "shared_rules_key": "shared-rules-{{.serviceName}}",
  "name": "{{.serviceName}}",
  "zone_key": "zone-{{.zone}}",
  "default": {
    "light": [
      {
        "constraint_key": "",
        "cluster_key": "cluster-{{.serviceName}}",
        "metadata": null,
        "properties": null,
        "response_data": {},
        "weight": 1
      }
    ],
    "dark": null,
    "tap": null
  },
  "rules": null,
  "response_data": {},
  "cohort_seed": null,
  "properties": null,
  "retry_policy": null
}
{{- end }}