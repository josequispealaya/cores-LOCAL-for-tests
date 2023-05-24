#!/bin/bash

RTL_PATH="rtl/"
COCOTB_MAKEFILE_TEMPLATE='Makefile.cocotb-template'

run_test() {
    module=$1
    module_directory=$2

    echo "Testing $DUT"

    eval "echo \"$(cat $COCOTB_MAKEFILE_TEMPLATE)\"" > $module_directory/Makefile

    make -C $module_directory sim

    rm $module_directory/Makefile
}



DUT=${1:-*}

for dut_path in $(find $RTL_PATH -name "test_$DUT.py")
do
    DUT=$(echo $dut_path | sed -E "s#^.+test_([a-zA-Z0-9_.-]+)\.py\$#\1#")

    # TODO: Si mantenemos nombres unicos para cada modulo, podriamos dejarlos en tests/
    dut_directory=${dut_path%%/test_$DUT.py}

    run_test $DUT $dut_directory

    if [ ! -z "${GUI}" ]; then
        gtkwave $module_directory/*.vcd
    fi
done
