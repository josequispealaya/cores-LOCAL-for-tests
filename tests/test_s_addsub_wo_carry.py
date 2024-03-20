import cocotb
import random

from cocotb.triggers import Timer

MAX_ITERATIONS = 10
N = 4

def verification(dut):
    if((dut.piOp.value == 0) and ((int(str(dut.piA.value),10) + int(str(dut.piB.value),10)) == int(str(dut.poZ.value),10))): return True
    elif((dut.piOp.value == 1) and ((int(str(dut.piA.value),10) - int(str(dut.piB.value),10)) == int(str(dut.poZ.value),10))): return True
    else: return False

@cocotb.test()
async def test_s_addsub_wo_carry(dut):

    iterNumber = random.randint(1,MAX_ITERATIONS)
    maxNumber = pow(2,N)

    for i in range(iterNumber):

        dut.piA.value = random.randint(((-1)*maxNumber/2),((maxNumber/2)-1))
        dut.piB.value = random.randint(((-1)*maxNumber/2),((maxNumber/2)-1))

        dut.piOp.value = random.randint(0,1)

        await Timer(1, 'us')

        assert verification(dut),f"\
            Error! failed random test\n\
            poZ = {dut.poZ.value}, piA = {dut.piA.value}, piB = {dut.piB.value} , piOp = {dut.piOp.value}"