#!/bin/bash
VERSION_ISTIO=istio-1.0.2
ISTIO_CTL=~/Istio-Openshift-Example/bin/$VERSION_ISTIO/bin/istioctl
TUTORIAL=~/Istio-Openshift-Example/istio-tutorial

# replace myproject with your projectname
oc adm policy add-scc-to-user anyuid -z default -n myproject
oc adm policy add-scc-to-user privileged -z default -n myproject
oc adm policy add-role-to-user admin admin -n myproject

# clone application
git clone https://github.com/redhat-developer-demos/istio-tutorial

# deploy customer application
cd $TUTORIAL/customer/java/springboot
mvn clean package
docker build -t example/customer .
docker images | grep customer

# inject sidecar
oc apply -f <($ISTIO_CTL kube-inject -f $TUTORIAL/customer/kubernetes/Deployment.yml) -n myproject
oc create -f $TUTORIAL/customer/kubernetes/Service.yml -n myproject

# create a route, not needed. Access the service from service object for now ;)
#oc expose service customer

# deploy preference application
cd $TUTORIAL/preference/java/springboot
mvn clean package
docker build -t example/preference:v1 .
docker images | grep preference

oc apply -f <($ISTIO_CTL kube-inject -f $TUTORIAL/preference/kubernetes/Deployment.yml) -n myproject
oc create -f $TUTORIAL/preference/kubernetes/Service.yml -n myproject

# deploy recommendation application
cd $TUTORIAL/recommendation/java/springboot
mvn clean package
docker build -t example/recommendation:v1 .
docker images | grep recommendation

oc apply -f <($ISTIO_CTL kube-inject -f $TUTORIAL/recommendation/kubernetes/Deployment.yml) -n myproject
oc create -f $TUTORIAL/recommendation/kubernetes/Service.yml -n myproject
oc get pods -w

# when you call the customer application the output should be :
# customer => preference => recommendation v1 from '99634814-sf4cl': 1
