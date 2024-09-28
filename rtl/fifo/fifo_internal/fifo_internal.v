module FIFO_internal
#(
    parameter ADDR_LENGTH = 8, WORD_LENGTH = 8
)
(
    input wire i_clk,
    input wire [WORD_LENGTH - 1 : 0] i_data_in,
    input wire i_read_en,
    input wire i_write_en,
    input wire i_reset,
    output wire [WORD_LENGTH - 1 : 0] o_data_out,
    output wire o_full,
    output wire o_empty
);

reg [ADDR_LENGTH - 1 : 0] w_addr;
reg [ADDR_LENGTH - 1 : 0] r_addr;

wire [ADDR_LENGTH - 1 : 0] w_next_r_addr;
wire [ADDR_LENGTH - 1 : 0] w_next_w_addr;

wire w_aux_write_en;

assign w_next_r_addr = r_addr + 1;
assign w_next_w_addr = w_addr + 1;

assign o_empty = (w_addr == r_addr);
assign o_full = (w_next_w_addr == r_addr);

assign w_aux_write_en = i_write_en & ~o_full;

RAM_DUALPORT #(ADDR_LENGTH, WORD_LENGTH) memory (
    .r_clk(i_clk),
    .w_clk(i_clk),
    .w_write_en(w_aux_write_en),
    .i_write_addr(w_addr),
    .i_read_addr(r_addr),
    .w_data_in(i_data_in),
    .r_data_out(o_data_out)
);

always @(posedge i_clk) begin
    if(i_reset == 1) begin
        r_addr <= {ADDR_LENGTH{1'b0}};
        w_addr <= {ADDR_LENGTH{1'b0}};
    end else begin
        if(i_read_en == 1'b1 && !o_empty) begin
            r_addr <= w_next_r_addr;
        end

        if(i_write_en == 1'b1 && !o_full) begin
            w_addr <= w_next_w_addr;
        end
    end
end

endmodule
