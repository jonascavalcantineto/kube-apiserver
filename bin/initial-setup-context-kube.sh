#!/bin/bash

USER="admin"

mkdir -p ${DIR_CERTS_USERS} ${DIR_CERTS_MODULES}


echo "GENERATE CERTS ON $DIR_CERTS"

#SETUP KUBECTL ADMIN
if [ ! -f ${DIR_CERTS_USERS}/${USER}-key.pem ]; then
    echo "CERTIFICATES ${DIR_CERTS_USERS} not found!"
    openssl genrsa -out ${DIR_CERTS_USERS}/${USER}-key.pem 2048
    openssl req -new -key ${DIR_CERTS_USERS}/${USER}-key.pem -out ${DIR_CERTS_USERS}/${USER}.csr -subj "/CN=${USER}"
    openssl x509 -req -in ${DIR_CERTS_USERS}/${USER}.csr -CA ${DIR_CERTS_API}/${CA_CERT_PEM} -CAkey ${DIR_CERTS_API}/${CA_CERT_PEM_KEY} -CAcreateserial -out ${DIR_CERTS_USERS}/${USER}.pem -days 7200


    kubectl config set-cluster $CLUSTER_NAME --certificate-authority=${DIR_CERTS_API}/${CA_CERT_PEM} --embed-certs=true --server=https://${APISERVER_IP}:6443 
    kubectl config set-credentials ${USER} --client-certificate=${DIR_CERTS_USERS}/${ADMIN_CERT_PEM} --client-key=${DIR_CERTS_USERS}/${ADMIN_KEY_PEM} --embed-certs=true --token=${TOKEN}
    kubectl config set-context $CONTEXT_NAME --cluster=$CLUSTER_NAME --user=${USER}
    kubectl config use-context $CONTEXT_NAME

    for modulo in kube-controller-manager kube-scheduler kubelet kube-proxy kube-dns kubernetes-dashboard
    do
        mkdir -p ${DIR_CERTS_MODULES}/${modulo}
        openssl genrsa -out ${DIR_CERTS_MODULES}/${modulo}/${modulo}-key.pem 2048
        openssl req -new -key ${DIR_CERTS_MODULES}/${modulo}/${modulo}-key.pem -out ${DIR_CERTS_MODULES}/${modulo}/${modulo}.csr -subj "/CN=${modulo}"
        openssl x509 -req -in ${DIR_CERTS_MODULES}/${modulo}/${modulo}.csr -CA ${DIR_CERTS_API}/${CA_CERT_PEM} -CAkey ${DIR_CERTS_API}/${CA_CERT_PEM_KEY} -CAcreateserial -out ${DIR_CERTS_MODULES}/${modulo}/${modulo}.pem -days 7200

        kubectl config set-cluster $CLUSTER_NAME --certificate-authority=${DIR_CERTS_API}/${CA_CERT_PEM} --embed-certs=true --server=https://${APISERVER_IP}:6443  --kubeconfig=${DIR_CERTS_MODULES}/${modulo}/kubeconfig
        kubectl config set-credentials ${modulo} --client-certificate=${DIR_CERTS_MODULES}/${modulo}/${modulo}.pem --client-key=${DIR_CERTS_MODULES}/${modulo}/${modulo}-key.pem --embed-certs=true --token=$TOKEN --kubeconfig=${DIR_CERTS_MODULES}/${modulo}/kubeconfig
        kubectl config set-context $CONTEXT_NAME --cluster=$CLUSTER_NAME --user=${modulo} --kubeconfig=${DIR_CERTS_MODULES}/${modulo}/kubeconfig
        kubectl config use-context $CONTEXT_NAME --kubeconfig=${DIR_CERTS_MODULES}/${modulo}/kubeconfig
    done
else 
    echo "CERTIFICATES ${DIR_CERTS_USERS} found!"
fi

chown -R kube:kube ${PATH_BASE_KUBERNETES}/