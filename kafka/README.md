# Install Kafka For "Full" Setup

This directory contains the files needed to install kafka with 3 brokers with a sidecar for each broker.  This will follow the pattern described in the full setup.

TODO: add image of diagram here.

## Steps

1. Create kafka namespace and add secrets

    ```bash
    kubectl create namespace kafka
    kubectl get secret docker.secret --export -o yaml | kubectl apply --namespace=kafka -f -
    kubectl get secret sidecar-certs --export -o yaml | kubectl apply --namespace=kafka -f -
    ```

    TODO: add `kafka` namespace to control

2. Install kafka/sidecars

    ```bash
    kubectl apply -f kafka/configmap-b0.yaml
    kubectl apply -f kafka/configmap-b1.yaml
    kubectl apply -f kafka/configmap-b2.yaml
    kubectl apply -f kafka/svc-b0.yaml
    kubectl apply -f kafka/svc-b1.yaml
    kubectl apply -f kafka/svc-b2.yaml
    kubectl apply -f kafka/kafka_template.yaml -n kafka
    ```

3. Install coughka deployment for testing

Run a kafka client and create any topics - by default in coughka we're using coughka-test-topic, so:

```bash
kubectl run kafka-observables-client --rm --tty -i --restart='Never' --image docker.io/bitnami/kafka:2.4.0-debian-9-r22 --namespace kafka --command -- bash
```

and then:

```bash
kafka-topics.sh --create --bootstrap-server kafka-broker-1.kafka.svc.cluster.local:9093 --topic coughka-test-topic
```

Now configure the mesh for the incoming coughka/sidecar combo:

```bash
cd kafka/coughka/mesh
for cl in clusters/*.json; do greymatter create cluster < $cl; done
for cl in domains/*.json; do greymatter create domain < $cl; done
for cl in listeners/*.json; do greymatter create listener < $cl; done
for cl in proxies/*.json; do greymatter create proxy < $cl; done
for cl in rules/*.json; do greymatter create shared_rules < $cl; done
for cl in routes/*.json; do greymatter create route < $cl; done
cd ../../..
```

```bash
kubectl apply -f kafka/coughka/coughka-deployment.yaml
```

Once everything is running, there should be no errors in the coughka container logs.  You can use a consumer to check the messages or go to `services/coughka/published` to see the list of messages being published by the coughka service and `/services/coughka/subscribed` to see the list of messages being consumed by the coughka service.
