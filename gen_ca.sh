#!/bin/bash

echo ">>> CA Key and Certificate"
openssl genrsa -aes256 -out ca.key 4096
openssl req -new -x509 -days 365 -key ca.key -subj $SUBJ -out ca.crt
openssl rsa -in ca.key -out ca.key
