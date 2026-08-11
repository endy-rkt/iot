#!/bin/bash

#this script is to run with root privilege
if [[ $EUID -ne 0 ]]; then
    echo "This script must be run with root priv"
    exit 1
fi

ARGOCD_PORT=8080

echo "destroying resources..."

kubectl delete all --all -n dev

kubectl delete apps --all -n argocd

kubectl delete ns dev argocd

if lsof -i :$ARGOCD_PORT > /dev/null; then
    echo "cleaning argocd port $ARGOCD_PORT..."
    PID=$(lsof -i :$ARGOCD_PORT | grep LISTEN | head -n 1| awk '{print $2}')
    kill -9 $PID
fi
