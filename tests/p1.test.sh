#!/bin/bash

#this script is to run with root privilege
# if [[ $EUID -ne 0 ]]; then
#     echo "This script must be run with root priv"
#     exit 1
# fi

SERVER="trazanadS"
TEST_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TEST_RES="$TEST_DIR/.test_res"
cd $TEST_DIR/../p1

check_nodes(){
    echo "checking nodes..."
    vagrant ssh $SERVER -c "kubectl get nodes"
}

check_pods(){
    echo "checking pods..."
    vagrant ssh $SERVER -c "kubectl run test-pod --image=nginx && kubectl wait --for=condition=Ready pod --all --timeout=420s && kubectl get pods"
}


check_nodes
check_pods
