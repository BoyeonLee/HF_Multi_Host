#!/bin/bash

docker rm -f `docker ps -a -q`

# cleen up the MSP directory
if [ -d "organizations/peerOrgs" ]; then
    sudo rm -Rf organizations/peerOrgs
    sudo rm -Rf organizations/ordererOrg
    sudo rm -Rf organizations/CAs/*
fi

# cleen up the genesis block directory
if [ -d "channel-artifacts" ]; then
    sudo rm -Rf channel-artifacts
fi

docker ps -a