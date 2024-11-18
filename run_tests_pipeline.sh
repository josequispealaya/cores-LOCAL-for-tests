#!/bin/bash

# Imprimir mensaje antes de listar los archivos
echo "Imprimiendo archivos .py en /usr/local/bin/tests/"
TEST_FILES=$(ls /usr/local/bin/tests/*.py)

echo "Verificando si el script run_cocotb_tests.sh existe..."
ls -l /usr/local/bin/


for TEST_FILE in $TEST_FILES; do
    # Obtener el nombre del test
    #TEST_NAME=$(basename $TEST_FILE .py)
    TEST_NAME=$(basename $TEST_FILE .py)

    echo "Ejecutando test: $TEST_NAME"
    
    # Ejecutar el test específico usando el script que ya se tiene
    # ./run_cocotb_tests.sh $TEST_NAME
    #/usr/local/bin/run_cocotb_tests.sh $TEST_NAME

    echo "Ejecutando test: $TEST_NAME"
    echo "Ejecutando run_cocotb_tests.sh con argumento: $TEST_NAME"
    /usr/local/bin/run_cocotb_tests.sh "$TEST_NAME"
    #/usr/local/bin/run_cocotb_tests.sh test_uartRx
    #/usr/local/bin/run_cocotb_tests.sh test_uartTx
    
    # Verificar si el test falló
    if [ $? -ne 0 ]; then
        echo "El test $TEST_NAME falló. Deteniendo la ejecución."
        exit 1  # Detener el script si un test falla
    fi
done

echo "Todos los tests han pasado correctamente."
exit 0
