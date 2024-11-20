#!/bin/bash

if [ ! -z $1 ]; then
    DUT="--dut $1"
fi

if [ ! -z $2 ]; then
    WAVES="--waves"
fi


export PYTHONPATH=tests/
python3 /usr/local/bin/run_tests.py $DUT $WAVES

