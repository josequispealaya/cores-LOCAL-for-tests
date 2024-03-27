import cocotb
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge

from cocotbext.spi import SpiMaster, SpiSignals, SpiConfig

from drv.streamDrv_lucas import StreamDrv

from numpy.random import randint

CLK_PERIOD_NS = 50  # ns -> 20MHz

def init_clock(dut):
    '''
    Creates clock
    '''
    cocotb.start_soon(Clock(dut.clk, CLK_PERIOD_NS, units='ns').start())

async def init_dut(dut):
    '''
    Initialize DUT signals
    '''
    dut.rst.value       = 1
    dut.tx_tvalid.value = 0
    dut.tx_tdata.value  = 0
    dut.rx_tready.value = 0
    for _ in range(3): await RisingEdge(dut.clk)
    dut.rst.value       = 0
    for _ in range(3): await RisingEdge(dut.clk)

async def init_test (dut):
    '''
    Run all initialization routines and returns drivers.
    '''

    #               DUT DESCRIPTION
    # -------------------------------------------------
    #              ------------------
    #              |                |
    #              |                |<-- tx_tdata
    #  spi_miso <--|                |<-- tx_tvalid
    #  spi_moss -->|   SPI_SLAVE    |--> tx_tready
    #  spi_sclk -->|                |
    #  spi_cs_n -->|                |--> rx_tdata
    #              |                |--> rx_tvalid
    #              |                |<-- rx_tready
    #              |                |
    #       clk -->|>>              |<-- rst
    #              ------------------
    # -------------------------------------------------

    spi_signals = SpiSignals(
        sclk    = dut.spi_sclk,
        mosi    = dut.spi_mosi,
        miso    = dut.spi_miso,
        cs      = dut.spi_cs_n,
    )

    spi_config = SpiConfig(
        word_width          = 8,        # number of bits in a SPI transaction
        sclk_freq           = 10000,    # clock rate in Hz
        cpol                = False,    # clock idle polarity
        cpha                = True,     # clock phase (CPHA=True means data sampled on second edge)
        msb_first           = True,     # the order that bits are clocked onto the wire
        data_output_idle    = 1,        # the idle value of the MOSI or MISO line
        ignore_rx_value     = None,     # MISO value that should be ignored when received
    )

    spi_master  = SpiMaster(spi_signals, spi_config)
    tx_stream   = StreamDrv(dut.clk, dut.tx_tdata, dut.tx_tvalid, dut.tx_tready)   # Its an input stream
    rx_stream   = StreamDrv(dut.clk, dut.rx_tdata, dut.rx_tvalid, dut.rx_tready)   # Its an output stream


    init_clock(dut)
    await init_dut(dut)

    return spi_master, tx_stream, rx_stream

async def end_test(dut):
    '''
    Ends test by waiting a little bit.
    '''
    for _ in range(10): await RisingEdge(dut.clk)

@cocotb.test()
async def test_00_slave_idle_state(dut):
    '''
    Checks initial state of the output signals.
    '''
    spi_master, tx_stream, rx_stream = await init_test(dut)
    for _ in range(100): await RisingEdge(dut.clk)

    assert dut.tx_tready.value == 0
    assert dut.rx_tvalid.value == 0
    assert dut.spi_miso.value == 0


@cocotb.test()
async def test_01_slave_receives_single_data(dut):
    '''
    SPI receives one single random value and it is read from the rx_stream.
    '''
    spi_master, tx_stream, rx_stream = await init_test(dut)

    data = [randint(0, 256)]
    spi_task = cocotb.start_soon(spi_master.write(data))

    recv_data = await rx_stream.read(
        count = 1
    )

    assert recv_data == data

    await spi_task  # Wait until spi_master.write() ends

    await end_test(dut)

@cocotb.test()
async def test_02_slave_receives_single_data_twice(dut):
    '''
    SPI receives one single random value and it is read from the rx_stream, but this is done twice with some delay.
    '''
    spi_master, tx_stream, rx_stream = await init_test(dut)

    for _ in range(2):
        data = [randint(0, 256)]
        spi_task = cocotb.start_soon(spi_master.write(data))
        recv_data = await rx_stream.read(
            count = 1
        )
        assert recv_data == data
        await spi_task  # Wait until spi_master.write() ends

        for _ in range(100): await RisingEdge(dut.clk)

    await end_test(dut)

@cocotb.test()
async def test_03_slave_receives_multiple_data(dut):
    '''
    SPI receives a burst of 10 random values and those are read from the rx_stream inmediately.
    '''
    spi_master, tx_stream, rx_stream = await init_test(dut)

    data = [randint(0, 256) for _ in range(10)]
    spi_task = cocotb.start_soon(spi_master.write(data))

    recv_data = await rx_stream.read(
        count = len(data)
    )

    assert recv_data == data

    await spi_task  # Wait until spi_master.write() ends

    await end_test(dut)

@cocotb.test()
async def test_04_slave_receives_multiple_data_with_delay(dut):
    '''
    SPI receives a burst of 10 random values and those are read from the rx_stream with some random delay.
    '''
    spi_master, tx_stream, rx_stream = await init_test(dut)

    data = [randint(0, 256) for _ in range(10)]
    spi_task = cocotb.start_soon(spi_master.write(data))

    recv_data = await rx_stream.read(
        count       = len(data),
        max_delay   = 100
    )

    assert recv_data == data

    await spi_task  # Wait until spi_master.write() ends

    await end_test(dut)

# @cocotb.test()
# async def test_05_slave_transmit(dut):
#     # FIXME: Este test está mal y se cuelga (darle ctrl+c).. Tiene que ver con que el spi_master no mueve el clock..
#     #        Hay que leer bien como funca en la documentación (https://github.com/schang412/cocotbext-spi)

#     spi_master, tx_stream, rx_stream = await init_test(dut)

#     data = [0x61]

#     await tx_stream.write(data)

#     read_bytes = await spi_master.read(1)

#     assert read_bytes == data

#     await end_test(dut)