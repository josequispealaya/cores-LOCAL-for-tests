`include "../FSM_I2C_FIFO/FSM_I2C_FIFO.v"
`include "../UART_FSM/UART_FSM.v"
`include "../uart/uart.v"
`include "../uart/uart_rx.v"
`include "../uart/uart_tx.v"
`include "../uart/uart_clkgen.v"

module FSM_I2C_FIFO_UART #(
    parameter DATA_DEPTH = 8, 
    DIV_BITS = 16, 
    DIV_CLK_NUMBER=170, 
    NBYTES = 0,                        //El i2c_master empieza a contar desde el cero (0=leer una vez)
    ADDR_SLAVE_READ = 157,
    ADDR_SLAVE_WRITE = 156,
    CONFIG_REGISTER_WRITE = 9,         //A modo de prueba se cambio el valor para que sea el mismo y se pueda comprobar
    CONFIG_REGISTER_READ = 3,          //el valor real del sensor de temperatura es 0x09 para escribir y 0x03 para leer
    CONFIG_REGISTER_DATA = 4,
    SENSOR_DATA = 0,
    SENSOR_DECIMAL_FRACTION_DATA = 15,
    ADDR_LENGTH = 8,
    COUNTER_ACK_LIMIT = 25,
    COUNTER_CONFIG_LIMIT = 25,

    //i2c master
    CLK_DIV = 65,                   // 26000000/(65*4) = 100000 Hz
    CLK_DIV_REG_BITS = 24,

    //UART_FSM
    DATA_SENSOR0 = 97,
    DATA_SENSOR1 = 98,
    DATA_SENSOR2 = 99,
    DATA_SENSOR3 = 100,
    DATA_SENSOR4 = 101,
    DATA_SENSOR5 = 102,
    DATA_SENSOR6 = 103,
    DATA_SENSOR7 = 104,
    FSM_SENSOR0 =  105,
    FSM_SENSOR1 =  106,
    FSM_SENSOR2 =  107,
    FSM_SENSOR3 =  108,
    FSM_SENSOR4 =  109,
    FSM_SENSOR5 =  110,
    FSM_SENSOR6 =  111,
    FSM_SENSOR7 =  112
)(
    input i_clk,
    input i_rst,

    input i_rx,
    output o_tx,

    output reg o_led_status,    //Para verificar que la FPGA siga funcionando
/*    output o_led_uart_err,
    output o_led_fsm_error,
    output o_led_fifo_err,
    output o_led_borar,
*/

    output [7:0] o_leds,

    inout sda,            //Para simulacion hay assign comentados mas abajo)
    inout scl
);

//--------------------------------------------------------------------------------------------
//FSM I2C y FIFO
//--------------------------------------------------------------------------------------------

/*

                                         __________
                                        |          |
           i_fifo_data_out_extracted--->|          |
                                        |          |
                                        |   I2C    |
                                        |   FSM    |<--->sda
                     o_fifo_data_out<---|   FIFO   |<--->scl
                                        |          |
                                        |          |
    o_fifo_data_out_valid_to_extract<---|          |
                                        |__________|             
            
*/

wire [7:0] w_leds;

assign o_leds = w_leds;

//-------------------
//wires and registers
//-------------------

wire aux;

wire w_fsm_rst;

wire w_fifo_data_out_extracted;
wire w_fifo_data_out_valid_to_extract;
wire [DATA_DEPTH-1:0] w_fifo_data_out;

//Input Output interface
wire w_sda_oe;
wire w_sda_o;
wire w_sda_i;

//Input output interface
wire w_scl_oe;
wire w_scl_o;
wire w_scl_i;

//--------------------------------------------------------------------------------------------
//UART_FSM
//--------------------------------------------------------------------------------------------

/*

                                         __________
                                        |          |
                 i_uart_recived_data--->|          |
                i_uart_recived_valid--->|          |
           o_uart_recived_data_ready<---|          |
                                        |   UART   |--->o_fifo0_data_out_extracted
                    o_uart_send_data<---|   FSM    |<---i_fifo0_data_out_valid_to_extract
                   o_uart_send_valid<---|          |<---i_fifo0_data_out
              i_uart_send_data_ready--->|          |
                                        |          |
                                        |__________|             
            
*/

