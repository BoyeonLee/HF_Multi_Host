#!/bin/bash

C_YELLOW='\033[1;33m'
C_BLUE='\033[0;34m'
C_RESET='\033[0m'

function infoln() {
  echo -e "${C_YELLOW}${1}${C_RESET}"
}

function subinfoln() {
  echo -e "${C_BLUE}${1}${C_RESET}"
}

export PATH=${HOME}/bin:$PATH
export FABRIC_CFG_PATH=${PWD}/config

infoln "---------- Generating Orderer certificates using Fabric CA ----------"
COMPOSE_FILE_CA=docker/docker-compose-ca-orderer.yaml
docker-compose -f $COMPOSE_FILE_CA -p ca_orderer up -d 2>&1
sleep 2

export CA_ORDERER_PORT=7054
. ordererRegisterEnroll.sh

subinfoln "----- Create $orderer Org crypto material -----"
createOrdererOrg

orderers="orderer0 orderer1 orderer2 orderer3 orderer4"
for orderer in $orderers
do 
    export ORDERER1_NAME=$orderer

    . ordererRegisterEnroll.sh

    subinfoln "----- Create $orderer crypto material -----"
    createOrdererNode
done
