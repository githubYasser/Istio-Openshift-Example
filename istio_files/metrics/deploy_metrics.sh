#!/bin/bash
VERSION_ISTIO=istio-1.0.2
ISTIO_CTL=~/Istio-Openshift-Example/bin/$VERSION_ISTIO/bin/istioctl
ISTIO_FILES=~/Istio-Openshift-Example/istio_files

$ISTIOCTL create -f $ISTIO_FILES/metrics/recommendation_requestcount.yml -n istio-system

#In the Prometheus dashboard, add the following:
#istio_requests_total{destination_service="recommendation.tutorial.svc.cluster.local"}
  
#Total count of all requests to v3 of the recommendation service:  
#istio_requests_total{destination_service="recommendation.tutorial.svc.cluster.local", destination_version="v3"}