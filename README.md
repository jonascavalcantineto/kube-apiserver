# Enviroment Defaults

```
ENV ETCD_SERVER="127.0.0.1"
ENV APISERVER_IP="127.0.0.1"
ENV KUBERNETES_CLUSTER_RANGE_IP="10.254.0.0/16"
ENV CLUSTER_NAME="cluster.local"
ENV CONTEXT_NAME="default"
ENV USER="admin"
ENV PATH_BASE_KUBERNETES="/opt/kubernetes/apiserver"
ENV DIR_CERTS="${PATH_BASE_KUBERNETES}/certificates"
ENV DIR_CERTS_SERVICES="${DIR_CERTS}/services"
ENV ADMIN_CERT_PEM="admin.pem"
ENV ADMIN_KEY_PEM="admin-key.pem"
ENV CA_CERT_PEM="ca.pem"
ENV CA_CERT_PEM_KEY="ca-key.pem"
ENV CERT_CA_SUBJ="cluster.local"
ENV API_CERT_CRT="apiserver.crt"
ENV API_KEY="apiserver.key"
ENV API_CERT_PEM="apiserver.pem"
ENV API_KEY_PEM="apiserver-key.pem"
ENV API_CERT_CSR="apiserver.csr"

```

# Docker command
```
docker run -d 
        --name <container_name> --privileged 
        -p 6443:6443 -p  
        -e ETCD_SERVER=<ip_server_etcd> 
        -e APISERVER_IP=<ip_apiserver> 
        -e KUBERNETES_CLUSTER_RANGE_IP=<network/mask> 
        -e CLUSTER_NAME=<name.cluster> 
        -e CONTEXT_NAME=<default> 
        -e USER=<user_admin> 
        -e PATH_BASE_KUBERNETES=<path_files_kube_apiserver> 
        -e DIR_CERTS=<path_all_certificates> 
        -e ADMIN_CERT_PEM=<cert_user_admin.pem> 
        -e ADMIN_KEY_PEM=<user_admin-key.pem> 
        -e CA_CERT_PEM=<ca_cert_PEM.pem> 
        -e CA_CERT_PEM_KEY=<ca-key.pem>  
        -e API_CERT_CRT=<apiserver.crt> 
        -e API_KEY=<apiserver.key> 
        -e API_CERT_PEM=<apiserver.pem> 
        -e API_KEY_PEM=<apiserver-key.pem> 
        -e TOKEN=<hash> (# dd if=/dev/urandom bs=128 count=1 2>/dev/null | base64 | tr -d "=+/" | dd bs=32 count=1 2>/dev/null)
        -v <path_local_storage>:${DIR_CERTS}/services <image>:<tag>
```
# Kubernetes

[![Submit Queue Widget]][Submit Queue] [![GoDoc Widget]][GoDoc] [![CII Best Practices](https://bestpractices.coreinfrastructure.org/projects/569/badge)](https://bestpractices.coreinfrastructure.org/projects/569)

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

## To start using Kubernetes

See our documentation on [kubernetes.io].

Try our [interactive tutorial].

Take a free course on [Scalable Microservices with Kubernetes].

[announcement]: https://cncf.io/news/announcement/2015/07/new-cloud-native-computing-foundation-drive-alignment-among-container