#!/bin/bash

#this script is to run with root privilege
# if [[ $EUID -ne 0 ]]; then
#     echo "This script must be run with root priv"
#     exit 1
# fi

SERVER="http://192.168.56.110"
TEST_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TEST_RES="$TEST_DIR/.test_res"
cd $TEST_DIR/../p2

check_apps(){
    curl -H "Host: app1.com" $SERVER
    curl -H "Host: app2.com" $SERVER
    curl $SERVER
}

check_apps