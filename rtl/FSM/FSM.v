module FSM #(
     parameter DATA_DEPTH = 8,
     parameter NBYTES = 0,                        //El i2c_master empieza a contar desde el cero (0=leer una vez)
     parameter ADDR_SLAVE_READ = 79,
     parameter ADDR_SLAVE_WRITE = 78,
     parameter CONFIG_REGISTER_WRITE = 3,         //A modo de prueba se cambio el valor para que sea el mismo y se pueda comprobar
     parameter CONFIG_REGISTER_READ = 3,          //el valor real del sensor de temperatura es 0x09 para escribir y 0x03 para leer
     parameter CONFIG_REGISTER_DATA = 4,
     parameter SENSOR_DATA = 0,
     parameter SENSOR_DECIMAL_FRACTION_DATA = 15
)(
     input i_clk, 
     input i_rst,

     input i_force_rst,

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
     output reg o_data_write_valid,

     input i_nak,

     //FIFO

     input i_ready_in,
     output reg [DATA_DEPTH-1:0] o_data_in,
     output reg o_data_in_valid,

     input i_fifo_full,
     output reg o_err
);

//Registro para los estados
reg [2:0] r_state;

//Contadores
reg [3:0] r_counterAck;
reg [3:0] r_counterConfig;
reg [2:0] r_i2c_load_data_contr;

//Otros registros
reg r_prev_nak;
reg [2:0] r_prev_contr;
reg r_get_decimal_fraction;

//Estados
parameter ADDR=0, CONFIGUWRITE=1, CONFIGREAD=2, READING=3, NORESPOND=4, RESET=5;

//Parametros locales
//parameter LOAD_ADDR=0, LOAD_NBYTES=1, ANALYSE_DATA=2, LOAD_REG=3, LOAD_DATA=4, CHANGE_VALID=5;

localparam  LOAD_ADDR =      'd0,
            LOAD_NBYTES =    'd1,
            ANALYSE_DATA =   'd2,
            LOAD_REG =       'd3,
            LOAD_DATA =      'd4,
            CHANGE_VALID =   'd5,
            SAVE_DATA =      'd6,
            IDLE =           'd7
;

parameter NONE=0;

//Logica de las salidas

