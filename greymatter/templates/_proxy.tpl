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
  "listeners": [],
  "secret": {
    "secret_key": "secret-{{.serviceName}}-secret",
    "secret_name": "spiffe://deciphernow.com/{{.serviceName}}/mTLS",
    "secret_validation_name": "spiffe://deciphernow.com",
    "ecdh_curves": [
        "X25519:P-256:P-521:P-384"
    ]
  }
}
{{- end }}