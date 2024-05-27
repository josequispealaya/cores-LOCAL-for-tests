module FSM #(
     parameter DATA_DEPTH = 8,
     parameter ADDR_VALUE_READ = 78,
     parameter CONFIG_REGISTER_WRITE = 9,
     parameter CONFIG_REGISTER_READ = 3,
     parameter CONFIG_REGISTER_DATA = 4
)(
     input i_clk, 
     input i_ack, 
     input i_conf, 
     input i_rst,

     //control
     output reg o_start, 
     
     //addr interface
     input i_addr_ready,
     output reg [DATA_DEPTH-1:0] o_addr_bits, 
     output reg o_addr_valid,

     //read parameters
     input i_nbytes_ready,
     output reg [DATA_DEPTH-1:0] o_nbytes_bits,
     output reg o_nbytes_valid,

     //read interface
     input [DATA_DEPTH-1:0] i_data_read_bits,
     input i_data_read_valid,
     output reg o_data_read_ready,

     //write interface
     input i_data_write_ready,                         
     output reg [DATA_DEPTH-1:0] o_data_write_bits,
     output reg o_data_write_valid

);

//Registro para los estados
reg [2:0] r_state;

//Contadores
reg [3:0] r_counterAck;
reg [3:0] r_counterConfig;
reg [2:0] r_i2c_load_data_contr;

//Estados
parameter ADDR=0, CONFIGUWRITE=1, CONFIGREAD=2, READING=3, NORESPOND=4;

//Parametros locales
parameter LOAD_ADDR=0, LOAD_NBYTES=1, ANALYSE_DATA=2, LOAD_REG=3, LOAD_DATA=4, CHANGE_VALID=5;
parameter NONE=0;

always @(r_state)
     begin
          case (r_state)
               ADDR:
                    case (r_i2c_load_data_contr)
                         LOAD_ADDR:
                              o_addr_bits = ADDR;
                              o_addr_valid = 1;
                              o_start = 1;
                         LOAD_NBYTES:
                              o_start = 0;                       //Para generar un pulso del start ya que a este estado ingreso luego de LOAD_ADDR
                              o_nbytes_bits = DATA_DEPTH;
                              o_nbytes_valid = 1;
                         ANALYSE_DATA:
                              o_addr_bits = NONE;
                              o_addr_valid = 0;
                              o_nbytes_bits = NONE;
                              o_nbytes_valid = 0;

                    endcase
               CONFIGUWRITE:
                    case (r_i2c_load_data_contr)
                         LOAD_ADDR:
                              o_addr_bits = ADDR;
                              o_addr_valid = 1;
                              o_start = 1;
                         LOAD_REG:
                              o_start = 0;                       //Para generar un pulso del start ya que a este estado ingreso luego de LOAD_ADDR
                              o_data_bits = CONFIG_REGISTER_WRITE; 
                              o_data_valid = 1;
                         CHANGE_VALID:
                              o_data_valid = 0;
                         LOAD_DATA:
                              o_data_bits = CONFIG_REGISTER_DATA;
                              o_data_valid = 1;

                    endcase
               CONFIGREAD:
                    case (r_i2c_load_data_contr)
                         LOAD_ADDR:
                              o_addr_bits = ADDR;
                              o_addr_valid = 1;
                              o_start = 1;
                         LOAD_REG:
                              o_start = 0;                       //Para generar un pulso del start ya que a este estado ingreso luego de LOAD_ADDR
                              o_data_bits = CONFIG_REGISTER_WRITE; 
                              o_data_valid = 1;
                         LOAD_NBYTES:
                              o_nbytes_bits = DATA_DEPTH;
                              o_nbytes_valid = 1;
                         ANALYSE_DATA:
                              o_addr_bits = NONE;
                              o_addr_valid = 0;
                              o_data_bits = NONE; 
                              o_data_valid = 0;
                              o_nbytes_bits = NONE;
                              o_nbytes_valid = 0;
                    endcase
               READING:
                    case (r_i2c_load_data_contr)
                         LOAD_ADDR:
                              o_addr_bits = ADDR;
                              o_addr_valid = 1;
                              o_start = 1;
                         LOAD_REG:
                              o_start = 0;                       //Para generar un pulso del start ya que a este estado ingreso luego de LOAD_ADDR
                              o_data_bits = CONFIG_REGISTER_WRITE; 
                              o_data_valid = 1;
                         LOAD_NBYTES:
                              o_nbytes_bits = DATA_DEPTH;
                              o_nbytes_valid = 1;
                         ANALYSE_DATA:
                              o_addr_bits = NONE;
                              o_addr_valid = 0;
                              o_data_bits = NONE; 
                              o_data_valid = 0;
                              o_nbytes_bits = NONE;
                              o_nbytes_valid = 0;
                    endcase
               NORESPOND:
                    o_start = 0;
                    o_addr_bits = NONE;
                    o_addr_valid = 0;
                    o_nbytes_bits = NONE;
                    o_nbytes_valid = 0;
                    o_data_read_ready = 0;
                    o_data_write_bits = NONE;
                    o_data_write_valid = 0;
               default:
                    o_start = 0;
                    o_addr_bits = NONE;
                    o_addr_valid = 0;
                    o_nbytes_bits = NONE;
                    o_nbytes_valid = 0;
                    o_data_read_ready = 0;
                    o_data_write_bits = NONE;
                    o_data_write_valid = 0;
          endcase
     end

