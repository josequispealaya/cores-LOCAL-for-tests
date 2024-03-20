import cocotb
import random

from cocotb.triggers import Timer

MAX_ITERATIONS = 10

def verification(dut):
    if((dut.piI3.value == 1) and (dut.poC.value == 3)): return True
    elif((dut.piI2.value == 1) and (dut.poC.value == 2)): return True
    elif((dut.piI1.value == 1) and (dut.poC.value == 1)): return True
    elif((dut.piI0.value == 1) and (dut.poC.value == 0)): return True
    elif((dut.poC.value == 0) and (dut.poG.value == 1)): return True
    else: return False

@cocotb.test()
async def test_cod_w_prio(dut):

    iterNumber = random.randint(1,MAX_ITERATIONS)
    a = []

    for i in range(iterNumber):

        dut.piI0.value = random.randint(0,1)
        dut.piI1.value = random.randint(0,1)
        dut.piI2.value = random.randint(0,1)
        dut.piI3.value = random.randint(0,1)

        a.append(dut.piI3.value)
        a.append(dut.piI2.value)
        a.append(dut.piI1.value)
        a.append(dut.piI0.value)

        await Timer(1, 'us')

        assert verification(dut),f"\
            Error! failed random test\n\
            poC = {dut.poC.value}, poG = {dut.poG.value}, piI = {a}"