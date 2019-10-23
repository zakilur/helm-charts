# Greymatter CLI

## Prerequisites

- Grey Matter installed into an OpenShift cluster
- Grey Matter CLI

### Interact with the Control API

Download and install the cli

export GREYMATTER_CONSOLE_LEVEL=debug
export GREYMATTER_API_HOST=localhost:5555
export GREYMATTER_API_KEY=xxx
export GREYMATTER_API_SSL=false
export GREYMATTER_API_INSECURE=true
export EDITOR=vim

oc port-forward $(oc get pods --template '{{range .items}}{{.metadata.name}}{{"\n"}}{{end}}' | grep ^gm-control-api) 5555

### Edge Admin UI + Container

oc port-forward $(oc get pods --template '{{range .items}}{{.metadata.name}}{{"\n"}}{{end}}' | grep ^edge) 8001:8001

oc exec -it $(oc get pods --template '{{range .items}}{{.metadata.name}}{{"\n"}}{{end}}' | grep ^edge) /bin/sh

### Observables

greymatter edit proxy -proxyid-

"gm_observables": {
    "emitFullResponse": false,
    "useKafka": true,
    "eventTopic": "fabric",
    "enforceAudit": false,
    "topic": "edge-oauth",
    "kafkaZKDiscover": false,
    "kafkaServerConnection": "kafka-default.fabric.svc:9092"
}

### Handy oc commands

oc create clusterrolebinding admin --clusterrole cluster-admin --user admin 

oc get events