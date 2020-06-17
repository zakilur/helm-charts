#!/bin/sh
# Run from helm-charts/observables directory

make delete-kibana-proxy NAMESPACE=observables-gm

greymatter delete cluster cluster-kibana-observables-proxy-proxy
greymatter delete cluster edge-to-kibana-observables-proxy-proxy-cluster
greymatter delete domain domain-kibana-observables-proxy-proxy
greymatter delete listener listener-kibana-observables-proxy-proxy
greymatter delete proxy proxy-kibana-observables-proxy-proxy
greymatter delete shared_rules shared-rules-kibana-observables-proxy-proxy
greymatter delete shared_rules edge-kibana-observables-proxy-proxy-shared-rules
greymatter delete route route-kibana-observables-proxy-proxy
greymatter delete route edge-kibana-observables-proxy-proxy-route
greymatter delete route edge-kibana-observables-proxy-proxy-route-2


make kibana-proxy NAMESPACE=observables-gm