#!/bin/bash

if [ ! -z $1 ]; then
    DUT="--dut $1"
fi

if [ ! -z $2 ]; then
    WAVES="--waves"
fi

# Mensajes de depuración

echo "EL DUT ANTES DE SER ENVIADO ES: $DUT"
# Aquí imprime --dut test_uartRx    y    --dut test_uartTx     
#echo "WAVES: $WAVES"
#echo "PYTHONPATH: $PYTHONPATH"


export PYTHONPATH=tests

#AGREGAMOS ..
##rm -rf build
##mkdir -p build
#

python3 /code/run_tests.py $DUT $WAVES

