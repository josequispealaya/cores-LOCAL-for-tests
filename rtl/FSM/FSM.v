module FSM(i_clk, i_ack, i_conf, i_rst, o_out);

input i_clk, i_ack, i_conf, i_rst;
output [3:0] o_out;

reg [3:0] o_out;
reg [2:0] r_state;

reg [3:0] r_counterAck;
reg [3:0] r_counterConfig;

parameter ADDR=0, CONFIGUWRITE=1, CONFIGREAD=2, READING=3, NORESPOND=4;

always @(r_state)
     begin
          case (r_state)
               ADDR:
                    o_out = 4'b0000;
               CONFIGUWRITE:
                    o_out = 4'b0001;
               CONFIGREAD:
                    o_out = 4'b0010;
               READING:
                    o_out = 4'b0100;
               NORESPOND:
                    o_out = 4'b1000;
               default:
                    o_out = 4'b0000;
          endcase
     end

always @(posedge i_clk or posedge i_rst)
     begin
          if (i_rst) begin
               r_state = ADDR;
               r_counterAck = 0;
               r_counterConfig = 0;
          end
          else begin
               case (r_state)
                    ADDR: begin
                         if(i_ack==1) begin
                              r_state = ADDR;
                              r_counterAck = r_counterAck + 1;
                         end
                         else if(i_ack==0) begin
                              r_state = CONFIGUWRITE;
                              r_counterAck = 0;
                         end

                         if(r_counterAck == 10) begin
                              r_state = NORESPOND;
                         end
                    end

                    CONFIGUWRITE: begin
                         if (i_ack==1) begin
                              r_state = CONFIGUWRITE;
                              r_counterAck = r_counterAck + 1;
                         end
                         else if(i_ack==0) begin
                              r_counterAck = 0;
                              r_state = CONFIGREAD;
                         end

                         if(r_counterAck == 10) begin
                              r_state = NORESPOND;
                         end

                         if(r_counterConfig == 10) begin
                              r_state = NORESPOND;
                         end
                    end

                    CONFIGREAD: begin
                         if (i_ack==1) begin
                              r_state = CONFIGREAD;
                              r_counterAck = r_counterAck + 1;
                         end
                         else if (i_conf==1) begin
                              r_counterConfig = r_counterConfig + 1;
                              r_state = CONFIGUWRITE;
                         end
                         else begin
                              r_counterAck = 0;
                              r_counterConfig = 0;
                              r_state = READING;      //Escribo en la FIFO el valor leido con el bit de error en 1
                         end

                         if(r_counterAck == 10) begin
                              r_state = NORESPOND;
                         end

                         if(r_counterConfig == 10) begin
                              r_state = NORESPOND;
                         end
                    end

                    READING: begin
                         if (i_ack==1) begin
                              r_state = READING;
                              r_counterAck = r_counterAck + 1;
                         end
                         else if (i_ack==0) begin
                              r_state = READING;      //Escribo en la FIFO el valor leido con el bit de error en 0
                         end
                         
                         if(r_counterAck == 10) begin
                              r_state = NORESPOND;            //Analizar la posibilidad de registrar desde que estado paso al estado NORESPOND
                         end
                    end

                    NORESPOND: begin
                         r_state = NORESPOND;
                    end
               endcase
          end
     end

endmodule