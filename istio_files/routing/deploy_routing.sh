#!/bin/bash

# On default when u create a second version of recommendation/or you scale it and you inject the sidecar and deploy it to openshift, then all request to the recommendation service
# will be forwarded to both version of recommendation service because of round-robin loadbalancing of openshift.

ISTIO_FILES=~/Istio-Openshift-Example/istio_files

# Destional-rule für beide versionen des recommendation service definieren.
oc apply -f $ISTIO_FILES/routing/destination-rule-recommendation-v1-v2.yml -n tutorial

# All users to recommendation:v2
oc apply -f $ISTIO_FILES/routing/virtual-service-recommendation-v2.yml -n tutorial

# Create the virtualservice that will send 90% of requests to v1 and 10% to v2
oc apply -f $ISTIO_FILES/routing/virtual-service-recommendation-v1_and_v2.yml -n tutorial

# Set Safari users to v2
oc apply -f $ISTIO_FILES/routing/virtual-service-safari-recommendation-v2.yml -n tutorial

# traffic Mirroring / Shadowing
oc apply -f $ISTIO_FILES/routing/virtual-service-recommendation-v1-mirror-v2.yml -n tutorial

# We’ll create a whitelist on the preference service to only allow requests from the recommendation service, which will make the preference service invisible to the customer service.
# Requests from the customer service to the preference service will return a 404 Not Found HTTP error code.
oc apply -f $ISTIO_FILES/routing/acl-whitelist.yml -n tutorial

# We’ll create a blacklist making the customer service blacklist to the preference service. Requests from the customer service to the preference service will return a 403 Forbidden HTTP error code.
oc apply -f $ISTIO_FILES/routing/acl-blacklist.yml -n tutorial

# loadbalancing
oc apply -f $ISTIO_FILES/routing/destination-rule-recommendation_lb_policy_app.yml -n tutorial

# ratelimit
oc apply -f $ISTIO_FILES/routing/recommendation_rate_limit_handler.yml
oc apply -f $ISTIO_FILES/routing/rate_limit_rule.yml

# fault injection iwth abort: 50% der request an recommendation service sollen 503 error-code liefern.
oc apply -f $ISTIO_FILES/routing/destination-rule-recommendation.yml -n tutorial
oc apply -f $ISTIO_FILES/routing/virtual-service-recommendation-503.yml -n tutorial

# fault injection with deplay 
oc apply -f $ISTIO_FILES/routing/virtual-service-recommendation-delay.yml -n tutorial

# retry for recommendation service v2
oc apply -f $ISTIO_FILES/routing/virtual-service-recommendation-v2_retry.yml -n tutorial

# retry for recommendation service v1 and v2
istioctl replace -f istiofiles/virtual-service-recommendation-v1_and_v2_retry.yml -n tutorial

# timeout on recommendation service
oc apply -f $ISTIO_FILES/routing/virtual-service-recommendation-timeout.yml -n tutorial

# circuit-breaker policy auf recommendation service. If more than 1 request being handled by any instance/pod the the service should call should fail. 
oc apply -f $ISTIO_FILES/routing/destination-rule-recommendation_cb_policy_version_v2.yml -n tutorial
# test it with siege. Siege is a load-test tool: 
# siege -r 2 -c 20 -v customer-tutorial.$(minishift ip).nip.io

# Pool ejection or outlier detection on recommendation service v1 and v2.
oc apply -f $ISTIO_FILES/routing/destination-rule-recommendation_cb_policy_pool_ejection.yml -n tutorial

# Egress. allow call to outside of service-mesh. 
oc apply -f $ISTIO_FILES/routing/service-entry-egress-httpbin.yml -n tutorial

# Ingress. Allow traffic from outside to inside mesh. A gateway is defined for customer service, means the call to the customer service go first to ingressgateway and then to customer.
oc apply -f $ISTIO_FILES/routing/gateway-customer.yml
# Now test it: 
# export INGRESS_PORT=$(oc -n istio-system get service istio-ingressgateway -o jsonpath='{.spec.ports[?(@.name=="http2")].nodePort}')
# export INGRESS_HOST=$(minishift ip)
# export GATEWAY_URL=$INGRESS_HOST:$INGRESS_PORT
# curl http://${GATEWAY_URL}/

# clean up
~/Istio-Openshift-Example/.cleanup.sh