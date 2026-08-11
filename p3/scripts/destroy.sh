#!/bin/bash

echo "destroying resources..."

kubectl delete all --all -n dev

kubectl delete apps --all -n argocd

kubectl delete ns dev argocd
