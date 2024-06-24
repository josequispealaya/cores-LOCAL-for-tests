`include "../FSM/FSM.v"
`include "../i2c_master/i2c_master_oe.v"   

module FSMwithI2C #(
    parameter DATA_DEPTH = 8
)(
    input i_clk,
    input i_rst,

    input [2:0] state_tb,
    input [1:0] start,
    input [1:0] stop,
    input [7:0] index,

    inout sda,
    inout scl
);

wire w_start;

wire w_addr_ready;
wire [DATA_DEPTH-1:0] w_addr_bits; 
wire w_addr_valid;

//read parameters
wire w_nbytes_ready;
wire [DATA_DEPTH-1:0] w_nbytes_bits;
wire w_nbytes_valid;

//read interface
wire [DATA_DEPTH-1:0] w_data_read_bits;
wire w_data_read_valid;
wire w_data_read_ready;

//write interface
wire w_data_write_ready;         
wire [DATA_DEPTH-1:0] w_data_write_bits;
wire w_data_write_valid;

//Input Output interface
wire w_sda_oe;
wire w_sda_o;
wire w_sda_i;

//Input output interface
reg r_sda_i;
reg r_scl;
reg r_sda_o;
reg r_sda_oe;
reg r_scl_oe;

wire w_nak;

//Registers
reg r_prev_val;
reg r_in_out_sda;
reg r_sda;

FSM fsm(
    .i_clk(i_clk), 
    .i_rst(i_rst),

    //control
    .o_start(w_start), 
    
    //addr interface
    .i_addr_ready(w_addr_ready),
    .o_addr_bits(w_addr_bits), 
    .o_addr_valid(w_addr_valid),

    //read parameters
    .i_nbytes_ready(w_nbytes_ready),
    .o_nbytes_bits(w_nbytes_bits),
    .o_nbytes_valid(w_nbytes_valid),

    //read interface
    .i_data_read_bits(w_data_read_bits),
    .i_data_read_valid(w_data_read_valid),
    .o_data_read_ready(w_data_read_ready),

    //write interface
    .i_data_write_ready(w_data_write_ready),                         
    .o_data_write_bits(w_data_write_bits),
    .o_data_write_valid(w_data_write_valid),

    .i_nak(w_nak)
);

i2c_master_oe i2c_master(
    //control
    .i_clk(i_clk),
    .i_rst(i_rst),
    .i_start(w_start), 

    //stream input addr interface
    .i_addr_bits(w_addr_bits),
    .i_addr_valid(w_addr_valid),
    .o_addr_ready(w_addr_ready),

    //stream input number of bytes to read
    .i_nbytes_bits(w_nbytes_bits),
    .i_nbytes_valid(w_nbytes_valid),
    .o_nbytes_ready(w_nbytes_ready),

    //stream input data interface
    .i_data_bits(w_data_write_bits),
    .i_data_valid(w_data_write_valid),
    .o_data_ready(w_data_write_ready),

    //stream output read data
    .o_data_bits(w_data_read_bits),
    .o_data_valid(w_data_read_valid),
    .i_data_ready(w_data_read_ready),

    //i2c lines splitted for manual instantiation
    //of io ports

    //strict input lines
    .i_sda_in(w_sda_i),
    .i_scl_in(scl),
    
    //tristate buffers separate lines
    .o_sda_oe(w_sda_oe),
    .o_scl_oe(r_scl_oe),

    //strict output lines
    .o_sda_out(w_sda_o),
    .o_scl_out(scl),
    
    .o_nak(w_nak)
);

assign sda = w_sda_oe ? w_sda_o : 1'bz;
assign w_sda_i = sda;

endmodule