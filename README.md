# Host Preparation

- Install Docker
- Add user to docker group. Manage Docker as a non-root user. Add your user to docker group:

```
$ sudo groupadd docker
$ sudo usermod -aG docker $USER
```

# Install Openshift and Istio

```
./install.sh
```


# Install EFK-Stack (Elasticsearch-fluentd-Kibana)

```
/istio_files/deploy_logging.sh
```

# Install Kiali

```
./kiali.sh
```