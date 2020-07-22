#!/bin/bash

#Helper Function in case of S3
empty_input_check() {
    if [[ -z "$1" ]]; then
        printf '%s\n' "No input entered"
        exit 1
    fi
}

aws() {
    echo -e "\nS3 Access Key:"
    read ACCESS
    empty_input_check $ACCESS
    echo S3 Secret Key:
    read SECRET
    echo AWS Region:
    read REGION
    echo S3 Bucket:
    read BUCKET
}

cd $(dirname "${BASH_SOURCE[0]}")
echo decipher email: 
read EMAIL
echo password:
read -s PASSWORD
echo "Do you wish to configure S3 credentials for gm-data backing [yn] "
read -re yn
TEMPLATE=credentials.template
case $yn in
    [Yy]* ) TEMPLATE=s3credentials.template; aws;;
    [Nn]* ) echo -e "\nSetting S3 to false";;
    * ) echo -e "\nPlease answer yes or no. Defaulting to no S3";;
esac
helm repo add decipher https://nexus.production.deciphernow.com/repository/helm-hosted --username $EMAIL --password $PASSWORD
export EMAIL
export PASSWORD
export ACCESS
export SECRET
export REGION
export BUCKET
envsubst < $TEMPLATE > ../../credentials.yaml
