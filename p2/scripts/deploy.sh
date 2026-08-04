#!/bin/sh

CONF_PATH="/vagrant"

deploy_app1(){
    local APP1_CONF="$CONF_PATH/app1"
    local APP1_INDEX="$APP1_CONF/conf/site/index.html"
    local APP1_DEPLOYMENT="$APP1_CONF/manifest/deployment.yaml"
    local APP1_SERVICE="$APP1_CONF/manifest/service.yaml"
    local APP1_SERVICE_TEST="$APP1_CONF/manifest/service-test.yaml"

    if [ ! -f "$APP1_DEPLOYMENT" ];then
        echo "Error app1 deployment manifest not found"
        return 1
    fi

    echo "Deploy app1"
    kubectl create configmap app1-index --from-file="$APP1_INDEX"

    kubectl apply -f "$APP1_DEPLOYMENT","$APP1_SERVICE","$APP1_SERVICE_TEST"
    #remember to remove lesy ty test ty
}

deploy_app2(){
    local APP2_CONF="$CONF_PATH/app2"
    local APP2_INDEX="$APP2_CONF/conf/site/index.html"
    local APP2_DEPLOYMENT="$APP2_CONF/manifest/deployment.yaml"
    local APP2_SERVICE="$APP2_CONF/manifest/service.yaml"
    local APP2_SERVICE_TEST="$APP2_CONF/manifest/service-test.yaml"

    if [ ! -f "$APP2_DEPLOYMENT" ];then
        echo "Error app2 deployment manifest not found"
        return 1
    fi

    echo "Deploy app2"
    kubectl create configmap app2-index --from-file="$APP2_INDEX"

    kubectl apply -f "$APP2_DEPLOYMENT","$APP2_SERVICE","$APP2_SERVICE_TEST"
    #remember to remove lesy ty test ty
}

deploy_app1

deploy_app2
