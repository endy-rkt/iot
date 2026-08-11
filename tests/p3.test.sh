#!/bin/bash

#this script is to run with root privilege
# if [[ $EUID -ne 0 ]]; then
#     echo "This script must be run with root priv"
#     exit 1
# fi

SERVER="http://localhost:30042/"
TEST_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TEST_RES="$TEST_DIR/.test_res"
cd $TEST_DIR/../p3

check_apps(){
    curl $SERVER
}

check_apps