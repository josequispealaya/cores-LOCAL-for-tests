#!/bin/bash

RTL_PATH="rtl/"
COCOTB_MAKEFILE_TEMPLATE='Makefile.cocotb-template'

run_test() {
    module=$1
    module_path=$2

    echo "Testing $DUT"

    # TODO: Si mantenemos nombres unicos para cada modulo, podriamos dejarlos en tests/
    dut_directory=${module_path%%/test_$module.py}

    eval "echo \"$(cat $COCOTB_MAKEFILE_TEMPLATE)\"" > $dut_directory/Makefile

    make -C $dut_directory sim

    rm $dut_directory/Makefile
}



DUT=${1:-*}

for dut_path in $(find $RTL_PATH -name "test_$DUT.py")
do
    DUT=$(echo $dut_path | sed -E "s#^.+test_([a-zA-Z0-9_.-]+)\.py\$#\1#")

    run_test $DUT $dut_path
done
