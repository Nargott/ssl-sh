#!/bin/bash

#/C=UA/ST=KyivRegion/L=Kyiv/O=AtticLab/OU=Nargott/CN=nargott.pp.ua

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

OLD_SERIAL=$(<${OUTDIR}/db/serial)
NEW_SERIAL=$((0x${OLD_SERIAL}+1))

echo ">>> Create the Client Key and CSR"
openssl genrsa -aes256 -passout pass:${PASS} -out ${OUTPATH}.key 4096
openssl req -new -key ${OUTPATH}.key -passin pass:${PASS} -subj ${SUBJ} -out ${OUTPATH}.csr

echo ">>> Sign client certificate"
#openssl ca -config ca.config -in ${OUTPATH}.csr -out ${OUTPATH}.crt -batch
openssl x509 -req -days 365 -in ${OUTPATH}.csr -CA ${OUTDIR}/${CAFILENAME}.crt -CAkey ${OUTDIR}/${CAFILENAME}.key -passin pass:${CAPASS} -set_serial ${OLD_SERIAL} -out ${OUTPATH}.crt

echo ">>> Pack client key and certificate to be used in browsers"
openssl pkcs12 -export -in ${OUTPATH}.crt -inkey ${OUTPATH}.key -passout pass:${PASS} -passin pass:${CAPASS} -certfile ${OUTDIR}/${CAFILENAME}.crt -out ${OUTPATH}.p12

echo ">>> Pack client key and certificate to pem-format"
#openssl pkcs12 -in ${OUTPATH}.p12 -passout pass:${PASS} -passin pass:${PASS} -out ${OUTPATH}.pem -clcerts
cat client01.crt client01.key > client01.pem

echo ${NEW_SERIAL} > ${OUTDIR}/db/serial

echo ">>> $0 Done."