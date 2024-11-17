`include "../i2c_master_oe.v"

module i2c_lattice_harness #(

    parameter DATA_DEPTH = 8,
    parameter CLK_DIV = 59 //400k
    // parameter CLK_DIV = 239 //100k
    //  parameter CLK_DIV = 8388607
    // parameter CLK_DIV = 524287   //10k
    
) (

    input i_clk,
    input i_rst,
    input i_start,

    inout o_sda,
    inout o_scl,

    output o_lock,
    output o_led1,
    output o_led2,
    output o_led3, 
    output [DATA_DEPTH-1:0] o_data_bits,
    output o_data_valid

);

wire w_sda_in;
wire w_sda_out;
wire w_sda_oen;

wire w_scl_in;
wire w_scl_out;
wire w_scl_oen;

wire w_restart_loopback;
wire w_restart_istart;

wire w_pll_clk_out;
wire w_gbclk;
wire w_nrst;

reg [2-1:0] r_sda_in_dr;
reg [2-1:0] r_scl_in_dr;
reg [3-1:0] r_restart_delay;
reg [8-1:0] r_internal_addr_counter;
reg r_idata_once_flag;


reg r_idata_ready;
reg r_idata_valid;
reg r_iaddr_valid;




assign w_nrst = i_rst;
assign w_rst = ~w_nrst;
assign w_restart_istart = r_restart_delay[2];

// assign o_led3 = iicMasterInst.r_proc_cntr[0];
// assign o_led1 = w_scl_out;
// assign o_led2 = w_sda_in;


// assign o_led1 = w_restart_istart;
// assign o_led2 = w_restart_loopback;
// assign o_led3 = o_data_valid;

assign {o_led1, o_led2, o_led3} = 3'b0;


// Configuracion de nucleo PLL 
// Manufacturado manualmente
// Con clk de 12 MHz configuro para que corra a 96 MHz

SB_PLL40_CORE #(

    //Configuracion de parametros

    .FEEDBACK_PATH("SIMPLE"), // Realimentacion simple
    .DIVR(4'b0000),           // DIVR = 0
    .DIVF(7'b011_1111),       // DIVF = 63
    .DIVQ(3'b011),            // DIVQ = 3
    .FILTER_RANGE(3'b001)     // Filtro interno

) pllInst (

    .LOCK(o_lock),            // Indicador de PLL bloqueado
    .RESETB(w_nrst),            // Linea de reset (activa en bajo)
    .BYPASS(1'b0),            // Sin Bypass
    .REFERENCECLK(i_clk),  // Clock de referencia (desde cristal externo)
    .PLLOUTGLOBAL(w_pll_clk_out)  // Clock de salida (conectado a linea auxiliar)

);

// Configuracion de global clock buffer
// Para distribuir el clock del pll

SB_GB globalBufferInst (
    .USER_SIGNAL_TO_GLOBAL_BUFFER(w_pll_clk_out), // Entrada
    .GLOBAL_BUFFER_OUTPUT(w_gbclk)
);

// Configuracion de primitivas de IO para salidas Open Drain
// Ver las recomendaciones de la referencia de Lattice para
// entender porque las cosas estan asi como asi
// Para el sda hago una full-instantiation para que quede de referencia
// en el scl solo defino lo que necesito.

SB_IO #(
    .PIN_TYPE (6'b101000), //
// Salida (b5-b2) : 1010 => Salida sin registrar con enable no registrado
// Entrada (b1-b0) : 00  => Entrada registrada
    .PULLUP (1'b0), //activamos pullup
    .NEG_TRIGGER (1'b0), //Las FF de IO trabajan en Rising edge
    .IO_STANDARD ("SB_LVCMOS")
) sdaPinInst (
    .PACKAGE_PIN (o_sda), // User‟s Pin signal name
    .LATCH_INPUT_VALUE (), // Latches/holds the Input value
    .CLOCK_ENABLE (), // Clock Enable common to input and output clock
    .INPUT_CLK (w_gbclk), // Clock for the input registers
    .OUTPUT_CLK (w_gbclk), // Clock for the output registers
    .OUTPUT_ENABLE (w_sda_oen), // Output Pin Tristate/Enable control
    .D_OUT_0 (w_sda_out), // Data 0 – out to Pin/Rising clk edge
    .D_OUT_1 (), // Data 1 - out to Pin/Falling clk edge
    .D_IN_0 (w_sda_in), // Data 0 - Pin input/Rising clk edge
    .D_IN_1 ()
);

SB_IO #(

    .PIN_TYPE (6'b101000),
    .PULLUP (1'b0)

) sclPinInst (

    .PACKAGE_PIN (o_scl),
    .INPUT_CLK (w_gbclk),
    .OUTPUT_CLK (w_gbclk),
    .OUTPUT_ENABLE (w_scl_oen),
    .D_OUT_0 (w_scl_out),
    .D_IN_0 (w_scl_in)

);

//Instanciacion del master de i2c
i2c_master_oe #(DATA_DEPTH, CLK_DIV) i2cMasterInst (
    .i_clk(w_gbclk),
    .i_rst(w_rst),
    .i_start(w_restart_istart),

    .i_addr_bits(8'b10100001),
    .i_addr_valid(1'b1),
    .o_addr_ready(w_restart_loopback),

    //stream input bytes to read
    .i_nbytes_bits(8'hff),
    .i_nbytes_valid(1'b1),
    .o_nbytes_ready(),

    //stream input data interface
    .i_data_bits(r_internal_addr_counter),
    .i_data_valid(r_idata_valid),
    .o_data_ready(r_idata_ready),

    //stream output read data
    .o_data_bits(o_data_bits),
    .o_data_valid(o_data_valid),
    .i_data_ready(1'b1),

    //i2c lines
    .i_sda_in(r_sda_in_dr[1]),
    .i_scl_in(r_scl_in_dr[1]),
    .o_scl_oe(w_scl_oen),
    .o_sda_oe(w_sda_oen),
    .o_scl_out(w_scl_out),
    .o_sda_out(w_sda_out)

);

always @(posedge w_gbclk or posedge w_rst) begin
    if (w_rst == 1'b1) begin
        r_start_btn_dr <= '0;
        r_sda_in_dr <= '0;
        r_scl_in_dr <= '0;
        r_restart_delay <= '0;
        r_internal_addr_counter <= '0;
        r_idata_valid <= 1'b0;
        r_idata_once_flag <= 1'b1;


    end else begin
        r_sda_in_dr <= (r_sda_in_dr << 1);
        r_sda_in_dr[0] <= w_sda_in;
        r_scl_in_dr <= (r_scl_in_dr << 1);
        r_scl_in_dr[0] <= w_scl_in;
        r_start_btn_dr <= (r_start_btn_dr << 1);
        r_start_btn_dr[0] <= w_start_btn;
        r_restart_delay <= (r_restart_delay << 1);
        r_restart_delay[0] <= w_restart_loopback & i_start;

        if (w_restart_istart == 1'b1 && r_idata_once_flag == 1'b0) begin
            r_idata_once_flag <= 1'b1;
        end

        if (r_idata_ready == 1'b1 && r_idata_once_flag == 1'b1) begin
            r_idata_valid <= 1'b1;
            r_idata_once_flag <= 1'b0;
        end else if (r_idata_ready == 1'b0 && r_idata_valid == 1'b1) begin
            r_idata_valid <= 1'b0;
            r_internal_addr_counter <= r_internal_addr_counter + 1;
        end
    end
end


endmodule