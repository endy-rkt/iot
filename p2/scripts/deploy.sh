#!/bin/sh

CONF_PATH="/vagrant"
INGRESS_MANIFEST="$CONF_PATH/manifest/ingress.yaml"

deploy_apps(){
    local APP_NUM=3
    local APP_CONF
    local APP_INDEX
    local APP_DEPLOYMENT
    local APP_SERVICE

    for i in $(seq 1 $APP_NUM); do
        APP_CONF="$CONF_PATH/app$i"
        APP_INDEX="$APP_CONF/conf/site/index.html"
        APP_DEPLOYMENT="$APP_CONF/manifest/deployment.yaml"
        APP_SERVICE="$APP_CONF/manifest/service.yaml"
        
        if [[ ! -f "$APP_DEPLOYMENT" || ! -f "$APP_SERVICE" ]];then
            echo "Error app$i manifest not found!"
            return 1
        fi

        echo "Deploying app$i..."
        kubectl create configmap "app$i-index" --from-file="$APP_INDEX"

        kubectl apply -f "$APP_DEPLOYMENT","$APP_SERVICE"

    done
}

setup_ingress(){
    if [ ! -f "$INGRESS_MANIFEST" ];then
        echo "Error ingress manifest not found!"
        return 1
    fi

    echo "Setting up ingress..."
    kubectl apply -f "$INGRESS_MANIFEST"
}

deploy_apps
 
setup_ingress
