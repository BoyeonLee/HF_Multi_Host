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

# Generate orderer system channel genesis block.
infoln "---------- Generating Orderer Genesis block ----------"
set -x
configtxgen -profile MultiNodeEtcdRaft -channelID system-channel -outputBlock ./channel-artifacts/genesis.block
{ set +x; } 2>/dev/null

# Generate transaction file
infoln "---------- Generating transaction file ----------"
set -x
configtxgen -profile ThreeOrgsChannel -outputCreateChannelTx ./channel-artifacts/ourchannel.tx -channelID ourchannel
{ set +x; } 2>/dev/null

# Generate anchorpeer org1 transaction file
infoln "---------- Generating anchorpeer org1 transaction file ----------"
set -x
configtxgen -profile ThreeOrgsChannel -outputAnchorPeersUpdate ./channel-artifacts/Org1MSPanchors.tx -channelID ourchannnel -asOrg Org1MSP
{ set +x; } 2>/dev/null

# Generate anchorpeer org2 transaction file
infoln "---------- Generating anchorpeer org2 transaction file ----------"
set -x
configtxgen -profile ThreeOrgsChannel -outputAnchorPeersUpdate ./channel-artifacts/Org2MSPanchors.tx -channelID ourchannnel -asOrg Org2MSP
{ set +x; } 2>/dev/null

# Generate anchorpeer org3 transaction file
infoln "---------- Generating anchorpeer org3 transaction file ----------"
set -x
configtxgen -profile ThreeOrgsChannel -outputAnchorPeersUpdate ./channel-artifacts/Org3MSPanchors.tx -channelID ourchannnel -asOrg Org3MSP
{ set +x; } 2>/dev/null