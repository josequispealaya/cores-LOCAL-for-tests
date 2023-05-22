# This file is public domain, it can be freely copied without restrictions.
# SPDX-License-Identifier: CC0-1.0

import os
import sys
import subprocess
from pathlib import Path
import random
import argparse

sys.path.append(str(Path(__file__).resolve().parent.parent))

from streamDrv import StreamDrv
from uartDrv import UartDrv

import cocotb
from cocotb.clock import Clock
from cocotb.runner import get_runner
from cocotb.triggers import ClockCycles
from cocotb.triggers import RisingEdge
from cocotb.triggers import Timer

CLK_PERIOD_NS = 50
DUT = "uarttx"
BAUD = 115200
TEST_CYCLES = 5
RANDOM_BYTES = 6

async def tx_pulse_gen(dut, baudTickCount):
    while True:
        await ClockCycles(dut.i_clk, (baudTickCount + 1) * 15)
        dut.i_txPulse.value = 1
        await RisingEdge(dut.i_clk)
        dut.i_txPulse.value = 0
        await ClockCycles(dut.i_clk, baudTickCount)


@cocotb.test()
async def simple_test(dut):


    baudTickCount = int(1 / (BAUD * CLK_PERIOD_NS * 1e-9 * 16)) ## 1/16 baud tick time in nanoseconds
    assert baudTickCount > 0, "\n\
        Error! Baud rate incompatible with system clock"
    
    stream_in = StreamDrv(dut.i_data, dut.i_valid, dut.o_ready, True)
    uart_drv = UartDrv(BAUD, None, dut.o_txd)


    clk = Clock(dut.i_clk, CLK_PERIOD_NS, units='ns')
    pulse_gen = tx_pulse_gen(dut, baudTickCount)
    cocotb.start_soon(clk.start())
    cocotb.start_soon(pulse_gen)
    await RisingEdge(dut.i_clk)

    #reset
    dut.i_rst.value = 1
    await Timer(random.randint(1, 20), units='ns')
    dut.i_rst.value = 0

    await RisingEdge(dut.i_clk)

    for x in range(TEST_CYCLES):
        #setup random data
        data_bytes = random.randbytes(RANDOM_BYTES)
        for byte in data_bytes:
            await stream_in.write(byte)
            recv = await uart_drv.receive(dut)
            if (recv == -1):
                print("Error! UART Framing error on reception!")
            else:
                assert recv == byte, f"\n\
                Error! Sent: {hex(byte)}, received: {hex(recv)}\n"

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
        runner.test(toplevel=DUT, py_module="test_uartTx", extra_args=["--wave=waveform.ghw", "--stop-delta=1000000"])
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