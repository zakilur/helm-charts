#!/bin/bash
set -xe 

echo "GREYMATTER_API_HOST: $GREYMATTER_API_HOST"
echo "GREYMATTER_API_SSLCERT: $GREYMATTER_API_SSLCERT"
echo "GREYMATTER_API_SSLKEY: $GREYMATTER_API_SSLKEY"

curl -XDELETE https://$GREYMATTER_API_HOST/services/catalog/latest/clusters/REPLACESTRING?zoneName=zone-default-zone --cert $GREYMATTER_API_SSLCERT --key $GREYMATTER_API_SSLKEY -k