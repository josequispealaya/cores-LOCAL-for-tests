import cocotb
import random

from cocotb.triggers import Timer

MAX_ITERATIONS = 10
N = 8

def verification(dut):
    if((dut.piA.value == dut.piB.value) and (dut.poIgual.value == 1) and (dut.poMayor.value == 0) and (dut.poMenor.value == 0)): return True
    elif((int(str(dut.piA.value),10) > int(str(dut.piB.value),10)) and (dut.poIgual.value == 0) and (dut.poMayor.value == 1) and (dut.poMenor.value == 0)): return True
    elif((int(str(dut.piA.value),10) < int(str(dut.piB.value),10)) and (dut.poIgual.value == 0) and (dut.poMayor.value == 0) and (dut.poMenor.value == 1)): return True
    else: return False

@cocotb.test()
async def test_comparator(dut):

    iterNumber = random.randint(1,MAX_ITERATIONS)
    maxNumber = pow(2,N)

    for i in range(iterNumber):

        # Complemento A 2

        dut.piA.value = random.randint(((-1)*maxNumber/2),((maxNumber/2)-1))
        dut.piB.value = random.randint(((-1)*maxNumber/2),((maxNumber/2)-1))

        await Timer(1, 'us')

        assert verification(dut),f"\
            Error! failed random test\n\
            poMayor = {dut.poMayor.value}, poMenor = {dut.poMenor.value}, poIgual = {dut.poIgual.value} , piA = {dut.piA.value}, piB = {dut.piB.value}"