#!/usr/bin/env sh

MESH_CONFIG_DIR="/etc/config/mesh/"

echo "Configuring mesh from config directory: $MESH_CONFIG_DIR"

cd $MESH_CONFIG_DIR

# DECIPHER_GREYMATTER_CLI_PREFIX="GREYMATTER"

# echo "Using Decipher Greymatter CLI: $DECIPHER_GREYMATTER_CLI_PREFIX"
# echo "Setting up environment ..."

echo "Listing environment ... "
env

echo "Waiting for oldtown to come up"

until nslookup oldtown; do
    echo "Waiting for oldtown"
    sleep 2
done

echo "Oldtown has been found"
# export ${DECIPHER_GREYMATTER_CLI_PREFIX}_CONSOLE_LEVEL=debug
# export ${DECIPHER_GREYMATTER_CLI_PREFIX}_API_HOST=localhost:5555
# export ${DECIPHER_GREYMATTER_CLI_PREFIX}_API_KEY=xxx
# export ${DECIPHER_GREYMATTER_CLI_PREFIX}_API_SSL=false

# greymatter create "$1"

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