always @(posedge i_clk or posedge i_rst)
     begin
          if (i_rst) begin
               r_state = ADDR;
               r_counterAck = 0;
               r_counterConfig = 0;
               r_i2c_load_data_contr = LOAD_ADDR;
          end
          else begin
               case (r_state)
                    ADDR: begin
                         
                         if(i_addr_ready) begin
                              r_i2c_load_data_contr = LOAD_ADDR;
                         end
                         else if(r_i2c_load_data_contr==LOAD_ADDR & i_nbytes_ready) begin
                              r_i2c_load_data_contr = LOAD_NBYTES;
                         end
                         else if(r_i2c_load_data_contr==LOAD_NBYTES) begin
                              r_i2c_load_data_contr = ANALYSE_DATA;
                         end

                         if(/*hubo NACK*/ & (r_i2c_load_data_contr==ANALYSE_DATA) & i_addr_ready) begin           
                              r_state = ADDR;
                              r_counterAck = r_counterAck + 1;
                         end
                         else if(/*hubo ACK*/ & (r_i2c_load_data_contr==ANALYSE_DATA) & i_addr_ready) begin  
                              r_state = CONFIGUWRITE;
                              r_counterAck = 0;
                         end

                         if(r_counterAck >= 10) begin
                              r_state = NORESPOND;
                         end
                         
                    end

                    CONFIGUWRITE: begin

                         if(i_addr_ready) begin
                              r_i2c_load_data_contr = LOAD_ADDR;
                         end
                         else if(r_i2c_load_data_contr==LOAD_ADDR & i_data_write_ready) begin
                              r_i2c_load_data_contr = LOAD_REG;
                         end
                         else if(r_i2c_load_data_contr==LOAD_REG) begin
                              r_i2c_load_data_contr = CHANGE_VALID;
                         end
                         else if(r_i2c_load_data_contr==CHANGE_VALID & i_data_write_ready) begin
                              r_i2c_load_data_contr = LOAD_DATA;
                         end

                         if(/*hubo NACK*/ & (r_i2c_load_data_contr==LOAD_DATA) & i_addr_ready) begin           
                              r_state = CONFIGUWRITE;
                              r_counterAck = r_counterAck + 1;
                         end
                         else if(/*hubo ACK*/ & (r_i2c_load_data_contr==LOAD_DATA) & i_addr_ready) begin  
                              r_state = CONFIGREAD;
                              r_counterAck = 0;
                         end

                         if(r_counterAck >= 10) begin
                              r_state = NORESPOND;
                         end

                         if(r_counterConfig >= 10) begin
                              r_state = NORESPOND;
                         end
                    end

                    CONFIGREAD: begin

                         if(i_addr_ready) begin
                              r_i2c_load_data_contr = LOAD_ADDR;
                         end
                         else if(r_i2c_load_data_contr==LOAD_ADDR & i_data_write_ready) begin
                              r_i2c_load_data_contr = LOAD_REG;
                         end
                         else if(r_i2c_load_data_contr==LOAD_REG & i_nbytes_ready) begin
                              r_i2c_load_data_contr = LOAD_NBYTES;
                         end
                         else if(r_i2c_load_data_contr==LOAD_NBYTES) begin
                              r_i2c_load_data_contr = ANALYSE_DATA;
                         end

                         if(/*hubo NACK*/ & (r_i2c_load_data_contr==ANALYSE_DATA) & i_addr_ready) begin           
                              r_state = CONFIGREAD;
                              r_counterAck = r_counterAck + 1;
                         end
                         else if(/*hubo ACK*/ & (r_i2c_load_data_contr==ANALYSE_DATA) & i_addr_ready) begin  
                              if(r_data_read == CONFIG_REGISTER_DATA) begin
                                   r_state = READING;
                                   r_counterAck = 0;
                                   r_counterConfig = 0;
                              end
                              else begin
                                   r_counterConfig = r_counterConfig + 1;
                                   r_state = CONFIGUWRITE;
                              end
                         end

                         if(r_counterAck >= 10) begin
                              r_state = NORESPOND;
                         end

                         if(r_counterConfig >= 10) begin
                              r_state = NORESPOND;
                         end
                         
                    end

                    READING: begin

                         if(i_addr_ready) begin
                              r_i2c_load_data_contr = LOAD_ADDR;
                         end
                         else if(r_i2c_load_data_contr==LOAD_ADDR & i_data_write_ready) begin
                              r_i2c_load_data_contr = LOAD_REG;
                         end
                         else if(r_i2c_load_data_contr==LOAD_REG & i_nbytes_ready) begin
                              r_i2c_load_data_contr = LOAD_NBYTES;
                         end
                         else if(r_i2c_load_data_contr==LOAD_NBYTES) begin
                              r_i2c_load_data_contr = ANALYSE_DATA;
                         end

                         if(/*hubo NACK*/ & (r_i2c_load_data_contr==ANALYSE_DATA) & i_addr_ready) begin           
                              r_state = READING;
                              r_counterAck = r_counterAck + 1;
                         end
                         else if(/*hubo ACK*/ & (r_i2c_load_data_contr==ANALYSE_DATA) & i_addr_ready) begin  
                              r_state = READING;
                              r_counterAck = 0;
                              r_counterConfig = 0;
                         end

                         if(r_counterAck >= 10) begin
                              r_state = NORESPOND;
                         end
                    end
                    NORESPOND: begin
                         r_state = NORESPOND;
                    end
               endcase
          end
     end

endmodule