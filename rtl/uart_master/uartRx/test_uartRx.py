# This file is public domain, it can be freely copied without restrictions.
# SPDX-License-Identifier: CC0-1.0

import os
import sys
import subprocess
from pathlib import Path

sys.path.append(str(Path(__file__).resolve().parent.parent))

from streamDrv import StreamDrv
from uartDrv import UartDrv


import cocotb
from cocotb.clock import Clock
from cocotb.runner import get_runner
from cocotb.triggers import FallingEdge
from cocotb.triggers import RisingEdge
from cocotb.triggers import ClockCycles
from cocotb.triggers import Timer
from cocotb.triggers import Event
 
import random

DUT = "uartrx"
DATA = [random.randint(0, 255) for _ in range(10)]
CLK_PERIOD_NS = 50
BAUD = 115200

async def rx_pulse_gen(dut):
    await RisingEdge(dut.o_rxSync)
    while True:
        await ClockCycles(dut.i_clk)

@cocotb.test()
async def rx_test(dut):




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
        vhdl_sources=vhdl_sources, toplevel=DUT, parameters=GENERICS
    )

    try:
        runner.test(toplevel=DUT, py_module=os.path.basename(__file__), extra_args=["--wave=waveform.ghw"])
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