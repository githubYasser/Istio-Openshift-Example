# replace myproject with your projectname
oc adm policy add-scc-to-user anyuid -z default -n myproject
oc adm policy add-scc-to-user privileged -z default -n myproject
oc adm policy add-role-to-user admin admin -n myproject

# clone application
git clone https://github.com/redhat-developer-demos/istio-tutorial
cd istio-tutorial

# deploy customer application
cd customer/java/springboot
mvn clean package
docker build -t example/customer .
docker images | grep customer

# inject sidecar
oc apply -f <(istioctl kube-inject -f ../../kubernetes/Deployment.yml) -n tutorial
oc create -f ../../kubernetes/Service.yml -n tutorial

# create a route, not needed. Access the service from service object for now ;)
#oc expose service customer

# deploy preference application
cd preference/java/springboot
mvn clean package
docker build -t example/preference:v1 .
docker images | grep preference

oc apply -f <(istioctl kube-inject -f ../../kubernetes/Deployment.yml) -n tutorial
oc create -f ../../kubernetes/Service.yml

# deploy recommendation application
cd recommendation/java/vertx
mvn clean package
docker build -t example/recommendation:v1 .
docker images | grep recommendation

oc apply -f <(istioctl kube-inject -f ../../kubernetes/Deployment.yml) -n tutorial
oc create -f ../../kubernetes/Service.yml
oc get pods -w

# when you call the customer application the output should be :
# customer => preference => recommendation v1 from '99634814-sf4cl': 1