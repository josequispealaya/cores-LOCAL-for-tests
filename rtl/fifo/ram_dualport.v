module RAM_DUALPORT
#(
    parameter ADDR_BITS = 8, WORD_LENGTH = 8
)
(
    input wire r_clk,
    input wire w_clk,
    input wire w_write_en,
    input [ADDR_BITS - 1 : 0] i_write_addr,
    input [ADDR_BITS - 1 : 0] i_read_addr,
    input wire [WORD_LENGTH - 1 : 0] w_data_in,
    output reg [WORD_LENGTH - 1 : 0] r_data_out
);

reg [ADDR_BITS - 1 : 0] r_write_addr;
reg [ADDR_BITS - 1 : 0] r_read_addr;

reg [WORD_LENGTH - 1 : 0] MEMORY[2**ADDR_BITS - 1 : 0];

assign r_write_addr = i_write_addr;
assign r_read_addr = i_read_addr;

always @(posedge w_clk) begin
    if (w_write_en == 1'b1) begin
        MEMORY[r_write_addr] <= w_data_in;
    end
end

always @(posedge r_clk) begin
    r_data_out <= MEMORY[r_read_addr];
end

endmodule