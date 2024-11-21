import argparse
import logging
import os
import subprocess

from cocotb.runner import get_runner
from tempfile import TemporaryDirectory


# Build and test configs
HDL_LANGUAGE = 'verilog'
VERILOG_SIM_DEFAULT = 'icarus'
VERILOG_GPI_INTERFACES = ["vpi"]
#TESTS_DIRECTORY = 'tests'
#MODULES_DIRECTORY = 'rtl'
TESTS_DIRECTORY = os.path.abspath('tests')
MODULES_DIRECTORY = os.path.abspath('rtl')
ICARUS_CFG_FILE = 'icarus.cf'

# Verilog directives to dump the test result in a vcd waveform file
VERILOG_DUMP_CONFIG_FILE = 'verilog_dump.v'
MODULE_PLACEHOLDER = 'REPLACE_WITH_MODULE_NAME'
WAVEFORM_FILE = 'waveform.vcd'

sim = os.getenv('SIM', VERILOG_SIM_DEFAULT)
logger = logging.getLogger(name='run_tests')


#import os

#print(f"TESTS_DIRECTORY: {os.path.abspath(TESTS_DIRECTORY)}")
#print(f"MODULES_DIRECTORY: {os.path.abspath(MODULES_DIRECTORY)}")
#print(f"Does TESTS_DIRECTORY exist? {os.path.exists(TESTS_DIRECTORY)}")
#print(f"Does MODULES_DIRECTORY exist? {os.path.exists(MODULES_DIRECTORY)}")


if os.path.exists(TESTS_DIRECTORY):
    print(f"Contents of TESTS_DIRECTORY ({TESTS_DIRECTORY}):")
    for root, dirs, files in os.walk(TESTS_DIRECTORY):
        print(f"Root: {root}")
        print(f"Directories: {dirs}")
        print(f"Files: {files}")

if os.path.exists(MODULES_DIRECTORY):
    print(f"Contents of MODULES_DIRECTORY ({MODULES_DIRECTORY}):")
    for root, dirs, files in os.walk(MODULES_DIRECTORY):
        print(f"Root: {root}")
        print(f"Directories: {dirs}")
        print(f"Files: {files}")



def get_testable_modules():
    """ Get all testable modules

        Return a list of tuples with (module, module_path, test_path)
    """
    modules = {}

    for dirpath, dirnames, filenames in os.walk(MODULES_DIRECTORY):
        for file in filenames:
            if file.endswith('.v'):
                # Diccionario (clave = valor)
                #modules[file.removesuffix('.v')] = os.path.join(dirpath, file)
                modules[file.removesuffix('.v').replace('_', '').lower()] = os.path.join(dirpath, file)
    # TESTEO
    # Imprimir el contenido del diccionario modules
    #     print("Contents of modules dictionary:")
    #        for module, path in modules.items():
    #        print(f"Module: {module}, Path: {path}") 

    # print("FIN DE: Contents of modules dictionary:")

    testable_modules = []

    # print(f"ANTES DE ENTRAR AL FOR NUEVAMENTE IMPRIMI EL Contents of TESTS_DIRECTORY ({TESTS_DIRECTORY}):")
    
    for dirpath, dirnames, filenames in os.walk(TESTS_DIRECTORY):
        #print(f"EL DIRPATH ES: ({dirpath})")
        #print(f"EL DIRNAME ES: ({dirnames})")
        #print(f"EL FILENAME ES: ({filenames})")
        for file in filenames:
         #   print(f"Segundo for")

            #print(f"EL FILE ES: ({file})")

            if file.startswith('test_') and file.endswith('.py'):
                #module = file.removeprefix('test_').removesuffix('.py')
                module = file.removeprefix('test_').removesuffix('.py').replace('_', '').lower()
                
                print(f"EL MODULE ES: ({module})")
                # AQUÍ IMPRIME: uarttx     uartrx

                module_path = modules.get(module)

                print(f"EL MODULE_PATH ES: {module_path}")

                if module_path:
                    test_path = os.path.join(dirpath, file)
                    testable_modules.append((module, module_path, test_path))
 

    # Imprimir el contenido de testable_modules
    print("Testable Modules  ANTES DEL RETURN:")
    for module, module_path, test_path in testable_modules:
        print(f"Module: {module}, Module Path: {module_path}, Test Path: {test_path}")

    # print("IMPRIÓ ALGO???????")

    return testable_modules

