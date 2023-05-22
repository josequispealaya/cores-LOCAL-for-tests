# This file is public domain, it can be freely copied without restrictions.
# SPDX-License-Identifier: CC0-1.0

import os
import sys
import random
import subprocess
from pathlib import Path

import cocotb
from cocotb.clock import Clock
from cocotb.runner import get_runner
from cocotb.triggers import ClockCycles
from cocotb.triggers import RisingEdge
from cocotb.triggers import FallingEdge
from cocotb.triggers import Timer


DUT = "baudGen"
GENERICS = {"g_divBits":10}




@cocotb.test()
async def baudGen_fixed_test(dut):
    # Start Clock
    cocotb.start_soon(Clock(dut.i_clk, 10, units='ns').start())

    #testeo con un divisor fijo 10 veces

    baudrate = 115200
    div = int(1/(baudrate*10e-9*16))

    tryes = 10

    dut.i_clk.value = 0

    # Reset!
    dut.i_rst.value = 1
    await Timer(random.randint(0,15), units='ns')
    dut.i_rst.value = 0

    #Init setup
    dut.i_baudDiv.value = div


    #Test section
    await RisingEdge(dut.i_clk)

    for x in range(0, tryes, 1):
        for y in range (0, 8, 1):
            for ccount in range (0, 16, 1):
                await ClockCycles(dut.i_clk, div+1, True)
                if (ccount >= 5 and ccount <= 7):
                    await Timer(10, units='ns')
                    # print(dut.o_rxPulse.value)
                    assert dut.o_rxPulse.value == 1, f"\n\
                        Error! Rx pulse missing\n\
                        Try #: {x}, Bit: {y}\n\
                        Clk16 cycle count: {ccount}\n"
            
            await Timer(10, units='ns')
            assert dut.o_txPulse.value == 1, f"\n\
                Error! Tx pulse missing\n\
                Try #: {x}, Bit: {y}\n"

@cocotb.test()
async def baudGen_random_test(dut):

    #testeo con un divisor random 10 veces

    div = random.randint(1, 2**GENERICS["g_divBits"]-1)

    tryes = 10

    dut.i_clk.value = 0

    # Reset!
    dut.i_rst.value = 1
    await Timer(10, units='ns')
    dut.i_rst.value = 0

    #Init setup
    dut.i_baudDiv.value = div

    clk = Clock(dut.i_clk, 10, units='ns')
    cocotb.start_soon(clk.start())

    #Test section
    await RisingEdge(dut.i_clk)

    for x in range(0, tryes, 1):
        for y in range (0, 8, 1):
            for ccount in range (0, 16, 1):
                await ClockCycles(dut.i_clk, div+1, True)
                if (ccount >= 5 and ccount <= 7):
                    await Timer(10, units='ns')
                    # print(dut.o_rxPulse.value)
                    assert dut.o_rxPulse.value == 1, f"\n\
                        Error! Rx pulse missing\n\
                        Try #: {x}, Bit: {y}\n\
                        Clk16 cycle count: {ccount}\n"
            
            await Timer(10, units='ns')
            assert dut.o_txPulse.value == 1, f"\n\
                Error! Tx pulse missing\n\
                Try #: {x}, Bit: {y}\n"
        
        div = random.randint(1, 2**GENERICS["g_divBits"]-1)

        await FallingEdge(dut.i_clk)
        dut.i_rst.value = 1
        await FallingEdge(dut.i_clk)
        dut.i_rst.value = 0
        dut.i_baudDiv.value = div
        await RisingEdge(dut.i_clk)

@cocotb.test()
async def baudGen_rx_sync_test(dut):

    #testeo con un divisor fijo resincronizar el
    #los pulsos para rx;

    div = 0x0f
    resync = random.randint(0, 15)

    tryes = 10

    dut.i_clk.value = 0

    # Reset!
    dut.i_rst.value = 1
    await Timer(10, units='ns')
    dut.i_rst.value = 0

    #Init setup
    dut.i_baudDiv.value = div

    clk = Clock(dut.i_clk, 10, units='ns')
    cocotb.start_soon(clk.start())

    #Test section
    await RisingEdge(dut.i_clk)

    for x in range(0, tryes, 1):
        for y in range (0, 8, 1):
            for ccount in range (0, 16, 1):
                await ClockCycles(dut.i_clk, div+1, True)
                if (ccount == resync):
                    dut.i_rxSync = 1
                    await RisingEdge(dut.i_clk)
                    await FallingEdge(dut.i_clk)
                    dut.i_rxSync = 0
                    break
            for ccount in range (0, 16, 1):
                await ClockCycles(dut.i_clk, div+1, True)
                if (ccount >= 5 and ccount <= 7):
                    await Timer(10, units='ns')
                    assert dut.o_rxPulse.value == 1, f"\n\
                        Error! Rx pulse missing\n\
                        Try #: {x}, Bit: {y}\n\
                        Clk16 cycle count: {ccount}\n"
        
        resync = random.randint(0, 15)

        await FallingEdge(dut.i_clk)
        dut.i_rst.value = 1
        await FallingEdge(dut.i_clk)
        dut.i_rst.value = 0
        dut.i_baudDiv.value = div
        await RisingEdge(dut.i_clk)

def test_simple_dff_runner():

    sim = os.getenv("SIM", "ghdl")

    proj_path = Path(__file__).resolve().parent

    vhdl_sources = []

    for path, subdirs, files in os.walk(proj_path):
        for name in files:
            if name.endswith((".vhd", ".vhdl")):
                sourcePath = os.path.join(path, name)
                print("Adding source: " + sourcePath)
                vhdl_sources.append(os.path.relpath(sourcePath, proj_path))

    runner = get_runner(sim)()
    runner.build(
        vhdl_sources=vhdl_sources, toplevel=DUT.lower(), parameters=GENERICS
    )

    try:
        runner.test(toplevel=DUT.lower(), py_module="test_baudGen", extra_args=["--wave=waveform.ghw", "--stop-delta=1000000"])
    except:
        pass
    
    if (len(sys.argv) > 1):
        if (sys.argv[1] == "--wave"):
            print("Calling gtkwave to view waveform...\n")
            wavefile = os.path.join(proj_path, "sim_build", "waveform.ghw")
            if (os.path.exists(wavefile)):
                prog = ["gtkwave", str(os.path.relpath(wavefile, proj_path))]
                subprocess.run(prog)
        


if __name__ == "__main__":
    test_simple_dff_runner()