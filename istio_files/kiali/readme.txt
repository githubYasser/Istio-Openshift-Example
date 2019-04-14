- You should first have istio-enables application.
- run the script ./kiali.sh to install kiali.
- To uninstall kiali run:
  oc delete all,secrets,sa,templates,configmaps,deployments,clusterroles,clusterrolebindings,virtualservices,destinationrules --selector=app=kiali -n istio-system