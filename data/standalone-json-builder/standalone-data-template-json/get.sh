#!/usr/bin/env bash
# set -ex

# GET edge configuration
greymatter get cluster edge-REPLACESTRING-cluster
greymatter get shared_rules edge-REPLACESTRING-shared-rules
greymatter get route edge-REPLACESTRING-route-slash
greymatter get route sidecar-REPLACESTRING-route-slash

# GET sidecar configuratiotn

greymatter get cluster REPLACESTRING-service
greymatter get domain REPLACESTRING
greymatter get listener REPLACESTRING-listener
greymatter get proxy REPLACESTRING-proxy
greymatter get route REPLACESTRING-route
greymatter get shared_rules REPLACESTRING-shared-rules

# GET special data-jwt configs
greymatter get route REPLACESTRING-jwt-route-slash
greymatter get route REPLACESTRING-jwt-route

echo "finish get.sh"
