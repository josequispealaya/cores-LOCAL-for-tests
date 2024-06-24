"""Finite state machine (FSM) with i2c_master_oe"""

import cocotb
import random

from cocotb.triggers import Timer
import cocotb.types

#VARIABLES GLOBALES
#------------------

#REGISTROS
#------------------------------------------------------------------------
none = ['0','1','0','1','0','1','0','1']
registers = [none,none,none,none,none,none,none,none,none]
#------------------------------------------------------------------------

#INDICES
#------------------------------------------------------------------------
index_check_addr=0
index_data = 0
index_registers=0
register_pointer=0
read_index=0
#------------------------------------------------------------------------

#FLAGS
#------------------------------------------------------------------------
gen_ack_nack=0
bit_RW='2'

flag_reading_register=0
error=0

scl_prev_value = '1'
sda_prev_value = '1'
start = 0
stop = 1
#------------------------------------------------------------------------

#OTRAS VARIABLES
#------------------------------------------------------------------------
REGISTER_POINTER_CONFIG_SLAVE = "00001001"        #0x09
REGISTER_CONFIG_DATA_SLAVE = "00001000"           #0x04
ADDR_VECTOR = "01001110"                  #0x4e
data_write_vector = []
#------------------------------------------------------------------------

#ESTADOS
#------------------------------------------------------------------------
IDLE = 0
CHECK_ADDR = 1
ACK_NACK=2
WRITE=3             # Escribir en el registro
READ=4              # Leer el registro
WAIT_ACK_NACK=5
#------------------------------------------------------------------------

state = IDLE

async def clock(dut):
    dut.i_clk.value = 0
    while True:
        dut.i_clk.value = not dut.i_clk.value
        await Timer(10,'us')

def i2c_slave(dut,scl,sda):
    global index_check_addr
    global gen_ack_nack
    global bit_RW
    global index_data
    global data_write_vector
    global register_pointer
    global error
    global ADDR_VECTOR 
    global index_registers
    global state     
    global registers
    global scl_prev_value
    global sda_prev_value
    global start
    global stop

    dut.state_tb.value=state
    dut.start.value=start
    dut.stop.value=stop
    dut.index.value=index_registers

    if(scl_prev_value=='1' and scl=='1' and sda=='1' and sda_prev_value=='0' and state!=READ): 
            start=0
            stop=1
            state = IDLE
    elif(scl_prev_value=='1' and scl=='1' and sda=='0' and sda_prev_value=='1' and state!=READ): 
            start=1
            stop=0
            state = CHECK_ADDR

            index_check_addr=0
            gen_ack_nack=0
            bit_RW='2'
            index_data = 0
            index_registers=-1
            data_write_vector = []
            error=0

    if(start==0 and stop==1):
        index_check_addr=0
        gen_ack_nack=0
        bit_RW='2'
        index_data = 0
        index_registers=-1
        data_write_vector = []
        error=0
    elif(not (scl=='1' and scl_prev_value=='0')):
        state=state                                                             #Accion redudante
    elif(state==CHECK_ADDR):

        if(index_check_addr<0): index_check_addr=index_check_addr+1             #Para cuando viene del estado WAIT_ACK_NACK y darle un ciclo de scl mas al slave
        elif(sda==ADDR_VECTOR[index_check_addr] and index_check_addr<7):
            index_check_addr=index_check_addr+1
        elif(sda!=ADDR_VECTOR[index_check_addr] and index_check_addr<7):
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
                index_registers=0
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
            index_registers=0
            state=IDLE
        elif(gen_ack_nack==5):
            dut.sda.value=0
            state=IDLE

            index_check_addr=-1
            gen_ack_nack=0
            bit_RW='2'
            index_data = 0
            index_registers=-1
            data_write_vector = []
            register_pointer=0
            error=0

        verification()

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
        index_registers=index_registers+1
        if(index_registers>7):
            gen_ack_nack=4 
            state=ACK_NACK

    scl_prev_value=scl
    sda_prev_value=sda

def verification():
    global index_check_addr
    global gen_ack_nack
    global bit_RW
    global index_data
    global data_write_vector
    global register_pointer
    global error
    global ADDR_VECTOR 
    global index_registers
    global state     
    global registers
    global scl_prev_value
    global sda_prev_value
    global start
    global stop

    if(gen_ack_nack==2):
        assert error, "Wrong ADDR slave"
    elif(gen_ack_nack==3):
        assert (register_pointer!=int(REGISTER_POINTER_CONFIG_SLAVE,2)), "Wrong register pointer"
    elif(gen_ack_nack==5):
        assert (registers[register_pointer]!=int(REGISTER_CONFIG_DATA_SLAVE,2)), "Wrong register information"


@cocotb.test()
async def test_FSMwithI2C(dut):  

    scl = dut.scl.value.binstr
    sda = dut.sda.value.binstr
    clk_prev_value = dut.i_clk.value.binstr

    contador=100000    

    cocotb.start_soon(clock(dut))

    dut.i_rst.value = 1

    await Timer(30, 'us')

    dut.i_rst.value = 0

    while contador>0:

        clk=dut.i_clk.value.binstr
        scl = dut.scl.value.binstr
        sda = dut.sda.value.binstr

        if(clk=='1' and clk_prev_value=='0'): i2c_slave(dut,scl,sda)        #Positive edge del clk

        contador = contador - 1
        clk_prev_value=clk

        await Timer(10, 'us')