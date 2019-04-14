#!/bin/bash

VERSION_ISTIO=istio-1.0.2
ISTIO_FILES=~/Istio-Openshift-Example/istio_files
ISTIO_CTL=~/Istio-Openshift-Example/bin/$VERSION_ISTIO/bin/istioctl

# Enables mTLS into tutorial namespace and Makes that services withn tutorial namespace communicates with mTLS
oc apply -f $ISTIO_FILES/security/authentication-enable-tls.yml 
oc apply -f $ISTIO_FILES/security/destination-rule-tls.yml
# check if mtls is enabled inside tutorial namespace
# $ISTIO_CTL authn tls-check | grep tutorial
# curl http://${GATEWAY_URL}/


# End-user-authentication







# RBAC authorization






# JWT authorization