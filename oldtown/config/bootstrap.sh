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

echo "Waiting for 10 seconds"
sleep 10
echo "Done. Starting mesh configuration ..."

for d in */; do
    echo "Found service: $d"
    cd $d

    for fullfile in *.json; do
        filename=$(basename -- "$fullfile")
        extension="${filename##*.}"
        filename="${filename%.*}"

        echo "Creating mesh object: $filename."
        greymatter create $filename <$fullfile
    done

    cd $MESH_CONFIG_DIR
done
