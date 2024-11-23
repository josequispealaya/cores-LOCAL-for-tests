#############################################################
# Este Script se encarga de :
# 1. Leer los nombres de los tests en la carpeta tests/
# 2. Asociar dinámicamente el archivo DUT correspondiente
# 3. Ejecutar cada test dentro del c ontenedor Docker
#############################################################

import os
import subprocess

# Configuración de rutas
TESTS_DIR = "tests"
RTL_DIR = "rtl"
MAKE_COMMAND = "make test"

def find_dut_for_test(test_name):
    """
    Busca de forma recursiva un DUT que coincida con el nombre del test.
    """
    test_base = test_name.replace("test_", "").replace(".py", "")
    for root, _, files in os.walk(RTL_DIR):
        for file in files:
            if file == f"{test_base}.v":
                return os.path.join(root, file)
    return None

def run_test_with_dut(test_name, dut_path):
    """
    Ejecuta un test usando el comando `make test` con el DUT correspondiente.
    """
    env = os.environ.copy()
    env["DUT"] = dut_path
    env["TEST"] = test_name  # Opcional: si necesitas pasar también el test como variable.
    print(f"Running test: {test_name} with DUT: {dut_path}")
    result = subprocess.run(MAKE_COMMAND, shell=True, env=env)
    if result.returncode != 0:
        raise RuntimeError(f"Test {test_name} failed with DUT {dut_path}")

def main():
    test_files = [f for f in os.listdir(TESTS_DIR) if f.endswith(".py")]
    if not test_files:
        print("No tests found.")
        return

    for test_file in test_files:
        dut_path = find_dut_for_test(test_file)
        if not dut_path:
            print(f"No DUT found for test {test_file}. Skipping.")
            continue
        try:
            run_test_with_dut(test_file, dut_path)
        except RuntimeError as e:
            print(str(e))
            exit(1)  # Termina con error si un test falla.

if __name__ == "__main__":
    main()
