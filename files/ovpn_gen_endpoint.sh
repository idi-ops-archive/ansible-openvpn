#!/bin/bash

if [ $# -ne 1 ]; then
  echo "$0 <endpoint>"
  echo
  echo "  endpoint  - Mandatory OpenVPN server name (e.g. endpoint01)"
  echo
  exit 1
fi

source ./ovpn_gen.conf

ENDPOINT=$1

# Generate endpoint directory
mkdir -p ${ENDPOINTS_DIR}
cd ${ENDPOINTS_DIR}

echo Generate CA certificate

$OPENSSL req -nodes -newkey rsa:${RSA_BITS} -keyout ${ENDPOINT}_ca.pem -out ${ENDPOINT}_ca-csr.pem -days $KEY_DAYS -subj "${KEY_SUBJ}/CN=OpenVPN-CA/"

if [ $? -ne 0 ]; then
  echo "Failed to generate CA certificate" 
  exit 1
fi


echo Sign CA certificate

$OPENSSL x509 -req -in ${ENDPOINT}_ca-csr.pem -out ${ENDPOINT}_ca.crt -set_serial 1 -signkey ${ENDPOINT}_ca.pem -days $KEY_DAYS

if [ $? -ne 0 ]; then
  echo "Failed to sign CA certificate"
  exit 1
fi


echo Generate Server key

$OPENSSL req -nodes -newkey rsa:${RSA_BITS} -keyout ${ENDPOINT}_server.key -out ${ENDPOINT}_server.csr -days $KEY_DAYS -subj "${KEY_SUBJ}/CN=OpenVPN-Server/"

if [ $? -ne 0 ]; then
  echo "Failed to generate server key"
  exit 1
fi


echo Sign Server key

$OPENSSL x509 -req -in ${ENDPOINT}_server.csr -out ${ENDPOINT}_server.crt -CA ${ENDPOINT}_ca.crt -set_serial 1 -CAkey ${ENDPOINT}_ca.pem -days $KEY_DAYS

if [ $? -ne 0 ]; then
  echo "Failed to sign server key"
  exit 1
fi


echo Generate DH params

$OPENSSL dhparam -out ${ENDPOINT}_dh${RSA_BITS}.txt $RSA_BITS

if [ $? -ne 0 ]; then
  echo "Failed to generate DH params"
  exit 1
fi

