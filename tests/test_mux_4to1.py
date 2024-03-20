import cocotb
import random

from cocotb.triggers import Timer

MAX_ITERATIONS = 10

def verification(dut):
    if(dut.piSel.value == 0 and (dut.poI0.value == dut.piE.value)): return True
    elif(dut.piSel.value == 1 and (dut.poI1.value == dut.piE.value)): return True
    elif(dut.piSel.value == 2 and (dut.poI2.value == dut.piE.value)): return True
    elif(dut.piSel.value == 3 and (dut.poI3.value == dut.piE.value)): return True
    else: return False

@cocotb.test()
async def test_mux_4to1(dut):

    iterNumber = random.randint(1,MAX_ITERATIONS)

    for i in range(iterNumber):

        dut.piE.value = random.randint(0,15)
        dut.piSel.value = random.randint(0,3)

        await Timer(1, 'us')

        assert verification(dut),f"\
            Error! failed random test\n\
            piSel = {dut.piSel.value}, piE = {dut.piE.value}, poI0 = {dut.poI0.value},poI1 = {dut.poI1.value},poI2 = {dut.poI2.value},poI3 = {dut.poI3.value}"