def config_waveform_dump(tmp_dir, module):
    """ Generates a temporary config file to dump a waveform file

        Returns a the tmp configuration file path
    """

    with open(VERILOG_DUMP_CONFIG_FILE, 'r') as file:
        filedata = file.read()

    filedata = filedata.replace(MODULE_PLACEHOLDER, module)

    tmp_conf = os.path.join(tmp_dir, VERILOG_DUMP_CONFIG_FILE)

    with open(tmp_conf, 'w+') as file:
        file.write(filedata)

    return tmp_conf

def test_cocotb(dut, waves=False):

    runner = get_runner(sim)

    testeable_modules = get_testable_modules()

    #PRUEBA
    #print("MODULES IN Testable Modules:")
    #for module, module_path, test_path in testeable_modules:
    #    print(f"Module: {module}, Module Path: {module_path}, Test Path: {test_path}")
    # Aquí me imprime: uarttx

    print(f"EL DUT PARA SER COMPARADO ES:  ({dut})")
    # Aquí me imprime: uartrx    
    if dut:
        modules = [mod for mod in testeable_modules if mod[0] == dut]

        #PRUEABA
        #print("MODULESs para ser comparado!!!!!:")
        #for module in modules:
        #    print(f"Module: {module} ")

        #print("Comparamos!!!!!")

        if modules == []:
            logger.error(f'Missing DUT {dut}')
            return 1
    
        # print("PASAMOS EL IF?????:")
    
    else:
        modules = testeable_modules


    for module, module_path, test_path in modules:
        #PRUEBAS
        print(f"EL MODULES ES: ({module})")
        print(f"EL MODULE_PATH ES: ({module_path})")
        #print(f"EL TEST_PATH ES: ({test_path})")

        with TemporaryDirectory() as tmp_dir:
            
            #PRUEBA
            #print(" ¿¿¿¿  PASÓ EL WITH   ???:")

            #SE CAMBIÓ 
            #module_dir = module_path.removesuffix(f'{module}.v')
            module_dir = os.path.dirname(module_path)
            print(f"El directorio base del módulo es: {module_dir}")

            print(f"EL MODULE SIN SUFIJO .V ES: ({module_dir})")

            print(f"module_path: {module_path}")
            print(f"tmp_dir: {tmp_dir}")
            print(f"ICARUS_CFG_FILE: {os.path.abspath(ICARUS_CFG_FILE)}")
            print(f"build_dir: {module_dir}")
            
            # Usa el directorio temporal para construir un directorio único para el módulo
            build_dir = os.path.join(tmp_dir, module)
            print(f"NUEVO build_dir: {build_dir}")
            
            runner.build(
                verilog_sources = [module_path, config_waveform_dump(tmp_dir, module)],
                hdl_toplevel = module,
                #SE MODIFICÓ
                #build_dir = module_dir,
                build_dir = os.path.join(tmp_dir, module)
                build_args = ["-f", os.path.abspath(ICARUS_CFG_FILE)],
            )

            print(" ¿¿¿¿  RUNNER.BUILD   ???:") 

            runner.test(
                hdl_toplevel_lang=HDL_LANGUAGE,
                hdl_toplevel=module,
                test_module=f"test_{module}",
                gpi_interfaces=VERILOG_GPI_INTERFACES,
                build_dir=module_dir,
                test_dir=module_dir,
                plusargs=['-f', os.path.abspath(ICARUS_CFG_FILE)],
                waves=True,
            )
        

        if dut and waves:
            waveform = os.path.join(module_dir, WAVEFORM_FILE)
            subprocess.run(['gtkwave', waveform])


def parse_args():
    # SE CORRIGIÓ TUN POR RUN
    #p = argparse.ArgumentParser(prog='tun_tests.py',
    #                            description='Helper to run tests')
    p = argparse.ArgumentParser(prog='run_tests.py',
                                description='Helper to run tests')

    p.add_argument('--dut', help='Run test for one DUT')

    dut = p.add_argument_group('dut')
    dut.add_argument('-w', '--waves', action='store_true', help='Open waveforms for ')

    return p.parse_args()


if __name__ == "__main__":
    args = parse_args()

    test_cocotb(args.dut, args.waves)
