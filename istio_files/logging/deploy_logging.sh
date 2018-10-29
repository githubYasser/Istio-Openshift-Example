#!/bin/bash

ISTIO_FILES=~/Istio-Openshift-Example/istio_files

# Deploy Logging Elasticseach-fluentd-Kibana-Stack inside logging namespace
oc adm policy add-scc-to-user anyuid -z default -n logging
oc apply -f $ISTIO_FILES/logging/logging-stack.yaml
oc apply -f $ISTIO_FILES/logging/fluentd-istio.yaml

# Make some request to the applcaitaion

# Make port forwarding to kibana UI.
# Navigate to the Kibana UI and click the “Set up index patterns” in the top right.
# Use * as the index pattern, and click “Next step.”.
# Select @timestamp as the Time Filter field name, and click “Create index pattern.”
# Now click “Discover” on the left menu, and start exploring the logs generated