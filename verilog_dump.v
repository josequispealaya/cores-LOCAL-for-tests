module cocotb_icarus_dump();
initial begin
    $dumpfile("waveform.vcd");
    $dumpvars(0, REPLACE_WITH_MODULE_NAME);
end
endmodule
