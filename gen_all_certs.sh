#!/bin/bash

SUBJ=/C=UA/ST=KyivRegion/L=Kyiv/O=AtticLab/OU=Nargott/CN=nargott.pp.ua
CLIENT=client01

echo ">>> Remove old files"
rm -rf *.key
rm -rf *.crt
rm -rf *.csr
rm -rf *.p12

echo ">>> CA Key and Certificate"
openssl genrsa -aes256 -out ca.key 4096
openssl req -new -x509 -days 365 -key ca.key -subj $SUBJ -out ca.crt
openssl rsa -in ca.key -out ca.key

echo ">>> Dirs"
rm -rf db
mkdir db
mkdir db/certs
mkdir db/newcerts
touch db/index.txt
echo "02" > db/serial

./gen_server.sh $SUBJ
./gen_client.sh $CLIENT $SUBJ

echo ">>> Done."