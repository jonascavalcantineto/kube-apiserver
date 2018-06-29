#!/bin/bash

mkdir -p ${DIR_CERTS_API} ${DIR_CERTS_USERS} ${DIR_CERTS_MODULES}
cp /openssl.cnf  ${DIR_CERTS_API}/openssl.cnf 


#GENERATE CERTIFICATES 
if [ ! -f ${DIR_CERTS_API}/${CA_CERT_PEM_KEY} ]; then
    echo "CERTIFICATES ${DIR_CERTS_API} not found!"

    openssl genrsa -out ${DIR_CERTS_API}/${CA_CERT_PEM_KEY} 2048
    openssl req -x509 -new -nodes -key ${DIR_CERTS_API}/${CA_CERT_PEM_KEY} -days 10000 -out ${DIR_CERTS_API}/${CA_CERT_PEM} -subj "/CN=${CLUSTER_NAME}"
    openssl genrsa -out ${DIR_CERTS_API}/${API_KEY_PEM} 2048
    openssl req -new -key ${DIR_CERTS_API}/${API_KEY_PEM} -out ${DIR_CERTS_API}/${API_CERT_CSR} -subj "/CN=kube-apiserver" -config ${DIR_CERTS_API}/openssl.cnf
    openssl x509 -req -in ${DIR_CERTS_API}/${API_CERT_CSR} -CA ${DIR_CERTS_API}/${CA_CERT_PEM} -CAkey ${DIR_CERTS_API}/${CA_CERT_PEM_KEY} -CAcreateserial -out ${DIR_CERTS_API}/${API_CERT_PEM} -days 7200 -extensions v3_req -extfile ${DIR_CERTS_API}/openssl.cnf
    cp -a ${DIR_CERTS_API}/${API_CERT_PEM} ${DIR_CERTS_API}/${API_CERT_CRT}
    cp -a ${DIR_CERTS_API}/${API_KEY_PEM} ${DIR_CERTS_API}/${API_KEY}
else 
    echo "CERTIFICATES ${DIR_CERTS_API} found!"
fi

chown -R kube:kube ${PATH_BASE_KUBERNETES}/

/usr/local/sbin/kube-apiserver \
    --anonymous-auth=false \
    --service-cluster-ip-range=${KUBERNETES_CLUSTER_RANGE_IP} \
    --client-ca-file=${DIR_CERTS_API}/${CA_CERT_PEM}  \
    --tls-cert-file=${DIR_CERTS_API}/${API_CERT_CRT} \
    --tls-private-key-file=${DIR_CERTS_API}/${API_KEY} \
    --logtostderr=true \
    --v=2 \
    --storage-backend=etcd2 \
    --storage-media-type=application/json \
    --etcd-servers=http://${ETCD_SERVER}:2379  \
    --allow-privileged=true \
    --audit-log-path=/var/log/apiserver/ \
    --audit-log-format=legacy \
    --admission-control=NamespaceLifecycle,NamespaceExists,LimitRanger,SecurityContextDeny,ServiceAccount,ResourceQuota \
    --service-node-port-range=20-32767

 #--authorization-mode=RBAC \