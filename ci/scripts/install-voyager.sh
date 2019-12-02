#!/bin/bash
cd $(dirname "${BASH_SOURCE[0]}")
export PROVIDER=minikube
helm repo add appscode https://charts.appscode.com/stable/
helm repo update
helm fetch appscode/voyager --version 11.0.1
tar -xzf voyager-v11.0.1.tgz
patch ./voyager/templates/deployment.yaml deployment.patch
helm template voyager voyager \
  --namespace kube-system \
  --set cloudProvider=$PROVIDER \
  --set enableAnalytics=false \
  --set apiserver.enableAdmissionWebhook=false \
  > manifest.yaml
kubectl apply -f manifest.yaml
while [[ $(kubectl get pods -n kube-system -l app=voyager -o 'jsonpath={..status.conditions[?(@.type=="Ready")].status}') != "True" ]]; do echo "waiting for pod" && sleep 10; done
rm -rf voyager