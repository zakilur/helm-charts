#!/bin/bash
set -xe

#change directory to the directory of the script
cd $(dirname "${BASH_SOURCE[0]}")

# Source environment variables to make connection to gm-control
# . ../gmcli.source

# edge configuration
greymatter create cluster < edge/data2-cluster.json
greymatter create shared_rules < edge/data2-shared_rules.json
greymatter create route < edge/data2-route-1.json
greymatter create route < edge/data2-route-2.json

# sidecar configuration
greymatter create cluster < sidecar/cluster.json
greymatter create domain < sidecar/domain.json
greymatter create listener < sidecar/listener.json
greymatter create proxy < sidecar/proxy.json
greymatter create shared_rules < sidecar/shared_rules.json
greymatter create route < sidecar/route.json

# specials
greymatter create route < special/route-data2-jwt-slash.json
greymatter create route < special/route-data2-jwt.json

echo "Finish populate.sh"