always @(r_state or r_i2c_load_data_contr)
     begin
          case (r_state)
               ADDR: begin
                    case (r_i2c_load_data_contr) 
                         LOAD_ADDR: begin
                              o_addr_bits = ADDR_SLAVE_READ;
                              o_addr_valid = 1;
                              o_start = 1;
                         end
                         LOAD_REG: begin
                              o_start = 0;                       //Para generar un pulso del start ya que a este estado ingreso luego de LOAD_ADDR
                              o_data_write_bits = SENSOR_DATA; 
                              o_data_write_valid = 1;
                         end
                         CHANGE_VALID: begin
                              o_data_write_valid = 0;
                              o_addr_valid = 0;
                         end
                         LOAD_NBYTES: begin
                              o_nbytes_bits = NBYTES;
                              o_addr_bits = ADDR_SLAVE_READ;
                              o_addr_valid = 1;
                              o_nbytes_valid = 1;
                         end
                         ANALYSE_DATA: begin
                              o_addr_bits = NONE;
                              o_addr_valid = 0;
                              o_nbytes_bits = NONE;
                              o_nbytes_valid = 0;
                              o_data_write_bits = NONE; 
                              o_data_write_valid = 0;
                         end
                         IDLE: begin
                              o_addr_bits = NONE;
                              o_addr_valid = 0;
                              o_nbytes_bits = NONE;
                              o_nbytes_valid = 0;
                              o_data_write_bits = NONE; 
                              o_data_write_valid = 0;
                         end

                    endcase
               end
               CONFIGUWRITE: begin
                    case (r_i2c_load_data_contr)
                         LOAD_ADDR: begin
                              o_addr_bits = ADDR_SLAVE_WRITE;
                              o_addr_valid = 1;
                              o_start = 1;
                         end
                         LOAD_REG: begin
                              o_start = 0;                       //Para generar un pulso del start ya que a este estado ingreso luego de LOAD_ADDR
                              o_data_write_bits = CONFIG_REGISTER_WRITE; 
                              o_data_write_valid = 1;
                         end
                         CHANGE_VALID: begin
                              o_data_write_valid = 0;
                              o_addr_valid = 0;
                         end
                         LOAD_DATA: begin
                              o_data_write_bits = CONFIG_REGISTER_DATA; 
                              o_data_write_valid = 1;
                              o_addr_bits = ADDR_SLAVE_WRITE;
                              o_addr_valid = 1;
                         end
                         ANALYSE_DATA: begin
                              o_addr_bits = NONE;
                              o_addr_valid = 0;
                              o_data_write_bits = NONE; 
                              o_data_write_valid = 0;
                         end
                         IDLE: begin
                              o_addr_bits = NONE;
                              o_addr_valid = 0;
                              o_data_write_bits = NONE; 
                              o_data_write_valid = 0;
                         end

                    endcase
               end
               CONFIGREAD: begin
                    case (r_i2c_load_data_contr)
                         LOAD_ADDR: begin
                              o_addr_bits = ADDR_SLAVE_READ;
                              o_addr_valid = 1;
                              o_start = 1;
                         end
                         LOAD_REG: begin
                              o_start = 0;                       //Para generar un pulso del start ya que a este estado ingreso luego de LOAD_ADDR
                              o_data_write_bits = CONFIG_REGISTER_READ; 
                              o_data_write_valid = 1;
                         end
                         CHANGE_VALID: begin
                              o_data_write_valid = 0;
                              o_addr_valid = 0;
                         end
                         LOAD_NBYTES: begin
                              o_nbytes_bits = NBYTES;
                              o_addr_bits = ADDR_SLAVE_READ;
                              o_addr_valid = 1;
                              o_nbytes_valid = 1;
                         end
                         ANALYSE_DATA: begin
                              o_addr_bits = NONE;
                              o_addr_valid = 0;
                              o_nbytes_bits = NONE;
                              o_nbytes_valid = 0;
                              o_data_write_bits = NONE; 
                              o_data_write_valid = 0;
                         end
                         IDLE: begin
                              o_addr_bits = NONE;
                              o_addr_valid = 0;
                              o_nbytes_bits = NONE;
                              o_nbytes_valid = 0;
                              o_data_write_bits = NONE; 
                              o_data_write_valid = 0;
                         end
                    endcase
               end
               READING: begin
                    case (r_i2c_load_data_contr)
                         LOAD_ADDR: begin
                              o_addr_bits = ADDR_SLAVE_READ;
                              o_addr_valid = 1;
                              o_start = 1;
                         end
                         LOAD_REG: begin
                              o_start = 0;                       //Para generar un pulso del start ya que a este estado ingreso luego de LOAD_ADDR
                              if(!r_get_decimal_fraction) begin
                                   o_data_write_bits = SENSOR_DATA;
                              end
                              else begin
                                   o_data_write_bits = SENSOR_DECIMAL_FRACTION_DATA;
                              end
                              o_data_write_valid = 1;
                         end
                         CHANGE_VALID: begin
                              o_data_write_valid = 0;
                              o_addr_valid = 0;
                         end
                         LOAD_NBYTES: begin
                              o_nbytes_bits = NBYTES;
                              o_addr_bits = ADDR_SLAVE_READ;
                              o_addr_valid = 1;
                              o_nbytes_valid = 1;
                         end
                         ANALYSE_DATA: begin
                              o_addr_bits = NONE;
                              o_addr_valid = 0;
                              o_nbytes_bits = NONE;
                              o_nbytes_valid = 0;
                              o_data_write_bits = NONE; 
                              o_data_write_valid = 0;
                              if(i_fifo_full) begin
                                   o_data_in_valid = 0;          //*****
                              end
                              else begin
                                   o_data_in_valid = 1;          //*****
                              end
                              
                         end
                         SAVE_DATA: begin
                              o_data_in = i_data_read_bits; //*****
                         end
                         IDLE: begin
                              o_addr_bits = NONE;
                              o_addr_valid = 0;
                              o_nbytes_bits = NONE;
                              o_nbytes_valid = 0;
                              o_data_write_bits = NONE; 
                              o_data_write_valid = 0;
                              o_data_in = NONE;
                              o_data_in_valid = 0;
                         end
                    endcase
               end
               NORESPOND: begin
                    o_start = 0;
                    o_addr_bits = NONE;
                    o_addr_valid = 0;
                    o_nbytes_bits = NONE;
                    o_nbytes_valid = 0;
                    o_data_read_ready = 0;
                    o_data_write_bits = NONE;
                    o_data_write_valid = 0;
                    o_err = 1;
               end
               RESET: begin
                    o_start = 0;
                    o_addr_bits = NONE;
                    o_addr_valid = 0;
                    o_nbytes_bits = NONE;
                    o_nbytes_valid = 0;
                    o_data_read_ready = 0;
                    o_data_write_bits = NONE;
                    o_data_write_valid = 0;
                    o_data_in = NONE;
                    o_data_in_valid = 0;
                    o_err = 0;
               end
               default: begin
                    o_start = 0;
                    o_addr_bits = NONE;
                    o_addr_valid = 0;
                    o_nbytes_bits = NONE;
                    o_nbytes_valid = 0;
                    o_data_read_ready = 0;
                    o_data_write_bits = NONE;
                    o_data_write_valid = 0;
                    o_data_in = NONE;
                    o_data_in_valid = 0;
               end
          endcase
     end

