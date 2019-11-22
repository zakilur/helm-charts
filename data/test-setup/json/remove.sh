#!/bin/bash
set -x

#Change directory to the directory of the script
cd $(dirname "${BASH_SOURCE[0]}")

#source environment variables to make connection to gm-control
# . ../gmcli.source

# remove edge configuration
greymatter delete cluster edge-data2-cluster
greymatter delete shared_rules edge-data2-shared-rules
greymatter delete route edge-data2-route
greymatter delete route edge-data2-route-slash

# remove sidecar configuratiotn

greymatter delete cluster data2-service
greymatter delete domain data2
greymatter delete listener data2-listener
greymatter delete proxy data2-proxy
greymatter delete route data2-route
greymatter delete shared_rules data2-shared-rules

# remove special data-jwt configs
greymatter remove route data2-jwt-route-slash
greymatter remove route data2-jwt-route

echo "Finished remove.sh"