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

infoln "---------- Generating org1 certificates using Fabric CA ----------"
COMPOSE_FILE_CA=docker/docker-compose-ca-org1.yaml
docker-compose -f $COMPOSE_FILE_CA -p ca_org1 up -d 2>&1
sleep 2

infoln "---------- Generating org2 certificates using Fabric CA ----------"
COMPOSE_FILE_CA=docker/docker-compose-ca-org2.yaml
docker-compose -f $COMPOSE_FILE_CA -p ca_org2 up -d 2>&1
sleep 2

infoln "---------- Generating org3 certificates using Fabric CA ----------"
COMPOSE_FILE_CA=docker/docker-compose-ca-org3.yaml
docker-compose -f $COMPOSE_FILE_CA -p ca_org3 up -d 2>&1
sleep 2

# org1

export ORG_NAME=org1
export CA_PEER_PORT=2054
export PEER1_NAME=peer0
export PEER2_NAME=peer1

. peerRegisterEnroll.sh

subinfoln "----- Create Org1 Peer org crypto material -----"
createPeer

# org2

export ORG_NAME=org2
export CA_PEER_PORT=4054
export PEER1_NAME=peer2
export PEER2_NAME=peer3

. peerRegisterEnroll.sh

subinfoln "----- Create Org2 Peer org crypto material -----"
createPeer

# org3

export ORG_NAME=org3
export CA_PEER_PORT=6054
export PEER1_NAME=peer4
export PEER2_NAME=peer5

. peerRegisterEnroll.sh

subinfoln "----- Create Org3 Peer org crypto material -----"
createPeer
