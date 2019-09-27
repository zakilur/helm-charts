## testing multi mesh

Steps:

```bash
helm dep up greymatter
helm install greymatter -f greymatter-custom.yaml -f greymatter-custom-secrets.yaml -f greymatter-custom-minikube.yaml --name gm --replace
# wait for things to load.. make sure mesh is working
kubectl apply -f passthrough/passthrough.yaml
# make sure passthrough pods are up
kubectl get pods | grep passthrough
```

we need to make sure that the passthrough sidecar <-> passthrough service communication is not using tls, since dgoldstein1/passthrough doesn't support tls.

```bash
# forward the gm-control-api to your machine
kubectl port-forward gm-control-api-8d57c6d8d-tqvm8 5555:5555
# greymatter should have the following configs:
GREYMATTER_API_HOST=localhost:5555
GREYMATTER_API_INSECURE=true
GREYMATTER_API_KEY=<redacted>
GREYMATTER_API_PREFIX=
GREYMATTER_API_SSL=false
GREYMATTER_CONSOLE_LEVEL=debug

# edit the passthrough cluster so that require_tls is 'false' instead of 'true'
greymatter edit cluster cluster-passthrough
# test that you can get to the service from edge
# where VOYAGER_EDGE_SERVICE is the value of  `minikube service voyager-edge --https=true`
https://$VOYAGER_EDGE_SERVICE/services/passthrough/latest/get?url=http://google.com/
# the api is here: https://github.com/dgoldstein1/passthrough-service#api
```

## Create configs

***Note: the order of these operations are important.***

sidecar => mesh2 cluster, replace with your host and port of mesh2
```json
{
  "cluster_key": "cluster-mesh2",
  "zone_key": "zone-default-zone",
  "name": "mesh2",
  "instances": [
    {
      "host": "192.168.99.108",
      "port": 30275
    }
  ],
  "circuit_breakers": null,
  "outlier_detection": null,
  "health_checks": [],
  "require_tls": true,
  "ssl_config": {
    "cipher_filter": "",
    "protocols": null,
    "cert_key_pairs": [
      {
        "certificate_path": "/etc/proxy/tls/sidecar/server.crt",
        "key_path": "/etc/proxy/tls/sidecar/server.key"
      }
    ],
    "trust_file": "/etc/proxy/tls/sidecar/ca.crt"
  }
}
```
create shared rule tying cluster <-> routes together

```json
{
    "shared_rules_key": "mesh2-shared-rules",
    "name": "mesh2",
    "zone_key": "zone-default-zone",
    "default": {
      "light": [
        {
          "constraint_key": "",
          "cluster_key": "cluster-mesh2",
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
```
add in route for handling slash
```json
{
  "route_key": "passthrough-to-mesh2-slash",
  "domain_key": "domain-passthrough",
  "zone_key": "zone-default-zone",
  "path": "/mesh2",
  "prefix_rewrite": "/mesh2/",
  "redirects": null,
  "shared_rules_key": "mesh2-shared-rules",
  "rules": null,
  "response_data": {},
  "cohort_seed": null,
  "retry_policy": null
}
```
route for passthrough sidecar => mesh2 edge
```json
{
  "route_key": "passthrough-to-mesh2",
  "domain_key": "domain-passthrough",
  "zone_key": "zone-default-zone",
  "path": "/mesh2/",
  "prefix_rewrite": "/",
  "redirects": null,
  "shared_rules_key": "mesh2-shared-rules",
  "rules": null,
  "response_data": {},
  "cohort_seed": null,
  "retry_policy": null
}
```
