#!/bin/sh

CONF_PATH="/vagrant"
INGRESS_MANIFEST="$CONF_PATH/manifest/ingress.yaml"

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

deploy_app3(){
    local APP3_CONF="$CONF_PATH/app3"
    local APP3_INDEX="$APP3_CONF/conf/site/index.html"
    local APP3_DEPLOYMENT="$APP3_CONF/manifest/deployment.yaml"
    local APP3_SERVICE="$APP3_CONF/manifest/service.yaml"
    local APP3_SERVICE_TEST="$APP3_CONF/manifest/service-test.yaml"

    if [ ! -f "$APP3_DEPLOYMENT" ];then
        echo "Error app3 deployment manifest not found"
        return 1
    fi

    echo "Deploy app3"
    kubectl create configmap app3-index --from-file="$APP3_INDEX"

    kubectl apply -f "$APP3_DEPLOYMENT","$APP3_SERVICE","$APP3_SERVICE_TEST"
    #remember to remove lesy ty test ty
}

deploy_app1

deploy_app2

deploy_app3

#set up ingress
if [ ! -f "$INGRESS_MANIFEST" ];then
    echo "Error ingress manifest not found"
    return 1
fi

echo "Setting up ingress..."
kubectl apply -f "$INGRESS_MANIFEST"
