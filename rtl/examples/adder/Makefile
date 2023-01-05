
# Makefile

PWD=$(shell pwd)    # Guardo el path desde el que se llama al makefile.


# Incluyo este directorio al Python Path.
# Esto permite que Python vea los modulos existentes en este directorio.
# En este ejemplo, se utiliza el módulo 'adder_model.py'.
export PYTHONPATH := $(PWD):$(PYTHONPATH)  

# defaults (VHDL)       #(Verilog)
SIM ?= ghdl             #icarus
TOPLEVEL_LANG ?= vhdl   #verilog

VHDL_SOURCES += adder.vhdl
#VERILOG_SOURCES += $(PWD)/my_design.sv

SIM_ARGS=--vcd=waves.vcd	# Solo para VHDL. En verilog el .vcd se renombra desde el source file.

# TOPLEVEL es el nombre del módulo toplevel (el de los puertos) en tu archivo HDL.
TOPLEVEL := adder

# MODULE is the basename of the Python test file
MODULE   := test_adder

# Incluya las reglas de make que utiliza cocotb para configurar el simulador
include $(shell cocotb-config --makefiles)/Makefile.sim
