/* 
** Comentarios
**
** 3 streams: data, addr, y out
** señal de start
**
**
**  Cambie la fsm a un proceso
**  para evitarme tener que registrar a manopla
**  todas las latches en los periodos de clock
**  Puede ser un paso a optimizar ya que es posible
**  Que haya señales que se latcheen y que no sean necesarias
*/

module i2c_master_oe #(

    parameter DATA_DEPTH = 8,
    parameter CLK_DIV = 16,
    parameter CLK_DIV_REG_BITS = 24

) (
    
    //control
    input i_clk,
    input i_rst,
    input i_start, 

    //stream input addr interface
    input [DATA_DEPTH-1:0] i_addr_bits,
    input i_addr_valid,
    output o_addr_ready,

    //stream input number of bytes to read
    input [DATA_DEPTH-1:0] i_nbytes_bits,
    input i_nbytes_valid,
    output o_nbytes_ready,

    //stream input data interface
    input [DATA_DEPTH-1:0] i_data_bits,
    input i_data_valid,
    output o_data_ready,

    //stream output read data
    output reg [DATA_DEPTH-1:0] o_data_bits,
    output o_data_valid,
    input i_data_ready,

    //i2c lines splitted for manual instantiation
    //of io ports

    //strict input lines
    input i_sda_in,
    input i_scl_in,
    
    //tristate buffers separate lines
    output o_sda_oe,
    output o_scl_oe,

    //strict output lines
    output o_sda_out,
    output o_scl_out,

    inout o_sda,
    inout o_scl,
    
    output o_nak

);

// LOCALPARAMS

localparam STATE_BITS = 4;

localparam  S_IDLE =        'd0,
            S_START =       'd1,
            S_SEND_ADDR =   'd2,
            S_CHECK_ACK =   'd3,
            S_WRITE_REG =   'd4,
            S_WRITE_BITS =  'd5,
            S_READ_BITS =   'd6,
            S_SEND_ADDR_R = 'd7,
            S_GEN_ACK =     'd8,
            S_GEN_NACK =    'd9,
            S_REP_START =   'd10,
            S_STOP =        'd11
;

// INTERNAL REGS

reg [STATE_BITS-1:0] r_astate;
reg [STATE_BITS-1:0] r_nstate;
reg [STATE_BITS-1:0] r_nsaftack;

reg [DATA_DEPTH-1:0] r_addr_latch;
reg [DATA_DEPTH-1:0] r_nbytes_latch;
reg [DATA_DEPTH-1:0] r_idata_latch;
reg [DATA_DEPTH-1:0] r_odata_latch;

reg [CLK_DIV_REG_BITS-1:0] r_clkdiv_cntr;
reg [CLK_DIV_REG_BITS-1:0] r_clkdiv_div;

reg [2-1:0] r_proc_cntr;
reg [4-1:0] r_bit_cntr;

reg r_addr_ready;
reg r_nbytes_ready;
reg r_idata_ready;
reg r_odata_valid;

reg r_osda;
reg r_oscl;

reg r_fsm_tick;
reg r_oe_sda;
reg r_oe_scl;

reg r_nak;

// INTERNAL WIRES

wire w_rw_flag;

// ASYNC ASSIGNMENTS

assign o_addr_ready = r_addr_ready;
assign o_data_ready = r_idata_ready;
assign o_data_valid = r_odata_valid;
assign o_nbytes_ready = r_nbytes_ready;

//assign o_sda_out = r_osda;
//assign o_scl_out = r_oscl;
//assign o_scl_oe = r_oe_scl;
//assign o_sda_oe = r_oe_sda;

assign o_sda_out = r_oe_sda;
assign o_scl_out = r_oe_scl;
assign o_scl_oe = r_oscl;
assign o_sda_oe = r_osda;

assign w_rw_flag = r_addr_latch[0];

assign o_nak = r_nak;

// FSM

