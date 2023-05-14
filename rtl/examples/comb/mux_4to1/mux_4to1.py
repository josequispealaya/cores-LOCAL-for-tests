import os
import subprocess
from pathlib import Path
import argparse
import random

import cocotb
from cocotb.runner import get_runner
from cocotb.triggers import Timer

DUT ="ej_4"

@cocotb.test()
async def mux_4to1_test(dut):
       for E in range(5):
            for I in range(3):
                dut.piSel.value = I  
                dut.piE.value = E


                await Timer(2, units='ns')

                print(f"[{E}] piSel=|{dut.piSel.value}|poI0=|{dut.poI0.value}|poI1=|{dut.poI1.value}|poI2=|{dut.poI2.value}|poI3=|{dut.poI3.value}|")

@cocotb.test()
async def mux_4to1_test_random(dut):
       for E in range(10):
                dut.piSel.value = random.randint(0, 1)  
                dut.piE.value = random.randint(0, 4)
                

                await Timer(2, units='ns')

                print(f"[{E}] piSel=|{dut.piSel.value}|poI0=|{dut.poI0.value}|poI1=|{dut.poI1.value}|poI2=|{dut.poI2.value}|poI3=|{dut.poI3.value}|")

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
        vhdl_sources=vhdl_sources, toplevel=DUT
    )

    try:
        runner.test(toplevel=DUT, py_module=os.path.basename(__file__)[:-3], extra_args=["--wave=waveform.ghw", "--stop-delta=1000000"])
    except:
        pass
        


if __name__ == "__main__":
    
    parser = argparse.ArgumentParser()
    parser.add_argument("-w", "--wave", action="store_true", help="Open gtk-wave on finish")
    parser.add_argument("-vw", "--view-wave", action="store_true", help="Open gtkwave, does not simulate again")

    args = parser.parse_args()

    if not args.view_wave:
        test_simple_dff_runner()
    if args.wave or args.view_wave:
        print("Calling gtkwave to view waveform...\n")
        proj_path = Path(__file__).resolve().parent
        wavefile = os.path.join(proj_path, "sim_build", "waveform.ghw")
        if (os.path.exists(wavefile)):
            prog = ["gtkwave", str(os.path.relpath(wavefile, proj_path))]
            subprocess.run(prog)
