#!/usr/bin/env sh

MESH_CONFIG_DIR="/etc/config/mesh/"

echo "Configuring mesh from config directory: $MESH_CONFIG_DIR"

cd $MESH_CONFIG_DIR

# echo "Listing environment ... "
# env

echo "Waiting for oldtown to come up"

until nslookup oldtown; do
    echo "Waiting for oldtown"
    sleep 2
done

echo "Oldtown has been found"

wait=8
echo "Waiting for $wait seconds"
sleep $wait

echo "Done. Starting mesh configuration ..."

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

    names="cluster listener proxy shared_rules route"
    for name in $names; do
        echo "Creating mesh object: $name."
        greymatter create $name <$name.json
        sleep 0.01
    done

    cd $MESH_CONFIG_DIR
done
