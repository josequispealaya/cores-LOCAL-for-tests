#!/bin/make

# Por defecto suponemos que se va a trabajar con la EDU-FPGA 
TARGET = ICESTICK
PINOUT_FILE = pinout.pcf
TOP_LEVEL_FILE = FSM_I2C_FIFO_UART

# El package y tamaño dependen de la plataforma a utilizar.

# Si se usa la EDU-FPGA
ifeq ($(TARGET),EDUFPGA)
	PACKAGE = tq144
	SIZE = --hx4k

endif

# Si se usa el Lattice iCEstick
ifeq ($(TARGET),ICESTICK)
	PACKAGE = tq144
	SIZE = --hx4k
endif

# Sintetizar
synthesis:
	yosys -p "synth_ice40 -top $(TOP_LEVEL_FILE) -json $(TOP_LEVEL_FILE).json" ../$(TOP_LEVEL_FILE).v

# Ejecutar Place and Route
pnr:
	nextpnr-ice40 $(SIZE) --package $(PACKAGE) --json $(TOP_LEVEL_FILE).json --pcf ../$(PINOUT_FILE) --asc $(TOP_LEVEL_FILE).asc $(FORCE)

# Generar Bitstream
bitstream:
	icepack $(TOP_LEVEL_FILE).asc $(TOP_LEVEL_FILE).bin

# Configurar la placa
program:
	iceprog top.bin

# Limpiar subproductos
clean:
	rm *.json
	rm *.asc
	rm *.bin

# Proceso completo
all: synthesis pnr bitstream
