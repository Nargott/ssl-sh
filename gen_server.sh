#!/bin/bash

if [ "$1" == "" ]; then
    echo "USAGE: $0 /C=UA/ST=YourRegion/L=City/O=Company/OU=Owner/CN=SiteUrl [filename]"
    exit 0
fi

if [ "$2" == "" ]; then
    FILENAME="server"
else
    FILENAME="$2"
fi

echo "Filename is $FILENAME"

SUBJ=$1

OLD_SERIAL=$(<db/serial)
NEW_SERIAL=$((0x$old_serial+1))

#SUBJ = /C=UA/ST=KyivRegion/L=Kyiv/O=AtticLab/OU=Nargott/CN=nargott.pp.ua

echo ">>> Create the Server Key CSR and Certificate"
openssl genrsa -aes256 -out $FILENAME.key 4096
openssl req -new -key $FILENAME.key -subj $SUBJ -out $FILENAME.csr

echo ">>> Self Signing"
openssl x509 -req -days 365 -in $FILENAME.csr -CA ca.crt -CAkey ca.key -set_serial 01 -out $FILENAME.crt

echo ">>> Remove password from server key"
openssl rsa -in $FILENAME.key -out $FILENAME.nopass.key

echo $NEW_SERIAL > db/serial

echo ">>> $0 Done."