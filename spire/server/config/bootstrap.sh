#!/usr/bin/env sh

cd $(dirname $0)

mkdir -p $(dirname $REGISTRATION_API_PATH)

echo "Starting setup script"
./setup.sh &
echo "Successfully forked to background"

echo "Starting SPIRE server with configuration file: $CONFIG_FILE_PATH"
/opt/spire/bin/spire-server run -config $CONFIG_FILE_PATH