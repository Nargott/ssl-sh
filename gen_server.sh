#!/bin/bash

if [ "$1" == "" ] || [ "$2" == "" ] || [ "$3" == "" ] || [ "$4" == "" ]; then
    echo "USAGE: $0 capass pass path subj [cafilename]"
    echo "WHERE: \n capass -- passphrase for ca key"
    echo "WHERE: \n pass -- your secret passphrase for new key generation"
    echo "	path -- output path and filename (without extension) for .key and .crt files genration output (LIKE: generated/server)"
    echo "	subj -- an string of params for certificate (LIKE: /C=UA/ST=YourRegion/L=City/O=Company/OU=Owner/CN=SiteUrl )"
    echo "	cafilename -- (OPTIONAL) ca file name (without extension). DEFAULT: ca"
    exit 0
fi

if [ "$5" == "" ]; then
    CAFILENAME="ca"
else
    CAFILENAME="$5"
fi

CAPASS=$1
PASS=$2
OUTPATH=$3
SUBJ=$4

OUTDIR=${OUTPATH%/*}

echo ">>> Dirs $OUTDIR"
if [[ ! -f "${OUTDIR}/db/serial" ]]; then
    rm -rf ${OUTDIR}/db
    mkdir ${OUTDIR}/db
    mkdir ${OUTDIR}/db/certs
    mkdir ${OUTDIR}/db/newcerts
    touch ${OUTDIR}/db/index.txt
    echo "02" > ${OUTDIR}/db/serial
fi

OLD_SERIAL=$(<${OUTDIR}/db/serial)
NEW_SERIAL=$((0x${OLD_SERIAL}+1))

echo ">>> Create the Server Key CSR and Certificate"
openssl genrsa -aes256 -passout pass:${PASS} -out ${OUTPATH}.key 4096
openssl req -new -key ${OUTPATH}.key -passin pass:${PASS} -subj ${SUBJ} -out ${OUTPATH}.csr

echo ">>> Self Signing"
openssl x509 -req -days 365 -in ${OUTPATH}.csr -CA ${OUTDIR}/${CAFILENAME}.crt -CAkey ${OUTDIR}/${CAFILENAME}.key -passin pass:${CAPASS} -set_serial ${OLD_SERIAL} -out ${OUTPATH}.crt
rm ${OUTPATH}.csr

echo ">>> Remove password from server key"
openssl rsa -in ${OUTPATH}.key -passin pass:${PASS} -out ${OUTPATH}.nopass.key

echo ${NEW_SERIAL} > ${OUTDIR}/db/serial

echo ">>> $0 Done."