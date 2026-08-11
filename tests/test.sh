#!/bin/bash

#this script is to run with root privilege
if [[ $EUID -ne 0 ]]; then
    echo "This script must be run with root priv"
    exit 1
fi

TEST_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TEST_RES="$TEST_DIR/.test_res"

structure_test(){
    echo "Checking hidden or sentive file..."

    DIR="$TEST_DIR/.."
    FILE=(".gitkeep" ".vagrant" "token" ".token" ".env")
    
    for file in "${FILE[@]}"; do
        result=$(find "$DIR" -name "$file")

        if [ -n "$result" ]; then
            echo "❌ found : $result"
        fi
    done
}

test(){
    echo "Testing iot..."
    
    structure_test

    # for i in $(seq 1 3); do
    #     echo "Testing p$i..."

    #     chmod +x "$TEST_DIR/p$i.test.sh" && bash "$TEST_DIR/p$i.test.sh"
    
    # done
    rm $TEST_RES
}

test