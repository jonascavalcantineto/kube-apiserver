#!/bin/bash
/usr/local/sbin/kube-apiserver \
    --anonymous-auth=false \
    --service-cluster-ip-range=${KUBERNETES_CLUSTER_RANGE_IP} \
    --client-ca-file=${DIR_CERTS}/${CA_CERT_PEM}  \
    --tls-cert-file=${DIR_CERTS}/${API_CERT_CRT} \
    --tls-private-key-file=${DIR_CERTS}/${API_KEY} \
    --logtostderr=true \
    --v=2 \
    --storage-backend=etcd2 \
    --storage-media-type=application/json \
    --etcd-servers=http://${ETCD_SERVER}:2379  \
    --allow-privileged=true \
    --audit-log-path=/var/log/apiserver/ \
    --audit-log-format=legacy \
    --service-node-port-range=20-32767