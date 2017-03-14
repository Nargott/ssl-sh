#!/bin/bash

#/C=UA/ST=KyivRegion/L=Kyiv/O=AtticLab/OU=Nargott/CN=nargott.pp.ua

if [ "$1" == "" ] || [ "$2" == "" ]; then
    echo "USAGE: $0 clientFileName /C=UA/ST=YourRegion/L=City/O=Company/OU=Owner/CN=SiteUrl"
    exit 0
fi

CLIENT=$1
SUBJ=$2

echo ">>> Create the Client Key and CSR"
openssl genrsa -aes256 -out $CLIENT.key 4096
openssl req -new -key $CLIENT.key -subj $SUBJ -out $CLIENT.csr

echo ">>> Sign client certificate"
openssl ca -config ca.config -in $CLIENT.csr -out $CLIENT.crt -batch

echo ">>> Pack client key and certificate to be used in browsers"
openssl pkcs12 -export -in $CLIENT.crt -inkey $CLIENT.key -certfile ca.crt -out $CLIENT.p12

echo ">>> $0 Done."