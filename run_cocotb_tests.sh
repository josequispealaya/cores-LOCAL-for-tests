#!/bin/bash

if [ ! -z $1 ]; then
    DUT="--dut $1"
fi

if [ ! -z $2 ]; then
    WAVES="--waves"
fi

# Mensajes de depuración

echo "EL DUT ANTES DE SER ENVIADO ES: $DUT"
#echo "WAVES: $WAVES"
#echo "PYTHONPATH: $PYTHONPATH"


export PYTHONPATH=tests


python3 /code/run_tests.py $DUT $WAVES

