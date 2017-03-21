#!/bin/bash

SUBJ=/C=UA/ST=KyivRegion/L=Kyiv/O=AtticLab/OU=Nargott/CN=nargott.pp.ua
CLIENT=client01

echo ">>> Remove old files"
rm -rf *.key
rm -rf *.crt
rm -rf *.csr
rm -rf *.p12

./gen_ca.sh

./gen_server.sh $SUBJ
./gen_client.sh $CLIENT $SUBJ

echo ">>> Done."