#
#   Verilog And (Vand)
#
import cocotb
import random

from cocotb.triggers import Timer

MAX_ITERATIONS = 10

@cocotb.test()
async def test_Vand(dut):

    iterNumber = random.randint(1,MAX_ITERATIONS)

    for i in range(iterNumber):

        dut.a.value = random.randint(0,1)
        dut.b.value = random.randint(0,1)

        await Timer(3, 'us')
        
        assert dut.z.value == (dut.a.value and dut.b.value), f"\
            Error! failed random test\n\
            a = {dut.a.value}, b = {dut.b.value}, z = {dut.z.value}"