#
#   cocotb testbench comb_bin_despl
#
import cocotb
import random

from cocotb.triggers import Timer
from cocotb.clock import Clock


MAX_ITERATIONS = 10


@cocotb.test()
async def test_comp_bin_despl(dut):

    cocotb.start_soon(Clock(dut.clk, 1, units="ns").start())  # Create and start the clock

    for _ in range(MAX_ITERATIONS):
        # Generate random binary numbers
        a = random.randint(0, 2**dut.N - 1)  # Range for N-bit unsigned number
        b = random.randint(0, 2**dut.N - 1)

        dut.i_A.value = a
        dut.i_B.value = b
        dut.i_Ctrl.value = random.randint(0, 1)  # Random control signal

        # Wait for signal propagation
        await Timer(3, 'us')

        # Check outputs based on expected comparisons
        expected_mayor = unsigned(a) > unsigned(b)
        expected_igual = unsigned(a) == unsigned(b)
        expected_menor = not expected_mayor and not expected_igual

        assert dut.o_Mayor.value == expected_mayor, f"\
            Error: o_Mayor mismatch\n  a: {a}, b: {b}, expected: {expected_mayor}, actual: {dut.o_Mayor.value}"
        assert dut.o_Igual.value == expected_igual, f"\
            Error: o_Igual mismatch\n  a: {a}, b: {b}, expected: {expected_igual}, actual: {dut.o_Igual.value}"
        assert dut.o_Menor.value == expected_menor, f"\
            Error: o_Menor mismatch\n  a: {a}, b: {b}, expected: {expected_menor}, actual: {dut.o_Menor.value}"

