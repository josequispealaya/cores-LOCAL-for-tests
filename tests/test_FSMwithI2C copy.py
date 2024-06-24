"""Finite state machine (FSM) with i2c_master_oe"""

import cocotb
import random

from cocotb.triggers import Timer
import cocotb.types

MAX_ITERATIONS = 10
CONFIG_REGISTER_WRITE = "00001001"        #0x09
none = ['0','0','0','0','0','0','0','0']
index_check_addr=0
gen_ack_nack=0
bit_RW='2'
index_data = 0
index_registers=0
data_write_vector = []
register_pointer=0
flag_reading_register=0
error=0
addr_vector = "01001110"             #0x4e
aux=2
registers = [none,none,none,none,none,none,none,none,none]
read_index=0
flag_for_wait_1scl_clock=0
#
#-----------------------------------------------------
#

IDLE = 0
CHECK_ADDR = 1
ACK_NACK=2
WRITE=3             # Escribir en el registro
READ=4              # Leer el registro
WAIT_ACK_NACK=5

state = CHECK_ADDR

async def clock(dut):
    dut.i_clk.value = 0
    while True:
        dut.i_clk.value = not dut.i_clk.value
        await Timer(10,'us')

def i2c_slave(dut,start,stop):
    global none
    global index_check_addr
    global gen_ack_nack
    global bit_RW
    global index_data
    global data_write_vector
    global register_pointer
    global flag_reading_register
    global error
    global addr_vector 
    global index_registers
    global state  
    global aux      
    global registers
    global flag_for_wait_1scl_clock

    sda = dut.sda.value.binstr

    if(stop==1): aux=2

    if(stop==1 or aux==start): 
        aux=aux+1
        index_check_addr=0
        gen_ack_nack=0
        bit_RW='2'
        index_data = 0
        index_registers=0
        data_write_vector = []
        register_pointer=0
        flag_reading_register=0
        error=0

        if(start==2): state=CHECK_ADDR
        elif(stop==1): 
            aux=2
            state=IDLE

    dut.state_tb.value=state

    if(state==IDLE):
        state=CHECK_ADDR
    elif(state==CHECK_ADDR):

        if(index_check_addr<0): index_check_addr=index_check_addr+1             #Para cuando viene del estado WAIT_ACK_NACK y darle un ciclo de scl mas al slave
        elif(sda==addr_vector[index_check_addr] and index_check_addr<7):
            index_check_addr=index_check_addr+1
        elif(sda!=addr_vector[index_check_addr] and index_check_addr<7):
            error=1
            index_check_addr=index_check_addr+1
        elif(index_check_addr>=7):
            bit_RW = sda
            if(error): gen_ack_nack=2
            else: gen_ack_nack=1

            state=ACK_NACK

    elif(state==ACK_NACK):

        if(gen_ack_nack==1):
            dut.sda.value=0

            if(bit_RW=='0'):
                index_data=7
                state=WRITE
            else:
                index_registers=7
                state=READ

        elif(gen_ack_nack==2):
            dut.sda.value=1
            state=CHECK_ADDR
        elif(gen_ack_nack==3):
            dut.sda.value=0
            index_data=7
            state=WRITE
        elif(gen_ack_nack==4):
            dut.sda.value=0
            state=CHECK_ADDR
        elif(gen_ack_nack==5):
            dut.sda.value=0
            state=CHECK_ADDR

            index_check_addr=-1
            gen_ack_nack=0
            bit_RW='2'
            index_data = 0
            index_registers=0
            data_write_vector = []
            register_pointer=0
            flag_reading_register=0
            error=0

    elif(state==WRITE):
        if(index_data>=0):
            data_write_vector.append(sda)
            index_data=index_data-1
        
        if(gen_ack_nack!=3 and index_data<0):
            gen_ack_nack=3
            register_pointer=int("".join(data_write_vector),2)
            data_write_vector=[]
            state=ACK_NACK
        elif(index_data<0):
            registers[register_pointer] = data_write_vector
            state=ACK_NACK
            gen_ack_nack=5
    elif(state==READ):
        dut.sda.value=int(registers[register_pointer][index_registers])
        index_registers=index_registers-1
        if(index_registers<=0):
            gen_ack_nack=4 
            state=WAIT_ACK_NACK
    elif(state==WAIT_ACK_NACK):
        if(sda=='1' and flag_for_wait_1scl_clock==1):

            index_check_addr=-1
            gen_ack_nack=0
            bit_RW='2'
            index_data = 0
            index_registers=0
            data_write_vector = []
            register_pointer=0
            flag_reading_register=0
            error=0

            state=CHECK_ADDR
            flag_for_wait_1scl_clock=0
        elif(sda=='0' and flag_for_wait_1scl_clock==1):
            state=READ
            flag_for_wait_1scl_clock=0

        if(flag_for_wait_1scl_clock==0): flag_for_wait_1scl_clock=1

@cocotb.test()
async def test_FSMwithI2C(dut):  

    scl = dut.scl.value.binstr
    sda = dut.sda.value.binstr

    contador=100000
    scl_prev_value=scl
    sda_prev_value=sda
    start = 0
    stop = 0     

    cocotb.start_soon(clock(dut))

    dut.i_rst.value = 1

    await Timer(30, 'us')

    dut.i_rst.value = 0

    while contador>0:

        scl = dut.scl.value.binstr
        sda = dut.sda.value.binstr

        if(scl_prev_value=='1' and scl=='1' and sda=='0' and sda_prev_value=='1'): 
            start=start+1
            stop=0
        elif(scl_prev_value=='1' and scl=='1' and sda=='1' and sda_prev_value=='0'): 
            start=0
            stop=1

        dut.start.value=start
        dut.stop.value=stop

        if(scl=='1' and scl_prev_value=='0' and (start!=stop)): i2c_slave(dut,start,stop)        #Positive edge del scl

        contador = contador - 1
        scl_prev_value=scl
        sda_prev_value=sda

        await Timer(10, 'us')