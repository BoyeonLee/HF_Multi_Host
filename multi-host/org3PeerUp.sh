#!/bin/bash

C_YELLOW='\033[1;33m'
C_BLUE='\033[0;34m'
C_RESET='\033[0m'

# subinfoln echos in blue color
function infoln() {
  echo -e "${C_YELLOW}${1}${C_RESET}"
}

function subinfoln() {
  echo -e "${C_BLUE}${1}${C_RESET}"
}

# add PATH to ensure we are picking up the correct binaries
export PATH=${HOME}/bin:$PATH
export FABRIC_CFG_PATH=${PWD}/config

# Bring up the peer nodes using docker compose.
infoln "---------- Bring up the org3 peer nodes using docker compose ----------"

COMPOSE_FILES=docker/docker-compose-org3-peer.yaml
COMPOSE_FILES_COUCH=docker/docker-compose-org3-couch.yaml
IMAGE_TAG=latest docker-compose -f $COMPOSE_FILES -f $COMPOSE_FILES_COUCH -p org3_peer_couch up -d 2>&1