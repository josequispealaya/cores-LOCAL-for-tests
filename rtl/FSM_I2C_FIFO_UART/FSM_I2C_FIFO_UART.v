`include "../FSM/FSM.v"
`include "../i2c_master/i2c_master_oe.v"
`include "../fifo/fifo_internal/fifo_internal.v"
`include "../fifo/interface/fifo.v"
`include "../fifo/ram_dualport.v"
`include "../uart/uart.v"
`include "../uart/uart_rx.v"
`include "../uart/uart_tx.v"
`include "../uart/uart_clkgen.v"

module FSM_I2C_FIFO_UART #(
    parameter DATA_DEPTH = 8, DIV_BITS = 10, DIV_CLK_NUMBER=10, SEND_SENSOR_DATA = 165
)(
    input i_clk,
    input i_rst,

    input i_rx,
    output o_tx,

    inout sda,
    inout scl
);

wire w_start;
wire w_nak;

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
reg r_scl_oe;

//Registers
reg r_prev_val;
reg r_in_out_sda;
reg r_sda;

//FSM fifo interface
wire w_fifo_full;

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

    .i_nak(w_nak),

    .i_ready_in(w_ready_in),
    .o_data_in(w_data_in),
    .o_data_in_valid(w_data_in_valid),

    .i_fifo_full(w_fifo_full)
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

/*
                      __________
                     |          |
        ready_out--->|          |<---data_in
         data_out<---|   FIFO   |<---data_in_valid
   data_out_valid<---|          |--->ready_in
                     |__________|

*/

//Escritura
wire w_ready_in;
wire [DATA_DEPTH-1:0] w_data_in;
wire w_data_in_valid;
//Lectura
reg r_fifo_ready_in;
reg [DATA_DEPTH-1:0] r_fifo_data_out;            
reg r_fifo_data_out_valid;

FIFO fifo(
    .i_clk(i_clk), 
    .i_reset(i_rst),

    .i_data_in(w_data_in),
    .i_data_in_valid(w_data_in_valid),
    .o_ready_in(w_ready_in),

    .o_data_out(r_fifo_data_out),
    .o_data_out_valid(r_fifo_data_out_valid),
    .i_ready_out(r_fifo_ready_in),

    .o_full(w_fifo_full)
);

/*

              __________
             |          |
    i_rxd--->|          |--->o_data
    o_txd<---|          |--->o_valid
             |          |<---i_ready
             |          |
             |   UART   |<---i_data
             |          |<---i_valid
             |          |--->o_ready
  o_rxerr<---|          |
             |__________|             
            
*/

reg [DIV_BITS-1:0] r_div = DIV_CLK_NUMBER;
reg [DATA_DEPTH-1:0] r_uart_recived_data;
reg [DATA_DEPTH-1:0] r_uart_send_data;

reg r_uart_recived_valid;
reg r_uart_recived_valid_prev;
reg r_uart_recived_data_ready;

reg r_uart_send_valid;
reg r_uart_send_data_ready;
reg r_flag;

wire w_rxerr;

uart uart(
    .i_clk(i_clk),
    .i_rst(i_rst),

    .i_div(r_div),

    .i_rxd(i_rx),
    .o_txd(o_tx),

    .o_data(r_uart_recived_data),            //Datos recividos
    .o_valid(r_uart_recived_valid),          //Datos recividos extraidos
    .i_ready(r_uart_recived_data_ready),     //Infromacion lista para ser extraida de nuevo

    .i_data(r_uart_send_data),               //Datos a enviar
    .i_valid(r_uart_send_valid),             //Datos a enviar tomados o no tomados
    .o_ready(r_uart_send_data_ready),        //Informacion enviada o lista para enviar

    .o_rxerr(w_rxerr)

);

assign sda = w_sda_oe ? w_sda_o : 1'bz;
assign w_sda_i = sda;

//UART and FIFO LOGIC

always @(posedge i_clk or posedge i_rst) begin
    if(i_rst) begin
        r_uart_send_data = 0;
        r_uart_recived_data_ready = 1'b0;
        r_uart_send_valid = 1'b0;
        r_fifo_ready_in = 1'b0;
        r_uart_recived_valid_prev = r_uart_recived_valid;
        r_flag = 1'b0;                      //Para que no vuelva a entrar y generar pulsos de señal indeseados
    end
    else begin

        if(r_uart_recived_valid_prev==1'b0 & r_uart_recived_valid==1'b1) begin
            r_flag = 1'b0;
        end

        if(r_uart_recived_data==SEND_SENSOR_DATA & r_uart_recived_valid & (!r_fifo_ready_in) & (!r_uart_recived_data_ready) & (!r_flag)) begin
            r_fifo_ready_in = 1'b1;
            r_flag = 1'b1;
        end
        else if(r_fifo_data_out_valid) begin
            r_uart_send_data = r_fifo_data_out;
            r_uart_send_valid = 1'b1;
            r_fifo_ready_in = 1'b0;
        end
        else if(r_uart_send_valid == 1'b1) begin
            r_uart_send_valid = 1'b0;
        end

        r_uart_recived_valid_prev = r_uart_recived_valid;

    end

end

endmodule

/*
COSAS QUE TERMINAR

Contemplar el caso de FIFO llena
*/