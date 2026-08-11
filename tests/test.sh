#!/bin/bash

#this script is to run with root privilege
if [[ $EUID -ne 0 ]]; then
    echo "This script must be run with root priv"
    exit 1
fi

TEST_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

test(){
    echo "Testing iot..."
    
    for i in $(seq 1 3); do
        echo "Testing p$i..."

        chmod +x "$TEST_DIR/p$i.test.sh" && bash "$TEST_DIR/p$i.test.sh"
    
    done
}

test
