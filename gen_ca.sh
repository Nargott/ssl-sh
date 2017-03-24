#!/bin/bash

if [ "$1" == "" ] || [ "$2" == "" ] || [ "$3" == "" ]; then
    echo "USAGE: $0 pass path subj"
    echo "WHERE: \n pass -- your secret passphrase for new key generation"
    echo "	path -- output path and filename (without extention) for .key and .crt files genration output"
    echo "	subj -- an string of params for certificate (LIKE: /C=UA/ST=YourRegion/L=City/O=Company/OU=Owner/CN=SiteUrl )"
    exit 0
fi

PASS=$1
OUTPATH=$2
SUBJ=$3

echo ">>> CA Key and Certificate"
openssl genrsa -aes256 -passout pass:$PASS -out $OUTPATH.key 4096
openssl req -new -x509 -days 365 -key $OUTPATH.key -passin pass:$PASS -subj $SUBJ -out $OUTPATH.crt
#openssl rsa -in $OUTPATH.key -passin pass:$PASS -out $OUTPATH.key

echo ">>> $0 Done."