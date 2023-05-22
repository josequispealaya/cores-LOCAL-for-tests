# This file is public domain, it can be freely copied without restrictions.
# SPDX-License-Identifier: CC0-1.0

import os
import sys
import subprocess
from pathlib import Path

import cocotb
from cocotb.clock import Clock
from cocotb.runner import get_runner
from cocotb.triggers import FallingEdge
from cocotb.triggers import RisingEdge
from cocotb.triggers import Timer


DUT = "uart"
GENERICS = {}

@cocotb.test()
async def simple_test(dut):
    
    #reset
    dut.i_rst.value = 1
    await Timer(10, units='us')
    dut.i_rst.value = 0

    clk = Clock(dut.i_clk, 10, units='us')
    cocotb.start_soon(clk.start())

    dut.i_data.value = 0b10101010
    dut.i_valid.value = 1
    await Timer(20, units='us')
    dut.i_valid.value = 0

    await Timer(10, units='ms')
    assert True

def test_simple_dff_runner():

    sim = os.getenv("SIM", "ghdl")

    proj_path = Path(__file__).resolve().parent.parent

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