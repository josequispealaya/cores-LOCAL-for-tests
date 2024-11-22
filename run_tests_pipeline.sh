#!/bin/bash

# Hacer que el script falle si cualquier comando falla
set -e

# Imprimir mensaje antes de listar los archivos
##echo "Imprimiendo archivos .py en /code/tests/"
##TEST_FILES=$(ls /code/tests/*.py)

echo "Verificando si el script run_cocotb_tests.sh existe..."
ls -laR /code/

echo "Archivos de prueba encontrados en /code/tests:"
echo "$TEST_FILES"

##echo "Verificando el contenido de /code/rtl..."
##ls -laR /code/rtl


for TEST_FILE in $TEST_FILES; do
    # Obtener el nombre del test y sacarle la extensión .py
    TEST_NAME=$(basename $TEST_FILE .py)  
    
    ##echo "Ejecutando test: $TEST_NAME"
    ##echo "Ejecutando run_cocotb_tests.sh con argumento: $TEST_NAME"

    # Eliminar el prefijo "test_" y convertir a minúsculas
    DUT_NAME=$(echo "$TEST_NAME" | sed 's/^test_//' | tr '[:upper:]' '[:lower:]')
 
    /code/run_cocotb_tests.sh "$DUT_NAME"
    
    # Verificar si el test falló
    if [ $? -ne 0 ]; then
        echo "El test $TEST_NAME falló. Deteniendo la ejecución."
        exit 1  # Detener el script si un test falla
    fi
done

echo "Todos los tests han pasado correctamente."


exit 0
