`include "../FSM/FSM.v"
`include "../i2c_master/i2c_master_oe.v"   

module FSMwithI2C #(
    parameter DATA_DEPTH = 8
)(
    input i_clk,
    input i_rst,

    input i_sda,
    input i_scl,

    output o_sda_oe,
    output o_scl_oe,

    output o_sda,
    output o_scl
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

wire w_nak;

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
    .i_sda_in(i_sda),
    .i_scl_in(i_scl),
    
    //tristate buffers separate lines
    .o_sda_oe(o_sda_oe),
    .o_scl_oe(o_scl_oe),

    //strict output lines
    .o_sda_out(o_sda),
    .o_scl_out(o_scl),
    
    .o_nak(w_nak)
);


endmodule