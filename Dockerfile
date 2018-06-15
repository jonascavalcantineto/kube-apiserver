FROM centos:7.4.1708
LABEL MAINTAINER="unisp <cicero.gadelha@funceme.br | jonas.cavalcantineto@funceme.com>"

RUN yum update -y 
RUN yum install -y \
            vim \
            wget \
            epel-release.noarch \
            openssl 

RUN yum update -y
RUN yum install -y \
		supervisor.noarch \
		curl \
		bash-completion \
		git

#ETCD SERVER
ENV ETCD_SERVER="127.0.0.1"
ENV APISERVER_IP="127.0.0.1"


#CLUSTER DEFINITIONS
ENV KUBERNETES_CLUSTER_RANGE_IP="10.254.0.0/16"
ENV CLUSTER_NAME="cluster.local"
ENV CONTEXT_NAME="default"

#USER ADMIN
ENV USER="admin"

#PATH KUBERNETES
ENV PATH_BASE_KUBERNETES="/opt/kubernetes"
ENV DIR_CERTS="${PATH_BASE_KUBERNETES}/certs"
ENV DIR_CERTS_MODULES="${DIR_CERTS}/modules"
ENV DIR_CERTS_USERS="${DIR_CERTS}/users"
ENV DIR_CERTS_API="${DIR_CERTS}/api"

#CERTS
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

#COMMAND TO TOKEN GENERATE
# dd if=/dev/urandom bs=128 count=1 2>/dev/null | base64 | tr -d "=+/" | dd bs=32 count=1 2>/dev/null
ENV TOKEN="fQAv5WoZEDyu6YKP5e3AH33p7qYKN92K"

#KUBERNETES
ENV KUBERNETES_VERSION "v1.9.8"

RUN set -ex \
	&& wget https://github.com/kubernetes/kubernetes/releases/download/${KUBERNETES_VERSION}/kubernetes.tar.gz \
 	&& tar -zxvf kubernetes.tar.gz -C /tmp \
 	&& echo y | /tmp/kubernetes/cluster/get-kube-binaries.sh \
 	&& tar -zxvf /tmp/kubernetes/server/kubernetes-server-*.tar.gz -C /tmp/kubernetes/server \
 	&& mkdir -p ${PATH_BASE_KUBERNETES}/bin \
    && cp -a /tmp/kubernetes/server/kubernetes/server/bin/{kube-apiserver,kubectl} ${PATH_BASE_KUBERNETES}/bin/ \
    && ln -s ${PATH_BASE_KUBERNETES}/bin/kubectl /usr/local/sbin/kubectl \
    && ln -s ${PATH_BASE_KUBERNETES}/bin/kube-apiserver /usr/local/sbin/kube-apiserver \    
	&& useradd kube \
	&& chown -R kube:kube ${PATH_BASE_KUBERNETES}/ \
	&& echo "source <(kubectl completion bash)" >> ~/.bashrc \
 	&& rm -rf /tmp/kubernetes \
	&& rm -f kubernetes.tar.gz

ADD conf/openssl.cnf /openssl.cnf 
ADD bin/create_user_keys.sh /create_user_keys.sh
ADD bin/initial-setup-context-kube.sh /initial-setup-context-kube.sh
ADD bin/start_apiserver.sh /start_apiserver.sh
RUN chmod +x /create_user_keys.sh
RUN chmod +x /initial-setup-context-kube.sh
RUN chmod +x /start_apiserver.sh

#PORTS
# TCP     6443*       Kubernetes API Server
# TCP     2379-2380   etcd server client API
# TCP     10250       Kubelet API
# TCP     10251       kube-scheduler
# TCP     10252       kube-controller-manager
# TCP     10255       Read-Only Kubelet API

EXPOSE 6443 

COPY conf/supervisord.conf /etc/
ADD bin/start.sh /start.sh
RUN chmod +x /start.sh
CMD ["./start.sh"]

