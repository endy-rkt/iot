#!/bin/sh

CONF_PATH="/vagrant"

#/usr/share/nginx/html/index.html

deploy_app1(){
    local APP1_CONF="$CONF_PATH/app1"
    local APP1_INDEX="$APP1_CONF/conf/site/index.html"
    local APP1_DEPLOYMENT="$APP1_CONF/manifest/deployment.yaml"

    if [ ! -f "$APP1_DEPLOYMENT" ];then
        echo "Error app1 deployment manifest not found"
        return 1
    fi

    echo "Deploy app1"
    kubectl create configmap app1-index --from-file="$APP1_INDEX"

    kubectl apply -f "$APP1_DEPLOYMENT"
}

deploy_app1
