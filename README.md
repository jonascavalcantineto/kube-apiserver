# Kube-ApiServer v1.9.8

# Kubernetes

<img src="https://github.com/kubernetes/kubernetes/raw/master/logo/logo.png" width="100">

----

Kubernetes is an open source system for managing [containerized applications]
across multiple hosts; providing basic mechanisms for deployment, maintenance,
and scaling of applications.

Kubernetes builds upon a decade and a half of experience at Google running
production workloads at scale using a system called [Borg],
combined with best-of-breed ideas and practices from the community.

Kubernetes is hosted by the Cloud Native Computing Foundation ([CNCF]).
If you are a company that wants to help shape the evolution of
technologies that are container-packaged, dynamically-scheduled
and microservices-oriented, consider joining the CNCF.
For details about who's involved and how Kubernetes plays a role,
read the CNCF [announcement].

----

# Environment Variables

The kube-apiserver image uses several environment variables which are easy to miss. While none of the variables are required, they may significantly aid you in using the image.

This environment variable is recommended for you to use the kube-apiserver. 
This is the way to reach in the etcd servers
```
ETCD_SERVER="127.0.0.1"
APISERVER_IP="127.0.0.1"

```

These variables are default configuration of the cluster Kubernetes
```
KUBERNETES_CLUSTER_RANGE_IP="10.254.0.0/16"
CLUSTER_NAME="cluster.local"
CONTEXT_NAME="default"
USER="admin"
PATH_BASE_KUBERNETES="/opt/kubernetes"

```

These variables are usuly to certificates path and  files
```
DIR_CERTS="${PATH_BASE_KUBERNETES}/certs"
DIR_CERTS_MODULES="${DIR_CERTS}/modules"
DIR_CERTS_USERS="${DIR_CERTS}/users"
DIR_CERTS_API="${DIR_CERTS}/api"

ADMIN_CERT_PEM="admin.pem"
ADMIN_KEY_PEM="admin-key.pem"
CA_CERT_PEM="ca.pem"
CA_CERT_PEM_KEY="ca-key.pem"
CERT_CA_SUBJ="cluster.local"
API_CERT_CRT="apiserver.crt"
API_KEY="apiserver.key"
API_CERT_PEM="apiserver.pem"
API_KEY_PEM="apiserver-key.pem"
API_CERT_CSR="apiserver.csr"

```

# How to use this image

Start with docker command
```
docker run -d 
        --name <container_name> 
        --privileged \
        -p 6443:6443   \
        -e ETCD_SERVER=<ip_server_etcd> \ 
        -e APISERVER_IP=<ip_apiserver>  \
        -e KUBERNETES_CLUSTER_RANGE_IP=<network/mask> \ 
        -e CLUSTER_NAME=<name.cluster> \
        -e CONTEXT_NAME=<default>  \
        -e USER=<user_admin> \
        -e PATH_BASE_KUBERNETES=<path_files_kube_apiserver> \ 
        -e DIR_CERTS_MODULES="${DIR_CERTS}/modules"
        -e DIR_CERTS_USERS="${DIR_CERTS}/users"
        -e DIR_CERTS_API="${DIR_CERTS}/api"
        -e DIR_CERTS=<path_all_certificates>  \
        -e ADMIN_CERT_PEM=<cert_user_admin.pem> \ 
        -e ADMIN_KEY_PEM=<user_admin-key.pem> \ 
        -e CA_CERT_PEM=<ca_cert_PEM.pem> \ 
        -e CA_CERT_PEM_KEY=<ca-key.pem>  \ 
        -e API_CERT_CRT=<apiserver.crt> \ 
        -e API_KEY=<apiserver.key> \ 
        -e API_CERT_PEM=<apiserver.pem> \ 
        -e API_KEY_PEM=<apiserver-key.pem> \ 
        -e TOKEN=<hash> \(# dd if=/dev/urandom bs=128 count=1 2>/dev/null | base64 | tr -d "=+/" | dd bs=32 count=1 2>/dev/null) 
        -v <path_local_storage>:${DIR_CERTS}/services <image>:<tag> 
```
# Docker example

```
docker run -d --name kube-apiserver --privileged=true -h kube-apiserver -p 6443:6443 -e ETCD_SERVER="172.31.134.8" -e APISERVER_IP="172.31.134.8" -e CLUSTER_NAME="company.local" -v /opt/kubernetes/certs/:/opt/kubernetes/certs/ kube-apiserver

```