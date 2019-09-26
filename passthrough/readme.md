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
kubectl port-forward gm-control-api-8d57c6d8d-tqvm8 8088:5555
# greymatter should have the following configs:
#         GREYMATTER_API_HOST=localhost:8088
#         GREYMATTER_API_INSECURE=true
#         GREYMATTER_API_KEY=<redacted>
#         GREYMATTER_API_PREFIX=
#         GREYMATTER_API_SSL=false
#         GREYMATTER_CONSOLE_LEVEL=debug

# edit the passthrough cluster so that require_tls is 'false' instead of 'true'
greymatter edit cluster cluster-passthrough
# test that you can get to the service from edge
# where VOYAGER_EDGE_SERVICE is the value of  `minikube service voyager-edge --https=true`
https://$VOYAGER_EDGE_SERVICE/services/passthrough/latest/get?url=http://google.com/
# the api is here: https://github.com/dgoldstein1/passthough-service#api
```