//-------------------
//wires and registers
//-------------------

wire [DATA_DEPTH-1:0] w_uart_fsm_recived_data;
wire w_uart_recived_valid;
wire w_uart_recived_data_ready;

wire [DATA_DEPTH-1:0] w_uart_send_data;
wire w_uart_send_valid;
wire w_uart_send_data_ready;

wire [DATA_DEPTH-1:0] w_uart_recived_data;

wire w_fifo_empty;

//--------------------------------------------------------------------------------------------
//UART
//--------------------------------------------------------------------------------------------

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

//-------------------
//wires and registers
//-------------------

reg [DIV_BITS-1:0] r_div = DIV_CLK_NUMBER;

wire w_rxerr;

//--------------------------------------------------------------------------------------------
//UART and FIFO LOGIC
//--------------------------------------------------------------------------------------------

reg [31:0] r_counter = 26000050;
reg r_led_status;

FSM_I2C_FIFO #(
    .DATA_DEPTH(DATA_DEPTH),  
    .NBYTES(NBYTES),                        //El i2c_master empieza a contar desde el cero (0=leer una vez)
    .ADDR_SLAVE_READ(ADDR_SLAVE_READ),
    .ADDR_SLAVE_WRITE(ADDR_SLAVE_WRITE),
    .CONFIG_REGISTER_WRITE(CONFIG_REGISTER_WRITE),         //A modo de prueba se cambio el valor para que sea el mismo y se pueda comprobar
    .CONFIG_REGISTER_READ(CONFIG_REGISTER_READ),          //el valor real del sensor de temperatura es 0x09 para escribir y 0x03 para leer
    .CONFIG_REGISTER_DATA(CONFIG_REGISTER_DATA),
    .SENSOR_DATA(SENSOR_DATA),
    .SENSOR_DECIMAL_FRACTION_DATA(SENSOR_DECIMAL_FRACTION_DATA),
    .ADDR_LENGTH(ADDR_LENGTH),
    //i2c master
    .CLK_DIV(CLK_DIV),
    .CLK_DIV_REG_BITS(CLK_DIV_REG_BITS),
    .COUNTER_ACK_LIMIT(COUNTER_ACK_LIMIT),
    .COUNTER_CONFIG_LIMIT(COUNTER_CONFIG_LIMIT)
) FSM_I2C_FIFO (
    .i_clk(i_clk),
    .i_rst(i_rst),
    .i_fsm_rst(w_fsm_rst),

    .sda(sda),
    .scl(scl),

    .o_led_fsm_err(o_led_fsm_error),

    .i_fifo_data_out_extracted(w_fifo_data_out_extracted),
    .o_fifo_data_out_valid_to_extract(w_fifo_data_out_valid_to_extract),
    .o_fifo_data_out(w_fifo_data_out),

    .o_fifo_empty(w_fifo_empty),

    .o_borrar(o_led_borar)

);


//--------------------------------------------------------------------------------------------
//UART_FSM
//--------------------------------------------------------------------------------------------

/*

                                         __________
                                        |          |
                 i_uart_recived_data--->|          |
                i_uart_recived_valid--->|          |
           o_uart_recived_data_ready<---|          |
                                        |   UART   |--->o_fifo0_data_out_extracted
                    o_uart_send_data<---|   FSM    |<---i_fifo0_data_out_valid_to_extract
                   o_uart_send_valid<---|          |<---i_fifo0_data_out
              i_uart_send_data_ready--->|          |
                                        |          |
                                        |__________|             
            
*/

