#!/bin/bash

if [ $# -ne 2 ]; then
  echo "$0 <endpoint> <username>"
  exit 1
fi

source ./ovpn_gen.conf

ENDPOINT=$1
USER=$2

mkdir -p $USERS_DIR

echo Generate user key
$OPENSSL req -nodes -newkey rsa:${RSA_BITS} -keyout ${USERS_DIR}/${ENDPOINT}_${USER}.key -out ${USERS_DIR}/${ENDPOINT}_${USER}.csr -days $KEY_DAYS -subj "${KEY_SUBJ}/CN=OpenVPN-Client-${USER}/"

if [ $? -ne 0 ]; then
  echo "Failed to generate user key"
  exit 1
fi

echo Sign user key
$OPENSSL x509 -req -in ${USERS_DIR}/${ENDPOINT}_${USER}.csr -out ${USERS_DIR}/${ENDPOINT}_${USER}.crt -CA ${ENDPOINTS_DIR}/${ENDPOINT}_ca.crt -CAkey ${ENDPOINTS_DIR}/${ENDPOINT}_ca.pem -set_serial 1 -days $KEY_DAYS
