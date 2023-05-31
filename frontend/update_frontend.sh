#!/bin/bash

#variables in env file
if [ -f ".env" ]; then
    export $(grep -v '^#' .env | xargs)
fi

if ! [ "${ADS_APP_BUCKET}" ]; then
    echo "ADS_APP_BUCKET is not set!"
    exit 1
fi

current_version=$(cat js/version.js |  cut -d "=" -f 2 | cut -d "'" -f 2)

echo $current_version

next_version=`echo $current_version | awk -F. -v OFS=. 'NF==1{print ++$NF}; NF>1{if(length($NF+1)>length($NF))$(NF-1)++; $NF=sprintf("%0*d", length($NF), ($NF+1)%(10^length($NF))); print}'`;
echo "const FRONTEND_VERSION='$next_version';" > js/version.js;

s3cmd sync ./ --exclude '.env' s3://${ADS_APP_BUCKET}
s3cmd --recursive modify --add-header=content-type:application/javascript  s3://${ADS_APP_BUCKET}/js/
s3cmd --recursive modify --add-header=content-type:text/css  s3://${ADS_APP_BUCKET}/css/