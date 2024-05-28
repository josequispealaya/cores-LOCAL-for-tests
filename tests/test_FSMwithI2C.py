"""Finite state machine (FSM) with i2c_master_oe"""

import cocotb
import random

from cocotb.triggers import Timer

MAX_ITERATIONS = 10

async def clock(dut):
    dut.i_clk.value = 0
    while True:
        dut.i_clk.value = not dut.i_clk.value
        await Timer(10,'us')

# clock for clock stretching
async def clock_stretching(dut):
    dut.i_scl.value = 0
    while True:
        dut.i_scl.value = not dut.i_scl.value
        await Timer(325,'us')

@cocotb.test()
async def test_FSMwithI2C(dut):

    cocotb.start_soon(clock(dut))
    cocotb.start_soon(clock_stretching(dut))

    dut.i_rst.value = 1
    dut.i_sda.value = 1

    await Timer(30, 'us')

    dut.i_rst.value = 0

    await Timer(100, 'ms')

#    assert dut.o_z.value == (dut.i_a.value and dut.i_b.value), f"\
#        Error! failed random test\n\
#        i_a = {dut.i_a.value}, i_b = {dut.i_b.value}, o_z = {dut.o_z.value}"