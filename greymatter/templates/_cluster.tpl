{{- define "cluster" }}
{
  "cluster_key": "cluster-{{.serviceName}}",
  "zone_key": "zone-{{.zone}}",
  "name": "{{.serviceName}}",
  "instances": [],
  "circuit_breakers": null,
  "outlier_detection": null,
  "health_checks": [],
  "secret": {
    "secret_key": "secret-{{.serviceName}}-secret",
    "secret_name": "spiffe://deciphernow.com/{{.serviceName}}/mTLS",
    "secret_validation_name": "spiffe://deciphernow.com",
    "subject_names": {{ toJson .authorizedSvids }},
    "ecdh_curves": [
        "X25519:P-256:P-521:P-384"
    ]
  }
}
{{- end }}