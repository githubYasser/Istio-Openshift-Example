#!/bin/bash

# Environment
HOST_IP=$(/sbin/ip route | awk '/default/ { print $3 }')
PUBLIC_HOST_NAME=localhost
VERSION_OPENSHIFT=openshift-origin-client-tools-v3.11.0-0cbc58b-linux-64bit
VERSION_ISTIO=istio-1.0.2


# Shortcuts
OC=bin/$VERSION_OPENSHIFT/oc
ISTIOCTL=bin/$VERSION_ISTIO/bin/istioctl
DIR_ISTIO=bin/$VERSION_ISTIO

# init
mkdir -p bin


# Download Istio
if [ ! -d $DIR_ISTIO ]; then
  curl -SL https://github.com/istio/istio/releases/download/1.0.2/istio-1.0.2-linux.tar.gz | tar -xvzC bin/
fi

#export PATH="$PATH:/home/yassir/istio-1.0.2/bin"


# Download Openshift
if [ ! -f $OC ]; then
  curl -SL https://github.com/openshift/origin/releases/download/v3.11.0/openshift-origin-client-tools-v3.11.0-0cbc58b-linux-64bit.tar.gz | tar -xvzC bin/
fi

# Deploy Openshift
$OC cluster up --skip-registry-check=true --public-hostname=$PUBLIC_HOST_NAME
$OC login -u system:admin


# each istio service account has to be add to anyuid so that the containers can run with UID 0:
$OC adm policy add-scc-to-user anyuid -z istio-ingress-service-account -n istio-system
$OC adm policy add-scc-to-user anyuid -z default -n istio-system
$OC adm policy add-scc-to-user anyuid -z prometheus -n istio-system
$OC adm policy add-scc-to-user anyuid -z istio-egressgateway-service-account -n istio-system
$OC adm policy add-scc-to-user anyuid -z istio-citadel-service-account -n istio-system
$OC adm policy add-scc-to-user anyuid -z istio-ingressgateway-service-account -n istio-system
$OC adm policy add-scc-to-user anyuid -z istio-cleanup-old-ca-service-account -n istio-system
$OC adm policy add-scc-to-user anyuid -z istio-mixer-post-install-account -n istio-system
$OC adm policy add-scc-to-user anyuid -z istio-mixer-service-account -n istio-system
$OC adm policy add-scc-to-user anyuid -z istio-pilot-service-account -n istio-system
$OC adm policy add-scc-to-user anyuid -z istio-sidecar-injector-service-account -n istio-system
$OC adm policy add-scc-to-user anyuid -z istio-galley-service-account -n istio-system

# Install Istio’s Custom Resource Definitions
kubectl apply -f install/kubernetes/helm/istio/templates/crds.yaml

# Install Istio without mutual TLS authentication between sidecars
$OC apply -f $DIR_ISTIO/install/kubernetes/istio-demo.yaml

# Verifying the installation
kubectl get svc -n istio-system

# Ensure the corresponding Kubernetes pods are deployed and all containers are up and running:
kubectl get pods -n istio-system

# Deploy sample application
