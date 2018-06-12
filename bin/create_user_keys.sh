#!/bin/bash

new_user=$1

if [ ! -z ${new_user} ]
then
    if [ ${DIR_CERTS} != "" -a ${DIR_CERTS} != "" -a ${CA_CERT_PEM_KEY} != "" -a ${TOKEN} != "" ] 
    then
        mkdir -p ${DIR_CERTS_USERS}/${new_user}/
        openssl genrsa -out ${DIR_CERTS_USERS}/${new_user}/${new_user}-key.pem 2048
        openssl req -new -key ${DIR_CERTS_USERS}/${new_user}/${new_user}-key.pem -out ${DIR_CERTS_USERS}/${new_user}/${new_user}.csr -subj "/CN=${new_user}"
        openssl x509 -req -in ${DIR_CERTS_USERS}/${new_user}/${new_user}.csr -CA ${DIR_CERTS_API}/${CA_CERT_PEM} -CAkey ${DIR_CERTS_API}/${CA_CERT_PEM_KEY} -CAcreateserial -out ${DIR_CERTS_USERS}/${new_user}/${new_user}.pem -days 7200

        kubectl config set-cluster $CLUSTER_NAME --certificate-authority=${DIR_CERTS_API}/${CA_CERT_PEM} --embed-certs=true --server=https://${APISERVER_IP}:6443  --kubeconfig=${DIR_CERTS_USERS}/${new_user}/kubeconfig
        kubectl config set-credentials ${new_user} --client-certificate=${DIR_CERTS_USERS}/${new_user}/${new_user}.pem --client-key=${DIR_CERTS_USERS}/${new_user}/${new_user}-key.pem --embed-certs=true --token=$TOKEN --kubeconfig=${DIR_CERTS_USERS}/${new_user}/kubeconfig
        kubectl config set-context $CONTEXT_NAME --cluster=$CLUSTER_NAME --user=${new_user} --kubeconfig=${DIR_CERTS_USERS}/${new_user}/kubeconfig
        kubectl config use-context $CONTEXT_NAME --kubeconfig=${DIR_CERTS_USERS}/${new_user}/kubeconfig
    else
        echo "Some enviroment variable is lost: \n"
        echo ' 
            # CLUSTER_NAME="cluster.local"
            # CONTEXT_NAME="default"
            # PATH_BASE_KUBERNETES="/opt/kubernetes/apiserver"
            # DIR_CERTS="${PATH_BASE_KUBERNETES}/certificates"
            # CA_CERT_PEM="ca.pem"
            # CA_CERT_PEM_KEY="ca-key.pem"
            # API_CERT_CRT="apiserver.crt"
            # API_KEY="apiserver.key"
            # API_CERT_PEM="apiserver.pem"
            # API_KEY_PEM="apiserver-key.pem"
            # API_CERT_CSR="apiserver.csr"
            '
    fi
else
    echo "USE: $0 <new_user>"
fi