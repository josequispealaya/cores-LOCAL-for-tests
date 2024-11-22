#!/bin/bash

# Hacer que el script falle si cualquier comando falla
#set -e

# Imprimir mensaje antes de listar los archivos
## echo "Imprimiendo archivos .py en /code/tests/"
TEST_FILES=$(ls /code/tests/*.py)

##cho "Verificando si el script run_cocotb_tests.sh existe..."
#ls -laR /code/
## ls -l /code/

## echo "Archivos de prueba encontrados en /code/tests:"
## echo "$TEST_FILES"

#AQUI IMPRIME:   test_uartRx.py
#                test_uartTx.py   

##echo "Verificando el contenido de /code/rtl..."
#ls -laR /code/rtl
## ls -l /code/rtl


for TEST_FILE in $TEST_FILES; do
    # Obtener el nombre del test y sacarle la extensión .py
    TEST_NAME=$(basename $TEST_FILE .py)  
    
    ## echo "EL VALOR DE TEST_NAME ES: $TEST_NAME"

    # Eliminar el prefijo "test_" y convertir a minúsculas
    DUT_NAME=$(echo "$TEST_NAME" | sed 's/^test_//' | tr '[:upper:]' '[:lower:]')
 
    ## echo "Ejecutando run_cocotb_tests.sh con argumento: $DUT_NAME"
    /code/run_cocotb_tests.sh "$DUT_NAME"
    
    
    # Verificar si el test falló
    if [ $? -ne 0 ]; then
        echo "El test $TEST_NAME falló. Deteniendo la ejecución."
        exit 1  # Detener el script si un test falla
    fi
done

echo "Todos los tests han pasado correctamente."


exit 0
