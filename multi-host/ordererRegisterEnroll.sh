#!/bin/bashx

function createOrdererOrg() {
  subinfoln "Enrolling the CA admin of ordererOrg"
  mkdir -p organizations/ordererOrg

  export FABRIC_CA_CLIENT_HOME=${PWD}/organizations/ordererOrg
  export ORDERER_TLS_PATH=${PWD}/organizations/CAs/orderers

  # orderer 조직의 msp 생성(enroll)
  set -x
  fabric-ca-client enroll -u https://admin:adminpw@localhost:${CA_ORDERER_PORT} --caname ca_orderer --tls.certfiles ${ORDERER_TLS_PATH}/tls-cert.pem
  { set +x; } 2>/dev/null

  printf "NodeOUs:
  Enable: true
  ClientOUIdentifier:
    Certificate: cacerts/localhost-%s-ca_orderer.pem
    OrganizationalUnitIdentifier: client
  PeerOUIdentifier:
    Certificate: cacerts/localhost-%s-ca_orderer.pem
    OrganizationalUnitIdentifier: peer
  AdminOUIdentifier:
    Certificate: cacerts/localhost-%s-ca_orderer.pem
    OrganizationalUnitIdentifier: admin
  OrdererOUIdentifier:
    Certificate: cacerts/localhost-%s-ca_orderer.pem
    OrganizationalUnitIdentifier: orderer" "${CA_ORDERER_PORT}" "${CA_ORDERER_PORT}" "${CA_ORDERER_PORT}" "${CA_ORDERER_PORT}" >${PWD}/organizations/ordererOrg/msp/config.yaml

  # orderer 조직의 admin 등록(register)
  subinfoln "Registering orderer admin"
  set -x
  fabric-ca-client register --caname ca_orderer --id.name ordereradmin --id.secret ordereradminpw --id.type admin --tls.certfiles ${ORDERER_TLS_PATH}/tls-cert.pem
  { set +x; } 2>/dev/null

  # orderer 조직의 admin msp 발급(enroll)
  subinfoln "Generating the orderer admin msp"
  set -x
  fabric-ca-client enroll -u https://ordereradmin:ordereradminpw@localhost:${CA_ORDERER_PORT} --caname ca_orderer -M ${PWD}/organizations/ordererOrg/admin/Admin@orderer.com/msp --tls.certfiles ${ORDERER_TLS_PATH}/tls-cert.pem
  { set +x; } 2>/dev/null

  mkdir -p ${PWD}/organizations/ordererOrg/msp/tlscacerts

  cp ${PWD}/organizations/ordererOrg/msp/config.yaml ${PWD}/organizations/ordererOrg/admin/Admin@orderer.com/msp/config.yaml
}

function createOrdererNode() {

  export FABRIC_CA_CLIENT_HOME=${PWD}/organizations/ordererOrg
  export ORDERER_TLS_PATH=${PWD}/organizations/CAs/orderers

  # orderer node 등록(register)
  subinfoln "Registering ${ORDERER1_NAME}"
  set -x
  fabric-ca-client register --caname ca_orderer --id.name ${ORDERER1_NAME} --id.secret ${ORDERER1_NAME}pw --id.type orderer --tls.certfiles ${ORDERER_TLS_PATH}/tls-cert.pem
  { set +x; } 2>/dev/null

  # orderer node의 msp 발급(enroll)
  subinfoln "Generating the ${ORDERER1_NAME} msp"
  set -x
  fabric-ca-client enroll -u https://${ORDERER1_NAME}:${ORDERER1_NAME}pw@localhost:${CA_ORDERER_PORT} --caname ca_orderer -M ${PWD}/organizations/ordererOrg/orderers/${ORDERER1_NAME}/msp --csr.hosts ${ORDERER1_NAME}.org0.com --csr.hosts localhost --tls.certfiles ${ORDERER_TLS_PATH}/tls-cert.pem
  { set +x; } 2>/dev/null

  cp ${PWD}/organizations/ordererOrg/msp/config.yaml ${PWD}/organizations/ordererOrg/orderers/${ORDERER1_NAME}/msp/config.yaml

  # orderer node의 tls-cert 발급(enroll)
  subinfoln "Generating the ${ORDERER1_NAME} tls certificates"
  set -x
  fabric-ca-client enroll -u https://${ORDERER1_NAME}:${ORDERER1_NAME}pw@localhost:${CA_ORDERER_PORT} --caname ca_orderer -M ${PWD}/organizations/ordererOrg/orderers/${ORDERER1_NAME}/tls --enrollment.profile tls --csr.hosts ${ORDERER1_NAME}.org0.com --csr.hosts localhost --tls.certfiles ${ORDERER_TLS_PATH}/tls-cert.pem
  { set +x; } 2>/dev/null

  export ORDERER_PATH=organizations/ordererOrg/orderers/${ORDERER1_NAME}

  cp ${PWD}/${ORDERER_PATH}/tls/tlscacerts/* ${PWD}/${ORDERER_PATH}/tls/ca.crt
  cp ${PWD}/${ORDERER_PATH}/tls/signcerts/* ${PWD}/${ORDERER_PATH}/tls/server.crt
  cp ${PWD}/${ORDERER_PATH}/tls/keystore/* ${PWD}/${ORDERER_PATH}/tls/server.key

  mkdir -p ${PWD}/${ORDERER_PATH}/msp/tlscacerts
  cp ${PWD}/${ORDERER_PATH}/tls/tlscacerts/* ${PWD}/${ORDERER_PATH}/msp/tlscacerts/tls-cert.pem

  cp ${PWD}/${ORDERER_PATH}/tls/tlscacerts/* ${PWD}/organizations/ordererOrg/msp/tlscacerts/${ORDERER1_NAME}-tls-cert.pem
}