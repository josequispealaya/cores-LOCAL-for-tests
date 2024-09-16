module RAM_DUALPORT
#(
    parameter ADDR_BITS = 8, WORD_LENGTH = 8
)
(
    input wire r_clk,
    input wire w_clk,
    input wire w_write_en,
    input unsigned [ADDR_BITS - 1 : 0] w_addr,
    input unsigned [ADDR_BITS - 1 : 0] r_addr,
    input wire [WORD_LENGTH - 1 : 0] w_data_in,
    output reg [WORD_LENGTH - 1 : 0] r_data_out
);

reg [WORD_LENGTH - 1 : 0] MEMORY[2**ADDR_BITS - 1 : 0];

always @(posedge w_clk) begin
    if (w_write_en == 1'b1) begin
        MEMORY[w_addr] <= w_data_in;
    end
end

always @(posedge r_clk) begin
    r_data_out <= MEMORY[r_addr];
end

endmodule