always @(posedge i_clk or posedge i_rst) begin

    r_fsm_tick <= '0;
    r_oe_sda <= 1'b0;
    r_oe_scl <= 1'b0;

    if (i_rst == 1'b1) begin

        r_nstate <= S_IDLE;

        r_clkdiv_cntr <= '0;
        r_clkdiv_div <= CLK_DIV;
        
        r_proc_cntr <= '0;
        
        r_addr_ready <= 1'b1;
        r_idata_ready <= 1'b0;
        r_odata_valid <= 1'b0;
        r_nbytes_ready <= 1'b0;

        r_addr_latch <= '0;
        r_idata_latch <= '0;
        r_odata_latch <= '0;
        r_nbytes_latch <= '0;
        
        r_osda <= 1'b1;
        r_oscl <= 1'b1;

        r_nak <= 1'b0;


    end else begin

        if ((r_astate != S_CHECK_ACK && r_astate != S_READ_BITS && r_astate != S_IDLE) || r_osda != 1'b1) begin
            r_oe_sda <= 1'b1;
        end

        if (r_astate != S_IDLE && r_proc_cntr != 2'd1 && r_proc_cntr != 2'd2) begin
            r_oe_scl <= 1'b1;
        end

        r_astate <= r_nstate;
        
        r_clkdiv_cntr <= r_clkdiv_cntr + 1'b1;
        if (r_clkdiv_cntr >= r_clkdiv_div) begin
            r_clkdiv_cntr <= '0;
            r_fsm_tick <= 1'b1;
        end

        //State Machine Logic

        case (r_astate)

            S_IDLE: begin
                r_addr_ready <= 1'b1;
                r_idata_ready <= 1'b0;
                r_nak <= 1'b0;
                r_odata_valid <= 1'b0;              //Agregado

                if (i_start == 1'b1 && i_addr_valid == 1'b1) begin
                    r_addr_latch = i_addr_bits;
                    r_addr_ready <= 1'b0;
                    r_nstate <= S_START;
                end
            end

            S_START: begin


                if (r_fsm_tick == 1'b1) begin
                    
                    case (r_proc_cntr) 
                        
                        2'd0: begin
                            r_proc_cntr <= 2'd1;
                        end

                        2'd1: begin
                            r_osda <= 1'b0;
                            r_proc_cntr <= 2'd2;
                        end

                        2'd2: begin
                            r_proc_cntr <= 2'd3;
                        end

                        2'd3: begin
                            r_oscl <= 1'b0;
                            r_proc_cntr <= 2'd0;
                            r_bit_cntr <= 3'd7;
                            r_nstate <= S_SEND_ADDR;
                        end

                    endcase

                end

            end

            S_SEND_ADDR: begin

                if (r_fsm_tick == 1'b1) begin

                    case (r_proc_cntr) 
                        
                        2'd0: begin
                            r_osda <= (r_bit_cntr == 3'b0) ? 1'b0 : r_addr_latch[r_bit_cntr]; //always write
                            r_proc_cntr <= 2'd1;
                        end

                        2'd1: begin
                            r_oscl <= 1'b1;
                            r_proc_cntr <= 2'd2;
                        end

                        2'd2: begin
                            //clk stretch
                            if (i_scl_in == 1'b1) begin
                                r_proc_cntr <= 2'd3;
                            end
                        end

                        2'd3: begin
                            r_oscl <= 1'b0;
                            if (r_bit_cntr == 3'b0) begin
                                r_bit_cntr <= 3'd7;
                                r_idata_ready <= 1'b1;
                                r_nstate <= S_CHECK_ACK;
                                r_nsaftack <= S_WRITE_REG;
                            end else begin
                                r_bit_cntr <= r_bit_cntr - 1;
                                r_nstate <= S_SEND_ADDR;
                            end
                            r_proc_cntr <= 2'd0;
                        end
                    endcase
                end
            end

            S_CHECK_ACK: begin

                if (i_data_valid == 1'b1 && r_idata_ready == 1'b1) begin
                    r_idata_ready <= 1'b0;
                    r_idata_latch <= i_data_bits;
                end

                if (r_fsm_tick == 1'b1) begin
                    
                    case (r_proc_cntr) 
                        
                        2'd0: begin
                            r_proc_cntr <= 2'd1;
                            r_osda <= 1'b1;
                        end

                        2'd1: begin
                            r_oscl <= 1'b1;
                            r_proc_cntr <= 2'd2;
                        end

                        2'd2: begin
                            if (i_scl_in == 1'b1) begin
                                if (/*i_sda_in*/o_sda_oe == 1'b1) begin
                                    //NAK
                                    r_nstate <= S_STOP;
                                    r_nak <= 1'b1;
                                end else begin
                                    r_proc_cntr <= 2'd3;
                                end
                            end
                        end

                        2'd3: begin
                            r_oscl <= 1'b0;
                            r_proc_cntr <= 2'd0;

                            case (r_nsaftack)
                                
                                S_REP_START: begin
                                    r_nstate <= (r_idata_ready == 1'b1) ? S_REP_START : S_WRITE_REG;
                                    r_osda <= 1'b0;    
                                end

                                S_WRITE_BITS: begin
                                    r_nstate <= (r_idata_ready == 1'b1) ? S_STOP : S_WRITE_BITS;
                                end

                                S_WRITE_REG: begin
                                    r_nstate <= (r_idata_ready == 1'b1) ? S_STOP : S_WRITE_REG;
                                end

                                default: begin
                                    r_nstate <= r_nsaftack;
                                end

                            endcase

                            r_nsaftack <= S_IDLE;
                        end

                    endcase

                end
            end

            S_WRITE_REG: begin

                if (r_fsm_tick == 1'b1) begin
                    
                    case (r_proc_cntr) 
                        
                        2'd0: begin
                            r_osda <= r_idata_latch[r_bit_cntr];
                            r_proc_cntr <= 2'd1;
                        end

                        2'd1: begin
                            r_oscl <= 1'b1;
                            r_proc_cntr <= 2'd2;
                        end

                        2'd2: begin
                            if (i_scl_in == 1'b1) begin
                                r_proc_cntr <= 2'd3;
                            end
                        end

                        2'd3: begin
                            r_oscl <= 1'b0;
                            if (r_bit_cntr == 3'b0) begin
                                r_bit_cntr <= 3'd7;
                                r_nstate <= S_CHECK_ACK;
                                if (w_rw_flag) begin
                                    r_nsaftack <= S_REP_START;
                                    r_nbytes_latch <= '0;
                                    r_nbytes_ready <= 1'b1;
                                end else begin
                                    r_nsaftack <= S_WRITE_BITS;
                                end
                                r_idata_ready <= 1'b1;
                            end else begin
                                r_bit_cntr <=r_bit_cntr - 1;
                                r_nstate <= S_WRITE_REG;
                            end
                            r_proc_cntr <= 2'd0;
                        end

                    endcase

                end

            end

            S_WRITE_BITS: begin
                if (r_fsm_tick == 1'b1) begin
                    
                    case (r_proc_cntr) 
                        
                        2'd0: begin
                            r_osda <= r_idata_latch[r_bit_cntr];
                            r_proc_cntr <= 2'd1;
                        end

                        2'd1: begin
                            r_oscl <= 1'b1;
                            r_proc_cntr <= 2'd2;
                        end

                        2'd2: begin
                            if (i_scl_in == 1'b1) begin
                                r_proc_cntr <= 2'd3;
                            end
                        end

                        2'd3: begin
                            r_oscl <= 1'b0;
                            if (r_bit_cntr == 3'b0) begin
                                r_bit_cntr <= 3'd7;
                                r_nstate <= S_CHECK_ACK;
                                r_nsaftack <= S_WRITE_BITS;
                                r_idata_ready <= 1'b1;
                            end else begin
                                r_bit_cntr <=r_bit_cntr - 1;
                                r_nstate <= S_WRITE_BITS;
                            end
                            r_proc_cntr <= 2'd0;
                        end

                    endcase

                end

            end

            S_SEND_ADDR_R: begin

                if (r_fsm_tick == 1'b1) begin

                    case (r_proc_cntr) 
                        
                        2'd0: begin
                            r_osda <= r_addr_latch[r_bit_cntr];
                            r_proc_cntr <= 2'd1;
                        end

                        2'd1: begin
                            r_oscl <= 1'b1;
                            r_proc_cntr <= 2'd2;
                        end

                        2'd2: begin
                            //clk stretch
                            if (i_scl_in == 1'b1) begin
                                r_proc_cntr <= 2'd3;
                            end
                        end

                        2'd3: begin
                            r_oscl <= 1'b0;
                            if (r_bit_cntr == 3'b0) begin
                                r_bit_cntr <= 3'd7;
                                r_odata_latch <= '0;
                                r_nstate <= S_CHECK_ACK;
                                r_nsaftack <= S_READ_BITS;
                            end else begin
                                r_bit_cntr <= r_bit_cntr - 1;
                                r_nstate <= S_SEND_ADDR_R;
                            end
                            r_proc_cntr <= 2'd0;
                        end
                    endcase
                end
            
            end

            S_READ_BITS: begin

                if (r_fsm_tick == 1'b1) begin

                    case (r_proc_cntr) 
                        
                        2'd0: begin
                            r_odata_valid <= 1'b0;
                            r_osda <= 1'b1;
                            r_proc_cntr <= 2'd1;
                        end

                        2'd1: begin
                            r_oscl <= 1'b1;
                            r_proc_cntr <= 2'd2;
                        end

                        2'd2: begin
                            //clk stretch
                            if (i_scl_in == 1'b1) begin
                                r_odata_latch[r_bit_cntr] <= /*i_sda_in*/o_sda_oe;
                                r_proc_cntr <= 2'd3;
                            end
                        end

                        2'd3: begin
                            r_oscl <= 1'b0;
                            if (r_bit_cntr == 3'b0) begin
                                o_data_bits <= r_odata_latch;
                                r_odata_valid <= 1'b1;
                                r_bit_cntr <= 3'd7;
                                if (r_nbytes_latch != '0) begin
                                    r_nbytes_latch <= r_nbytes_latch - 1;
                                    r_nstate <= S_GEN_ACK;
                                end else begin
                                    r_nstate <= S_GEN_NACK;
                                end
                            end else begin
                                r_bit_cntr <= r_bit_cntr - 1;
                                r_nstate <= S_READ_BITS;
                            end
                            r_proc_cntr <= 2'd0;
                        end
                    endcase
                end

            end

            S_GEN_NACK: begin
                if (r_fsm_tick == 1'b1) begin
            
                    case (r_proc_cntr) 
                        
                        2'd0: begin
                            r_proc_cntr <= 2'd1;
                            r_osda <= 1'b1;
                        end

                        2'd1: begin
                            r_proc_cntr <= 2'd2;
                            r_oscl <= 1'b1;
                        end

                        2'd2: begin
                            if (i_scl_in == 1'b1) begin
                                r_proc_cntr <= 2'd3;
                            end
                        end

                        2'd3: begin
                            r_oscl <= 1'b0;
                            r_proc_cntr <= 2'd0;
                            r_nstate <= S_STOP;
                        end

                    endcase

                end 
            end

            S_GEN_ACK: begin
                if (r_fsm_tick == 1'b1) begin
            
                    case (r_proc_cntr) 
                        
                        2'd0: begin
                            r_proc_cntr <= 2'd1;
                            r_osda <= 1'b0;
                        end

                        2'd1: begin
                            r_proc_cntr <= 2'd2;
                            r_oscl <= 1'b1;
                        end

                        2'd2: begin
                            if (i_scl_in == 1'b1) begin
                                r_proc_cntr <= 2'd3;
                            end
                        end

                        2'd3: begin
                            r_oscl <= 1'b0;
                            r_proc_cntr <= 2'd0;
                            r_nstate <= S_READ_BITS;
                            r_odata_latch <= '0;
                            
                        end

                    endcase


                end 

            end

            S_REP_START: begin

                if (i_nbytes_valid == 1'b1 && r_nbytes_ready == 1'b1) begin
                    r_nbytes_latch <= i_nbytes_bits;
                    r_nbytes_ready <= 1'b0;
                end

                if (r_fsm_tick == 1'b1) begin
            
                    case (r_proc_cntr) 
                        
                        2'd0: begin
                            r_proc_cntr <= 2'd1;
                            r_osda <= 1'b1;
                        end

                        2'd1: begin
                            r_proc_cntr <= 2'd2;
                            r_oscl <= 1'b1;
                        end

                        2'd2: begin
                            r_proc_cntr <= 2'd3;
                            r_osda <= 1'b0;
                        end

                        2'd3: begin
                            r_oscl <= 1'b0;
                            r_proc_cntr <= 2'd0;
                            r_nstate <= (r_nbytes_ready == 1'b0) ? S_SEND_ADDR_R : S_IDLE;
                        end

                    endcase

                end 
            end

            S_STOP: begin
                if (r_fsm_tick == 1'b1) begin
            
                    case (r_proc_cntr) 
                        
                        2'd0: begin
                            r_proc_cntr <= 2'd1;
                            r_osda <= 1'b0;
                        end

                        2'd1: begin
                            r_proc_cntr <= 2'd2;
                            r_oscl <= 1'b1;
                        end

                        2'd2: begin
                            r_proc_cntr <= 2'd3;
                        end

                        2'd3: begin
                            r_osda <= 1'b1;
                            r_proc_cntr <= 2'd0;
                            r_nstate <= S_IDLE;
                        end

                    endcase

                end
            end

            default: begin
                r_nstate <= S_IDLE;
            end

        endcase

    end
    
end

endmodule