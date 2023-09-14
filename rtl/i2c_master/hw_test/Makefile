#!/bin/make

# Por defecto suponemos que se va a trabajar con la EDU-FPGA 
TARGET = EDUFPGA
FILES = ./i2c_lattice_harness.v
PINOUT_FILE = ./pinout.pcf
TOP_MOD = i2c_lattice_harness
BUILD_FOLDER = build

# El package y tamaño dependen de la plataforma a utilizar.

# Si se usa la EDU-FPGA
ifeq ($(TARGET),EDUFPGA)
	PACKAGE = tq144
	SIZE = --hx4k

endif

# Si se usa el Lattice iCEstick
ifeq ($(TARGET),ICESTICK)
	PACKAGE = tq144
	SIZE = --hx1k
endif

# crear directorio build
mkdir:
	mkdir -p ./${BUILD_FOLDER}

# Sintetizar
synthesis: | mkdir
	yosys -p "synth_ice40 -top $(TOP_MOD) -json ./${BUILD_FOLDER}/top.json" $(FILES)

# Ejecutar Place and Route
pnr:
	nextpnr-ice40 $(SIZE) --package $(PACKAGE) --json ./${BUILD_FOLDER}/top.json --pcf $(PINOUT_FILE) --asc ./${BUILD_FOLDER}/top.asc

# Generar Bitstream
bitstream:
	icepack ./${BUILD_FOLDER}/top.asc ./${BUILD_FOLDER}/top.bin

# Configurar la placa
program:
	iceprog ./${BUILD_FOLDER}/top.bin

# Limpiar archivos
	rm ./${BUILD_FOLDER}/*.bin
	rm ./${BUILD_FOLDER}/*.asc
	rm ./${BUILD_FOLDER}/*.json

# Proceso completo
all: mkdir synthesis pnr bitstream program
