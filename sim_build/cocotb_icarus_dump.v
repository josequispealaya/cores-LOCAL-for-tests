module cocotb_icarus_dump();
initial begin
$dumpfile("/mnt/c/FRBA/PID/repo fork LOCAL para tests/cores-LOCAL-for-tests/sim_build/waveform.vcd");
$dumpvars(0, uart_rx);
end
endmodule
