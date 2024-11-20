#!/bin/bash

# Imprimir mensaje antes de listar los archivos
echo "Imprimiendo archivos .py en /code/tests/"
TEST_FILES=$(ls /code/tests/*.py)

#echo "Verificando si el script run_cocotb_tests.sh existe..."
#ls -laR /code/
echo "verificando la ruta de test_file"
echo TEST_FILES

echo "Verificando el contenido de /code/rtl..."
ls -laR /code/rtl


for TEST_FILE in $TEST_FILES; do
    # Obtener el nombre del test
    TEST_NAME=$(basename $TEST_FILE .py)  # Le saca la extensión .py
    
    echo "Ejecutando test: $TEST_NAME"
    echo "Ejecutando run_cocotb_tests.sh con argumento: $TEST_NAME"
 
    /code/run_cocotb_tests.sh "$TEST_NAME"
    
    # Verificar si el test falló
    if [ $? -ne 0 ]; then
        echo "El test $TEST_NAME falló. Deteniendo la ejecución."
        exit 1  # Detener el script si un test falla
    fi
done

# echo "Todos los tests han pasado correctamente."

if [ $? -eq 0 ]; then
    echo "Todos los tests han pasado correctamente."
else
    echo "Error: Algunos tests fallaron."
    exit 1
fi

exit 0
