#!/usr/bin/env sh

MESH_CONFIG_DIR="/etc/config/mesh/"

echo "Configuring mesh from config directory: $MESH_CONFIG_DIR"

cd $MESH_CONFIG_DIR

# In a real environment, we won't just be able to install curl, it will need to be installed beforehand
command -v curl >/dev/null 2>&1 || { echo "This script requires curl to run. Installing..."; apk add curl; echo "done"; }

echo "Waiting for oldtown to come up"

until $(curl --max-time 3 --output /dev/null \
  --silent --head --fail -X GET \
  http://oldtown:5555/v1.0/cluster \
  -H 'Authorization: Bearer xxx'); do
  echo "Waiting ..."
done

echo "Got good response from oldtown"

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
        sleep 0.2
    done

    for file in route-*.json; do
        echo "Creating mesh object: $name."
        greymatter create route <$file
        sleep 0.2
    done

    cd $MESH_CONFIG_DIR
done
