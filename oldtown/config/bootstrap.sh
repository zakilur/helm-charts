#!/usr/bin/env sh

MESH_CONFIG_DIR="/etc/config/mesh/"

echo "Configuring mesh from config directory: $MESH_CONFIG_DIR"

cd $MESH_CONFIG_DIR

echo "Config dir services:"
ls

# This script expects oldtown to be up and available to serve requests
# Currently, this is handled in a fairly good idiomatic way using Readiness Probes and `k8s-waiter`

echo "Starting mesh configuration ..."

for d in */; do
    echo "Found service: $d"
    cd $d

    # The ordering of creating oldtown resources is extremely important and precise.
    # All objects referenced by keys must be created before being referenced or will result in an error.
    # So we add a delay of 0.1 seconds between each request to hopefully streamline this
    # A better option is probably to hardcode the order of items

    # for fullfile in *.json; do
    #     filename=$(basename -- "$fullfile")
    #     extension="${filename##*.}"
    #     filename="${filename%.*}"

    #     echo "Creating mesh object: $filename."
    #     greymatter create $filename <$fullfile
    # done

    names="cluster listener proxy shared_rules"
    for name in $names; do
        echo "Creating mesh object: $name."
        greymatter create $name <$name.json
        # sleep 0.1
    done

    for file in route-*.json; do
        echo "Creating mesh object: $name."
        greymatter create route <$file
        # sleep 0.1
    done

    cd $MESH_CONFIG_DIR
done