//Logica de la maquina de estados

always @(posedge i_clk or posedge i_rst)
     begin
          if (i_rst) begin
               r_state = RESET;
               r_counterAck = 0;
               r_counterConfig = 0;
               r_i2c_load_data_contr = IDLE;
               r_prev_nak = 0;
               r_prev_contr = IDLE;
               r_get_decimal_fraction = 1'b0;
          end
          else if (i_force_rst) begin
               r_state = RESET;
               r_counterAck = 0;
               r_counterConfig = 0;
               r_i2c_load_data_contr = IDLE;
               r_prev_nak = 0;
               r_prev_contr = IDLE;
               r_get_decimal_fraction = 1'b0;
          end
          else begin
               case (r_state)
                    ADDR: begin
                         
                         if(i_addr_ready & (r_i2c_load_data_contr==IDLE)) begin
                              r_i2c_load_data_contr = LOAD_ADDR;
                         end
                         else if(r_i2c_load_data_contr==LOAD_ADDR & i_data_write_ready) begin
                              r_i2c_load_data_contr = LOAD_REG;
                         end
                         else if(r_i2c_load_data_contr==LOAD_REG) begin
                              r_i2c_load_data_contr = CHANGE_VALID;
                         end
                         else if(r_i2c_load_data_contr==CHANGE_VALID & i_nbytes_ready) begin
                              r_i2c_load_data_contr = LOAD_NBYTES;
                         end
                         else if(r_i2c_load_data_contr==LOAD_NBYTES & i_data_read_valid) begin
                              r_i2c_load_data_contr = ANALYSE_DATA;
                         end

                         if(!i_nak & (r_i2c_load_data_contr==ANALYSE_DATA) & i_addr_ready) begin  
                              r_state = CONFIGUWRITE;
                              r_counterAck = 0;
                              r_i2c_load_data_contr = IDLE;
                         end
                         
                         if(i_nak & !r_prev_nak) begin
                              r_state = ADDR;
                              r_counterAck = r_counterAck + 1;
                              r_i2c_load_data_contr = IDLE;
                              r_prev_nak = i_nak; 
                         end
                         else if(!i_nak) begin
                              r_prev_nak = i_nak;
                         end

                         if(r_counterAck >= 10 & i_addr_ready) begin
                              r_state = NORESPOND;
                         end
                         
                    end

                    CONFIGUWRITE: begin

                         if(i_addr_ready & (r_i2c_load_data_contr==IDLE)) begin
                              r_i2c_load_data_contr = LOAD_ADDR;
                         end
                         else if(r_i2c_load_data_contr==LOAD_ADDR & i_data_write_ready) begin
                              r_i2c_load_data_contr = LOAD_REG;
                              r_prev_contr = LOAD_ADDR;
                         end
                         else if((r_i2c_load_data_contr==LOAD_REG) || (r_i2c_load_data_contr==LOAD_DATA)) begin
                              r_i2c_load_data_contr = CHANGE_VALID;
                              if(r_prev_contr!=CHANGE_VALID) r_prev_contr = LOAD_REG;
                         end
                         else if(r_i2c_load_data_contr==CHANGE_VALID & i_data_write_ready & r_prev_contr==LOAD_REG) begin
                              r_i2c_load_data_contr = LOAD_DATA;
                              r_prev_contr = CHANGE_VALID;
                         end
                         else if(r_i2c_load_data_contr==CHANGE_VALID && r_prev_contr==CHANGE_VALID) begin
                              r_i2c_load_data_contr = ANALYSE_DATA;
                         end

                         if(!i_nak & (r_i2c_load_data_contr==ANALYSE_DATA) & i_addr_ready) begin  
                              r_state = CONFIGREAD;
                              r_counterAck = 0;
                              r_i2c_load_data_contr = IDLE;
                         end
                         
                         if(i_nak & !r_prev_nak) begin
                              r_state = CONFIGUWRITE;
                              r_counterAck = r_counterAck + 1;
                              r_i2c_load_data_contr = IDLE;
                              r_prev_nak = i_nak; 
                         end
                         else if(!i_nak) begin
                              r_prev_nak = i_nak;
                         end

                         if(r_counterAck >= 10 & i_addr_ready) begin
                              r_state = NORESPOND;
                         end

                         if(r_counterConfig >= 10 & i_addr_ready) begin
                              r_state = NORESPOND;
                         end
                    end

                    CONFIGREAD: begin

                         if(i_addr_ready & (r_i2c_load_data_contr==IDLE)) begin
                              r_i2c_load_data_contr = LOAD_ADDR;
                         end
                         else if(r_i2c_load_data_contr==LOAD_ADDR & i_data_write_ready) begin
                              r_i2c_load_data_contr = LOAD_REG;
                         end
                         else if(r_i2c_load_data_contr==LOAD_REG) begin
                              r_i2c_load_data_contr = CHANGE_VALID;
                         end
                         else if(r_i2c_load_data_contr==CHANGE_VALID & i_nbytes_ready) begin
                              r_i2c_load_data_contr = LOAD_NBYTES;
                         end
                         else if(r_i2c_load_data_contr==LOAD_NBYTES & i_data_read_valid) begin
                              r_i2c_load_data_contr = ANALYSE_DATA;
                         end

                         if(!i_nak & (r_i2c_load_data_contr==ANALYSE_DATA) & i_addr_ready) begin  
                              r_i2c_load_data_contr = IDLE;
                              if(i_data_read_bits == CONFIG_REGISTER_DATA) begin
                                   r_state = READING;
                                   r_counterAck = 0;
                                   r_counterConfig = 0;
                              end
                              else begin
                                   r_counterConfig = r_counterConfig + 1;
                                   r_state = CONFIGUWRITE;
                              end
                         end
                         
                         if(i_nak & !r_prev_nak) begin
                              r_state = CONFIGREAD;
                              r_counterAck = r_counterAck + 1;
                              r_i2c_load_data_contr = IDLE;
                              r_prev_nak = i_nak; 
                         end
                         else if(!i_nak) begin
                              r_prev_nak = i_nak;
                         end

                         if(r_counterAck >= 10 & i_addr_ready) begin
                              r_state = NORESPOND;
                         end

                         if(r_counterConfig >= 10 & i_addr_ready) begin
                              r_state = NORESPOND;
                         end
                         
                    end

                    READING: begin

                         if(i_addr_ready & (r_i2c_load_data_contr==IDLE)) begin
                              r_i2c_load_data_contr = LOAD_ADDR;
                         end
                         else if(r_i2c_load_data_contr==LOAD_ADDR & i_data_write_ready) begin
                              r_i2c_load_data_contr = LOAD_REG;
                         end
                         else if(r_i2c_load_data_contr==LOAD_REG) begin
                              r_i2c_load_data_contr = CHANGE_VALID;
                         end
                         else if(r_i2c_load_data_contr==CHANGE_VALID & i_nbytes_ready) begin
                              r_i2c_load_data_contr = LOAD_NBYTES;
                         end
                         else if(r_i2c_load_data_contr==LOAD_NBYTES & i_data_read_valid) begin
                              r_i2c_load_data_contr = SAVE_DATA;
                         end
                         else if(r_i2c_load_data_contr==SAVE_DATA & (i_ready_in | i_fifo_full)) begin
                              r_i2c_load_data_contr = ANALYSE_DATA;
                         end

                         if(!i_nak & (r_i2c_load_data_contr==ANALYSE_DATA) & i_addr_ready) begin  
                              r_counterAck = 0;
                              r_i2c_load_data_contr = IDLE;
                              r_get_decimal_fraction = ~r_get_decimal_fraction;
                         end
                         
                         if(i_nak & !r_prev_nak) begin
                              r_state = READING;
                              r_counterAck = r_counterAck + 1;
                              r_i2c_load_data_contr = IDLE;
                              r_prev_nak = i_nak; 
                         end
                         else if(!i_nak) begin
                              r_prev_nak = i_nak;
                         end

                         if(r_counterAck >= 10 & i_addr_ready) begin
                              r_state = NORESPOND;
                         end
                    end
                    NORESPOND: begin
                         r_state = NORESPOND;
                    end
                    RESET: begin
                         r_state = ADDR;
                    end
               endcase
          end
     end

endmodule