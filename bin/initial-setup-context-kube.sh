#!/bin/bash

USER="admin"

if [ "$(ls -A $DIR_CERTS_SERVICES/)" ]; 
then
    echo "Take action $DIR_CERTS_SERVICES is not Empty"
else
    echo "$DIR_CERTS_SERVICES is Empty"
    #SETUP KUBECTL ADMIN
    openssl genrsa -out ${DIR_CERTS_SERVICES}/${USER}-key.pem 2048
    openssl req -new -key ${DIR_CERTS_SERVICES}/${USER}-key.pem -out ${DIR_CERTS_SERVICES}/${USER}.csr -subj "/CN=${USER}"
    openssl x509 -req -in ${DIR_CERTS_SERVICES}/${USER}.csr -CA ${DIR_CERTS}/${CA_CERT_PEM} -CAkey ${DIR_CERTS}/${CA_CERT_PEM_KEY} -CAcreateserial -out ${DIR_CERTS_SERVICES}/${USER}.pem -days 7200

    
    kubectl config set-cluster $CLUSTER_NAME --certificate-authority=${DIR_CERTS}/${CA_CERT_PEM} --embed-certs=true --server=https://${APISERVER_IP}:6443 
    kubectl config set-credentials ${USER} --client-certificate=${DIR_CERTS_SERVICES}/${ADMIN_CERT_PEM} --client-key=${DIR_CERTS_SERVICES}/${ADMIN_KEY_PEM} --embed-certs=true --token=${TOKEN}
    kubectl config set-context $CONTEXT_NAME --cluster=$CLUSTER_NAME --user=${USER}
    kubectl config use-context $CONTEXT_NAME
   
    for user in kube-controller-manager kube-scheduler kubelet kube-proxy
    do
       
        mkdir -p ${DIR_CERTS_SERVICES}/${user}/
        openssl genrsa -out ${DIR_CERTS_SERVICES}/${user}/${user}-key.pem 2048
        openssl req -new -key ${DIR_CERTS_SERVICES}/${user}/${user}-key.pem -out ${DIR_CERTS_SERVICES}/${user}/${user}.csr -subj "/CN=${user}"
        openssl x509 -req -in ${DIR_CERTS_SERVICES}/${user}/${user}.csr -CA ${DIR_CERTS}/${CA_CERT_PEM} -CAkey ${DIR_CERTS}/${CA_CERT_PEM_KEY} -CAcreateserial -out ${DIR_CERTS_SERVICES}/${user}/${user}.pem -days 7200

        kubectl config set-cluster $CLUSTER_NAME --certificate-authority=${DIR_CERTS}/${CA_CERT_PEM} --embed-certs=true --server=https://${APISERVER_IP}:6443  --kubeconfig=${DIR_CERTS_SERVICES}/${user}/kubeconfig
        kubectl config set-credentials ${user} --client-certificate=${DIR_CERTS_SERVICES}/${user}/${user}.pem --client-key=${DIR_CERTS_SERVICES}/${user}/${user}-key.pem --embed-certs=true --token=$TOKEN --kubeconfig=${DIR_CERTS_SERVICES}/${user}/kubeconfig
        kubectl config set-context $CONTEXT_NAME --cluster=$CLUSTER_NAME --user=${user} --kubeconfig=${DIR_CERTS_SERVICES}/${user}/kubeconfig
        kubectl config use-context $CONTEXT_NAME --kubeconfig=${DIR_CERTS_SERVICES}/${user}/kubeconfig

    done

    cp -rv ${DIR_CERTS}/apiserver* ${DIR_CERTS_SERVICES}/
    cp -rv ${DIR_CERTS}/ca* ${DIR_CERTS_SERVICES}/
fi
