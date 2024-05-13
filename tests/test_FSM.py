"""Finite state machine (FSM)


"""

import cocotb
import random

from cocotb.triggers import Timer

MAX_ITERATIONS = 10

async def clock(dut):
    dut.i_clk.value = 0
    while True:
        dut.i_clk.value = not dut.i_clk.value
        await Timer(10,'us')

@cocotb.test()
async def test_FSM(dut):

    cocotb.start_soon(clock(dut))

    dut.i_rst.value = 1
    dut.i_ack.value = 0
    dut.i_conf.value = 0

    await Timer(30, 'us')

    dut.i_rst.value = 0

    await Timer(50, 'us')
    
    dut.i_conf.value = 1

    await Timer(1000, 'us')

#    assert dut.o_z.value == (dut.i_a.value and dut.i_b.value), f"\
#        Error! failed random test\n\
#        i_a = {dut.i_a.value}, i_b = {dut.i_b.value}, o_z = {dut.o_z.value}"