UART_FSM #(.DATA_DEPTH(DATA_DEPTH),
    .DATA_SENSOR0(DATA_SENSOR0),
    .DATA_SENSOR1(DATA_SENSOR1),
    .DATA_SENSOR2(DATA_SENSOR2),
    .DATA_SENSOR3(DATA_SENSOR3),
    .DATA_SENSOR4(DATA_SENSOR4),
    .DATA_SENSOR5(DATA_SENSOR5),
    .DATA_SENSOR6(DATA_SENSOR6),
    .DATA_SENSOR7(DATA_SENSOR7),
    .FSM_SENSOR0(FSM_SENSOR0),
    .FSM_SENSOR1(FSM_SENSOR1),
    .FSM_SENSOR2(FSM_SENSOR2),
    .FSM_SENSOR3(FSM_SENSOR3),
    .FSM_SENSOR4(FSM_SENSOR4),
    .FSM_SENSOR5(FSM_SENSOR5),
    .FSM_SENSOR6(FSM_SENSOR6),
    .FSM_SENSOR7(FSM_SENSOR7)
)
UART_FSM (
    .i_clk(i_clk),
    .i_rst(i_rst),

    .i_uart_recived_data(w_uart_fsm_recived_data),
    .i_uart_recived_valid(w_uart_recived_valid),
    .o_uart_recived_data_ready(w_uart_recived_data_ready),

    .o_uart_send_data(w_uart_send_data),
    .o_uart_send_valid(w_uart_send_valid),
    .i_uart_send_data_ready(w_uart_send_data_ready),

    .o_fifo0_data_out_extracted(w_fifo_data_out_extracted),
    .i_fifo0_data_out_valid_to_extract(w_fifo_data_out_valid_to_extract),
    .i_fifo0_data_out(w_fifo_data_out),
    .o_fsm_rst(w_fsm_rst),
    .i_fifo_empty(w_fifo_empty),
    
    .o_leds(w_leds)
);

//--------------------------------------------------------------------------------------------
//UART
//--------------------------------------------------------------------------------------------

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

uart #(.DIV_BITS(DIV_BITS)) uart(
    .i_clk(i_clk),
    .i_rst(i_rst),

    .i_div(r_div),

    .i_rxd(i_rx),
    .o_txd(o_tx),

    .o_data(w_uart_recived_data),            //Datos recividos
    .o_valid(w_uart_recived_valid),          //Datos recividos extraidos
    .i_ready(w_uart_recived_data_ready),     //Infromacion lista para ser extraida de nuevo

    .i_data(w_uart_send_data),               //Datos a enviar
    .i_valid(w_uart_send_valid),             //Datos a enviar tomados o no tomados
    .o_ready(w_uart_send_data_ready),        //Informacion enviada o lista para enviar

    .o_rxerr(o_led_uart_err)

);

