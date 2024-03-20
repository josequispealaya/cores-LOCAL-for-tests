import cocotb
import random

from cocotb.triggers import Timer

MAX_ITERATIONS = 10
N = 8

def flip_num(my_nu):
    return '1' if(my_nu == '0') else '0';

def gray_to_binary(gray):

    binary_code = ""
    binary_code += gray[0]
    for i in range(1,len(gray)):
        if(gray[i] == '0'):
            binary_code += binary_code[i-1]
        else:
            binary_code += flip_num(binary_code[i-1])
    
    return int(binary_code,2)

def verification(dut):
    if(dut.poBin.value == gray_to_binary(str(dut.piGray.value))): return True
    else: return False

@cocotb.test()
async def test_bin2gray(dut):

    iterNumber = random.randint(1,MAX_ITERATIONS)
    maxNumber = pow(2,N) - 1

    for i in range(iterNumber):

        dut.piGray.value = random.randint(0,maxNumber)

        await Timer(1, 'us')

        assert verification(dut),f"\
            Error! failed random test\n\
            poBin = {dut.poBin.value}, piGray = {dut.piGray.value}"