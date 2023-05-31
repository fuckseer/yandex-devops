#!/bin/bash

#variables in env file
if [ -f ".env" ]; then
    export $(grep -v '^#' .env | xargs)
fi

if ! [ "${ADS_APP_REPOSITORY}" ]; then
    echo "ADS_APP_REPOSITORY is not set!"
    exit 1
fi


if ! [ "${ADS_APP_CONTAINER_ID}" ]; then
    echo "ADS_APP_CONTAINER_ID is not set!"
    exit 1
fi

if ! [ "${ENDPOINT}" ]; then
    echo "ENDPOINT is not set!"
    exit 1
fi

if ! [ "${DB}" ]; then
    echo "DB is not set!"
    exit 1
fi

if ! [ "${SERVICE_ACCOUNT_ID}" ]; then
    echo "SERVICE_ACCOUNT_ID is not set!"
    exit 1
fi

ADS_APP_REPOSITORY=$(echo $ADS_APP_REPOSITORY | tr -d '\r')
ADS_APP_CONTAINER_ID=$(echo $ADS_APP_CONTAINER_ID | tr -d '\r')
ENDPOINT=$(echo $ENDPOINT | tr -d '\r')
DB=$(echo $DB | tr -d '\r')
SERVICE_ACCOUNT_ID=$(echo $SERVICE_ACCOUNT_ID | tr -d '\r')


current_version=$(cat .version);
next_version=`echo $current_version | awk -F. -v OFS=. 'NF==1{print ++$NF}; NF>1{if(length($NF+1)>length($NF))$(NF-1)++; $NF=sprintf("%0*d", length($NF), ($NF+1)%(10^length($NF))); print}'`;
echo $next_version > .version;
new_image_name=${ADS_APP_REPOSITORY}:${next_version};
echo $new_image_name;
docker build -t $new_image_name . ;
docker push $new_image_name;

yc sls container revisions deploy \
    --container-id ${ADS_APP_CONTAINER_ID} \
    --memory 128M \
    --cores 1 \
    --execution-timeout 5s \
    --concurrency 4 \
    --environment  ENDPOINT=${ENDPOINT},DB=${DB} \
    --service-account-id ${SERVICE_ACCOUNT_ID} \
    --image "$new_image_name";