#!/bin/bashx

function createPeer() {
  subinfoln "Enrolling the CA admin of peerOrg"
  mkdir -p organizations/peerOrgs/${ORG_NAME}/

  export FABRIC_CA_CLIENT_HOME=${PWD}/organizations/peerOrgs/${ORG_NAME}
  export PEER_TLS_PATH=${PWD}/organizations/CAs/peers/${ORG_NAME}

  # peer org의 msp 생성
  set -x
  fabric-ca-client enroll -u https://admin:adminpw@localhost:${CA_PEER_PORT} --caname ca_${ORG_NAME}_peer --tls.certfiles ${PEER_TLS_PATH}/tls-cert.pem
  { set +x; } 2>/dev/null

  printf "NodeOUs:
  Enable: true
  ClientOUIdentifier:
    Certificate: cacerts/localhost-%s-ca_%s_peer.pem
    OrganizationalUnitIdentifier: client
  PeerOUIdentifier:
    Certificate: cacerts/localhost-%s-ca_%s_peer.pem
    OrganizationalUnitIdentifier: peer
  AdminOUIdentifier:
    Certificate: cacerts/localhost-%s-ca_%s_peer.pem
    OrganizationalUnitIdentifier: admin
  OrdererOUIdentifier:
    Certificate: cacerts/localhost-%s-ca_%s_peer.pem
    OrganizationalUnitIdentifier: orderer" "${CA_PEER_PORT}" "${ORG_NAME}" "${CA_PEER_PORT}" "${ORG_NAME}" "${CA_PEER_PORT}" "${ORG_NAME}" "${CA_PEER_PORT}" "${ORG_NAME}" >${PWD}/organizations/peerOrgs/${ORG_NAME}/msp/config.yaml

  # peer org의 peer0 등록(register)
  subinfoln "Registering ${PEER1_NAME}"
  set -x
  fabric-ca-client register --caname ca_${ORG_NAME}_peer --id.name ${PEER1_NAME} --id.secret ${PEER1_NAME}pw --id.type peer --tls.certfiles ${PEER_TLS_PATH}/tls-cert.pem
  { set +x; } 2>/dev/null

  # peer org의 peer1 등록(register)
  subinfoln "Registering ${PEER2_NAME}"
  set -x
  fabric-ca-client register --caname ca_${ORG_NAME}_peer --id.name ${PEER2_NAME} --id.secret ${PEER2_NAME}pw --id.type peer --tls.certfiles ${PEER_TLS_PATH}/tls-cert.pem
  { set +x; } 2>/dev/null

  # peer org의 user 등록(register)
  subinfoln "Registering peer ${ORG_NAME} user"
  set -x
  fabric-ca-client register --caname ca_${ORG_NAME}_peer --id.name user1 --id.secret user1pw --id.type client --tls.certfiles ${PEER_TLS_PATH}/tls-cert.pem
  { set +x; } 2>/dev/null
  
  # peer org의 admin 등록(register)
  subinfoln "Registering peer ${ORG_NAME} admin"
  set -x
  fabric-ca-client register --caname ca_${ORG_NAME}_peer --id.name peer${ORG_NAME}admin --id.secret peer${ORG_NAME}adminpw --id.type admin --tls.certfiles ${PEER_TLS_PATH}/tls-cert.pem
  { set +x; } 2>/dev/null
  
  # peer0 msp 발급(enroll)
  subinfoln "Generating the ${PEER1_NAME} msp"
  set -x
  fabric-ca-client enroll -u https://${PEER1_NAME}:${PEER1_NAME}pw@localhost:${CA_PEER_PORT} --caname ca_${ORG_NAME}_peer -M ${PWD}/organizations/peerOrgs/${ORG_NAME}/peers/${PEER1_NAME}/msp --csr.hosts ${PEER1_NAME}.${ORG_NAME}.com --tls.certfiles ${PEER_TLS_PATH}/tls-cert.pem
  { set +x; } 2>/dev/null

  cp ${PWD}/organizations/peerOrgs/${ORG_NAME}/msp/config.yaml ${PWD}/organizations/peerOrgs/${ORG_NAME}/peers/${PEER1_NAME}/msp/config.yaml

  # peer1 msp 발급(enroll)
  subinfoln "Generating the ${PEER2_NAME} msp"
  set -x
  fabric-ca-client enroll -u https://${PEER2_NAME}:${PEER2_NAME}pw@localhost:${CA_PEER_PORT} --caname ca_${ORG_NAME}_peer -M ${PWD}/organizations/peerOrgs/${ORG_NAME}/peers/${PEER2_NAME}/msp --csr.hosts ${PEER2_NAME}.${ORG_NAME}.com --tls.certfiles ${PEER_TLS_PATH}/tls-cert.pem
  { set +x; } 2>/dev/null

  cp ${PWD}/organizations/peerOrgs/${ORG_NAME}/msp/config.yaml ${PWD}/organizations/peerOrgs/${ORG_NAME}/peers/${PEER2_NAME}/msp/config.yaml

  # peer0 tls-cert 발급(enroll)
  subinfoln "Generating the ${PEER1_NAME}-tls certificates"
  set -x
  fabric-ca-client enroll -u https://${PEER1_NAME}:${PEER1_NAME}pw@localhost:${CA_PEER_PORT} --caname ca_${ORG_NAME}_peer -M ${PWD}/organizations/peerOrgs/${ORG_NAME}/peers/${PEER1_NAME}/tls --enrollment.profile tls --csr.hosts ${PEER1_NAME}.${ORG_NAME}.com --csr.hosts localhost --tls.certfiles ${PEER_TLS_PATH}/tls-cert.pem
  { set +x; } 2>/dev/null

  # peer1 tls-cert 발급(enroll)
  subinfoln "Generating the ${PEER2_NAME}-tls certificates"
  set -x
  fabric-ca-client enroll -u https://${PEER2_NAME}:${PEER2_NAME}pw@localhost:${CA_PEER_PORT} --caname ca_${ORG_NAME}_peer -M ${PWD}/organizations/peerOrgs/${ORG_NAME}/peers/${PEER2_NAME}/tls --enrollment.profile tls --csr.hosts ${PEER2_NAME}.${ORG_NAME}.com --csr.hosts localhost --tls.certfiles ${PEER_TLS_PATH}/tls-cert.pem
  { set +x; } 2>/dev/null

  # ${PEER1_NAME}.${ORG_NAME}

  export PEER0_PATH=organizations/peerOrgs/${ORG_NAME}/peers/${PEER1_NAME}

  cp ${PWD}/${PEER0_PATH}/tls/tlscacerts/* ${PWD}/${PEER0_PATH}/tls/ca.crt
  cp ${PWD}/${PEER0_PATH}/tls/signcerts/* ${PWD}/${PEER0_PATH}/tls/server.crt
  cp ${PWD}/${PEER0_PATH}/tls/keystore/* ${PWD}/${PEER0_PATH}/tls/server.key

  mkdir -p ${PWD}/organizations/peerOrgs/${ORG_NAME}/msp/tlscacerts
  cp ${PWD}/${PEER0_PATH}/tls/tlscacerts/* ${PWD}/organizations/peerOrgs/${ORG_NAME}/msp/tlscacerts/${PEER1_NAME}-ca.crt

  mkdir -p ${PWD}/organizations/peerOrgs/${ORG_NAME}/tlsca
  cp ${PWD}/${PEER0_PATH}/tls/tlscacerts/* ${PWD}/organizations/peerOrgs/${ORG_NAME}/tlsca/${PEER1_NAME}-tlsca-cert.pem

  mkdir -p ${PWD}/organizations/peerOrgs/${ORG_NAME}/ca
  cp ${PWD}/${PEER0_PATH}/msp/cacerts/* ${PWD}/organizations/peerOrgs/${ORG_NAME}/ca/${PEER1_NAME}-ca-cert.pem

   # ${PEER2_NAME}.${ORG_NAME}

  export PEER1_PATH=organizations/peerOrgs/${ORG_NAME}/peers/${PEER2_NAME}

  cp ${PWD}/${PEER1_PATH}/tls/tlscacerts/* ${PWD}/${PEER1_PATH}/tls/ca.crt
  cp ${PWD}/${PEER1_PATH}/tls/signcerts/* ${PWD}/${PEER1_PATH}/tls/server.crt
  cp ${PWD}/${PEER1_PATH}/tls/keystore/* ${PWD}/${PEER1_PATH}/tls/server.key

  # mkdir -p ${PWD}/organizations/peerOrgs/${ORG_NAME}/msp/tlscacerts
  cp ${PWD}/${PEER1_PATH}/tls/tlscacerts/* ${PWD}/organizations/peerOrgs/${ORG_NAME}/msp/tlscacerts/${PEER2_NAME}-ca.crt

  # mkdir -p ${PWD}/organizations/peerOrgs/${ORG_NAME}/tlsca
  cp ${PWD}/${PEER1_PATH}/tls/tlscacerts/* ${PWD}/organizations/peerOrgs/${ORG_NAME}/tlsca/${PEER2_NAME}-tlsca-cert.pem

  # mkdir -p ${PWD}/organizations/peerOrgs/${ORG_NAME}/ca
  cp ${PWD}/${PEER1_PATH}/msp/cacerts/* ${PWD}/organizations/peerOrgs/${ORG_NAME}/ca/${PEER2_NAME}-ca-cert.pem

  # peer org의 user msp 발급(enroll)
  subinfoln "Generating the peer ${ORG_NAME} user msp"
  set -x
  fabric-ca-client enroll -u https://user1:user1pw@localhost:${CA_PEER_PORT} --caname ca_${ORG_NAME}_peer -M ${PWD}/organizations/peerOrgs/${ORG_NAME}/users/User1@peer${ORG_NAME}.com/msp --tls.certfiles ${PEER_TLS_PATH}/tls-cert.pem
  { set +x; } 2>/dev/null

  cp ${PWD}/organizations/peerOrgs/${ORG_NAME}/msp/config.yaml ${PWD}/organizations/peerOrgs/${ORG_NAME}/users/User1@peer${ORG_NAME}.com/msp/config.yaml

  # peer org의 admin msp 발급(enroll)
  subinfoln "Generating the peer ${ORG_NAME} admin msp"
  set -x
  fabric-ca-client enroll -u https://peer${ORG_NAME}admin:peer${ORG_NAME}adminpw@localhost:${CA_PEER_PORT} --caname ca_${ORG_NAME}_peer -M ${PWD}/organizations/peerOrgs/${ORG_NAME}/users/Admin@peer${ORG_NAME}.com/msp --tls.certfiles ${PEER_TLS_PATH}/tls-cert.pem
  { set +x; } 2>/dev/null

  cp ${PWD}/organizations/peerOrgs/${ORG_NAME}/msp/config.yaml ${PWD}/organizations/peerOrgs/${ORG_NAME}/users/Admin@peer${ORG_NAME}.com/msp/config.yaml
}