assign w_uart_fsm_recived_data[0] = w_uart_recived_data[0];
assign w_uart_fsm_recived_data[1] = w_uart_recived_data[1];
assign w_uart_fsm_recived_data[2] = w_uart_recived_data[2];
assign w_uart_fsm_recived_data[3] = w_uart_recived_data[3];
assign w_uart_fsm_recived_data[4] = w_uart_recived_data[4];
assign w_uart_fsm_recived_data[5] = w_uart_recived_data[5];
assign w_uart_fsm_recived_data[6] = w_uart_recived_data[6];
assign w_uart_fsm_recived_data[7] = w_uart_recived_data[7];
/*
//--------------------------------------------------------------------------------------------
//SB_IO Instantiation
//--------------------------------------------------------------------------------------------

wire w_clock_enable;
wire w_d_out_0;
wire w_d_in_0;
wire w_d_out_1;
wire w_d_in_1;
reg r_latch_input_value = 1'b0;

wire w_package_pin_scl;
wire w_package_pin_sda;


assign w_package_pin_scl = scl;
assign w_package_pin_sda = sda;

//-------
//SDA pin
//-------

SB_IO
IO_PIN_SDA_INST
(
.PACKAGE_PIN (w_package_pin_sda),                 // User’s Pin signal name
.LATCH_INPUT_VALUE (r_latch_input_value),     // Latches/holds the Input value
.CLOCK_ENABLE (w_clock_enable),             // Clock Enable common to input and output clock
.INPUT_CLK (i_clk),                         // Clock for the input registers
.OUTPUT_CLK (i_clk),                        // Clock for the output registers
.OUTPUT_ENABLE (w_sda_oe),                  // Output Pin Tristate/Enable control
.D_OUT_0 (w_sda_o),                         // Data 0 – out to Pin/Rising clk edge
.D_OUT_1 (w_d_out_0),                         // Data 1 - out to Pin/Falling clk edge
.D_IN_0 (w_sda_i),                           // Data 0 - Pin input/Rising clk edge
.D_IN_1 (w_d_in_0)                            // Data 1 – Pin input/Falling clk edge
); // synthesis DRIVE_STRENGTH= x2

defparam IO_PIN_SDA_INST.PIN_TYPE = 6'b101001;
// See Input and Output Pin Function Tables.
// Default value of PIN_TYPE = 6’000000 i.e.
// an input pad, with the input signal
// registered.
defparam IO_PIN_SDA_INST.PULLUP = 1'b0;
// By default, the IO will have NO pull up.
// This parameter is used only on bank 0, 1,
// and 2. Ignored when it is placed at bank 3
defparam IO_PIN_SDA_INST.NEG_TRIGGER = 1'b0;
// Specify the polarity of all FFs in the IO to
// be falling edge when NEG_TRIGGER = 1.
// Default is rising edge.
defparam IO_PIN_SDA_INST.IO_STANDARD = "SB_LVCMOS";
// Other IO standards are supported in bank 3
// only: SB_SSTL2_CLASS_2, SB_SSTL2_CLASS_1,
// SB_SSTL18_FULL, SB_SSTL18_HALF, SB_MDDR10,
// SB_MDDR8, SB_MDDR4, SB_MDDR2 etc.

//-------
//SCL pin
//-------

SB_IO
IO_PIN_SCL_INST
(
.PACKAGE_PIN (w_package_pin_scl),                 // User’s Pin signal name
.LATCH_INPUT_VALUE (r_latch_input_value),     // Latches/holds the Input value
.CLOCK_ENABLE (w_clock_enable),             // Clock Enable common to input and output clock
.INPUT_CLK (i_clk),                         // Clock for the input registers
.OUTPUT_CLK (i_clk),                        // Clock for the output registers
.OUTPUT_ENABLE (w_scl_oe),                  // Output Pin Tristate/Enable control
.D_OUT_0 (w_scl_o),                         // Data 0 – out to Pin/Rising clk edge
.D_OUT_1 (w_d_out_1),                         // Data 1 - out to Pin/Falling clk edge
.D_IN_0 (w_scl_i),                           // Data 0 - Pin input/Rising clk edge
.D_IN_1 (w_d_in_1)                            // Data 1 – Pin input/Falling clk edge
); //synthesis DRIVE_STRENGTH= x2
defparam IO_PIN_SCL_INST.PIN_TYPE = 6'b101001;
// See Input and Output Pin Function Tables.
// Default value of PIN_TYPE = 6’000000 i.e.
// an input pad, with the input signal
// registered.
defparam IO_PIN_SCL_INST.PULLUP = 1'b0;
// By default, the IO will have NO pull up.
// This parameter is used only on bank 0, 1,
// and 2. Ignored when it is placed at bank 3
defparam IO_PIN_SCL_INST.NEG_TRIGGER = 1'b0;
// Specify the polarity of all FFs in the IO to
// be falling edge when NEG_TRIGGER = 1.
// Default is rising edge.
defparam IO_PIN_SCL_INST.IO_STANDARD = "SB_LVCMOS";
// Other IO standards are supported in bank 3
// only: SB_SSTL2_CLASS_2, SB_SSTL2_CLASS_1,
// SB_SSTL18_FULL, SB_SSTL18_HALF, SB_MDDR10,
// SB_MDDR8, SB_MDDR4, SB_MDDR2 etc.

//--------------------------------------------------------------------------------------------
//--------------------------------------------------------------------------------------------


*/

assign o_led_fifo_err = w_fifo_empty;


//--------------------------------------------------------------------------------------------
//UART and FIFO LOGIC
//--------------------------------------------------------------------------------------------

always @(posedge i_clk or posedge i_rst) begin
    if(i_rst) begin
        r_led_status = 1'b0;
    end
    else begin

        if(r_counter <= 50) begin
            r_led_status <= ~r_led_status;
            r_counter <= 26000050;
        end
        else begin
            r_counter <= r_counter - 1;
        end

    end

    o_led_status <= r_led_status;

end

endmodule

