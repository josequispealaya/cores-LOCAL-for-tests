module UART_FSM #(
    parameter DATA_DEPTH = 8,
    parameter DATA_SENSOR0 = 97,
    parameter DATA_SENSOR1 = 98,
    parameter DATA_SENSOR2 = 99,
    parameter DATA_SENSOR3 = 100,
    parameter DATA_SENSOR4 = 101,
    parameter DATA_SENSOR5 = 102,
    parameter DATA_SENSOR6 = 103,
    parameter DATA_SENSOR7 = 104,
    parameter FSM_SENSOR0 =  105,
    parameter FSM_SENSOR1 =  106,
    parameter FSM_SENSOR2 =  107,
    parameter FSM_SENSOR3 =  108,
    parameter FSM_SENSOR4 =  109,
    parameter FSM_SENSOR5 =  110,
    parameter FSM_SENSOR6 =  111,
    parameter FSM_SENSOR7 =  112
) (
    input i_clk,
    input i_rst,

    input [DATA_DEPTH-1:0] i_uart_recived_data,
    input i_uart_recived_valid,
    output reg o_uart_recived_data_ready,

    output reg [DATA_DEPTH-1:0] o_uart_send_data,
    output reg o_uart_send_valid,
    input i_uart_send_data_ready,

    output reg o_fifo0_data_out_extracted,
    input i_fifo0_data_out_valid_to_extract,
    input [DATA_DEPTH-1:0] i_fifo0_data_out,
    output reg o_fsm_rst
);

//Estados
localparam RESET=0, WAITING_UART_VALID=1,WAITING_MESSAGE=2,READ_MESSAGE=3,SEND_INFO=4,WAIT_SEND_INFO=5,SEND_DECIMAL_INFO=6;

//Registro para los estados
reg [2:0] r_state;
reg [2:0] r_nstate;

//Registros
reg r_uart_recived_valid;
reg r_uart_recived_valid_prev;
reg r_decimal_data;
reg r_decimal_data_prev;
reg [DATA_DEPTH-1:0] r_uart_recived_data;
reg [30:0] r_counter = 0;

integer i;

always @(r_state or r_uart_recived_data)
    begin
        case (r_state)
            WAITING_UART_VALID: begin
                o_fsm_rst <= 0;
                o_uart_send_valid <= 0;
                o_uart_send_data <= 0;
                o_uart_recived_data_ready <= 0;
                o_fifo0_data_out_extracted <= 0;
            end
            READ_MESSAGE: begin
                case (r_uart_recived_data)
                    DATA_SENSOR0: begin
                        o_fifo0_data_out_extracted <= 1;
                    end
                    DATA_SENSOR1: begin
                    end
                    DATA_SENSOR2: begin
                    end
                    DATA_SENSOR3: begin
                    end
                    DATA_SENSOR4: begin
                    end
                    DATA_SENSOR5: begin
                    end
                    DATA_SENSOR6: begin
                    end
                    DATA_SENSOR7: begin
                    end
                    FSM_SENSOR0: begin
                    end
                    FSM_SENSOR1: begin
                    end
                    FSM_SENSOR2: begin
                    end
                    FSM_SENSOR3: begin
                    end
                    FSM_SENSOR4: begin
                    end
                    FSM_SENSOR5: begin
                    end
                    FSM_SENSOR6: begin
                    end
                    FSM_SENSOR7: begin
                    end
                endcase
            end
            SEND_INFO: begin
                case (r_uart_recived_data)
                    DATA_SENSOR0: begin
                        o_fifo0_data_out_extracted <= 0;
                        o_uart_send_data <= i_fifo0_data_out;
                        o_uart_send_valid <= 1;
                    end
                    DATA_SENSOR1: begin
                    end
                    DATA_SENSOR2: begin
                    end
                    DATA_SENSOR3: begin
                    end
                    DATA_SENSOR4: begin
                    end
                    DATA_SENSOR5: begin
                    end
                    DATA_SENSOR6: begin
                    end
                    DATA_SENSOR7: begin
                    end
                    FSM_SENSOR0: begin
                    end
                    FSM_SENSOR1: begin
                    end
                    FSM_SENSOR2: begin
                    end
                    FSM_SENSOR3: begin
                    end
                    FSM_SENSOR4: begin
                    end
                    FSM_SENSOR5: begin
                    end
                    FSM_SENSOR6: begin
                    end
                    FSM_SENSOR7: begin
                    end
                endcase
            end
            SEND_INFO: begin
                case (r_uart_recived_data)
                    DATA_SENSOR0: begin
                        o_uart_send_valid <= 0;
                    end
                    DATA_SENSOR1: begin
                    end
                    DATA_SENSOR2: begin
                    end
                    DATA_SENSOR3: begin
                    end
                    DATA_SENSOR4: begin
                    end
                    DATA_SENSOR5: begin
                    end
                    DATA_SENSOR6: begin
                    end
                    DATA_SENSOR7: begin
                    end
                    FSM_SENSOR0: begin
                    end
                    FSM_SENSOR1: begin
                    end
                    FSM_SENSOR2: begin
                    end
                    FSM_SENSOR3: begin
                    end
                    FSM_SENSOR4: begin
                    end
                    FSM_SENSOR5: begin
                    end
                    FSM_SENSOR6: begin
                    end
                    FSM_SENSOR7: begin
                    end
                endcase
            end
            default: begin
                o_fsm_rst <= 1'b0;
                o_uart_send_valid <= 1'b0;
                o_uart_send_data <= 0;
                o_uart_recived_data_ready <= 1'b0;
                o_fifo0_data_out_extracted <= 1'b0;
            end
        endcase
    end

//Logica de la maquina de estados
/*
always @(posedge i_clk or posedge i_rst)
    begin
        if (i_rst) begin
            r_uart_recived_valid <= i_uart_recived_valid;
            r_uart_recived_valid_prev <= i_uart_recived_valid;
            r_state <= WAITING_UART_VALID;
            r_nstate <= WAITING_UART_VALID;
            r_decimal_data <= 1'b0;
            r_decimal_data_prev <= 1'b0;
            r_uart_recived_data <= 0;
        end
        else begin
            
            r_state = r_nstate;
        
            case (r_state)
                WAITING_UART_VALID: begin
                    
                    if((!r_uart_recived_valid && r_uart_recived_valid_prev) || (r_decimal_data)) begin
                        r_nstate = WAITING_MESSAGE;
                    end

                    r_uart_recived_valid_prev = r_uart_recived_valid;
                    r_uart_recived_valid = i_uart_recived_valid;
                    

                end
                WAITING_MESSAGE: begin
                    
                    if((r_uart_recived_valid && !r_uart_recived_valid_prev) || (r_decimal_data)) begin
                        r_nstate <= READ_MESSAGE;
                    end

                    r_uart_recived_valid_prev = r_uart_recived_valid;
                    r_uart_recived_valid = i_uart_recived_valid;

                end
                READ_MESSAGE: begin
                    case (r_uart_recived_data)
                        DATA_SENSOR0: begin

                            if(i_fifo0_data_out_valid_to_extract) begin
                                r_nstate <= SEND_INFO;
                            end

                        end
                        DATA_SENSOR1: begin
                        end
                        DATA_SENSOR2: begin
                        end
                        DATA_SENSOR3: begin
                        end
                        DATA_SENSOR4: begin
                        end
                        DATA_SENSOR5: begin
                        end
                        DATA_SENSOR6: begin
                        end
                        DATA_SENSOR7: begin
                        end
                        FSM_SENSOR0: begin
                        end
                        FSM_SENSOR1: begin
                        end
                        FSM_SENSOR2: begin
                        end
                        FSM_SENSOR3: begin
                        end
                        FSM_SENSOR4: begin
                        end
                        FSM_SENSOR5: begin
                        end
                        FSM_SENSOR6: begin
                        end
                        FSM_SENSOR7: begin
                        end
                        default: begin
                            r_nstate <= WAITING_UART_VALID;
                        end
                    endcase

                end
                SEND_INFO: begin

                    r_nstate <= WAIT_SEND_INFO;

                end
                WAIT_SEND_INFO: begin

                    r_nstate <= SEND_DECIMAL_INFO;
                    
                end
                SEND_DECIMAL_INFO: begin

                    if(i_uart_send_data_ready) begin
                        r_decimal_data = ~r_decimal_data_prev;
                        r_nstate <= WAITING_UART_VALID;
                    end
                end
                RESET: begin
                    r_nstate <= WAITING_UART_VALID;
                end
            endcase

            r_decimal_data_prev = r_decimal_data;
            r_uart_recived_data = i_uart_recived_data;

        end
    end
*/

always @(posedge i_clk or posedge i_rst) begin
    if (i_rst) begin
            r_uart_recived_valid <= i_uart_recived_valid;
            r_uart_recived_valid_prev <= i_uart_recived_valid;
            r_state <= WAITING_UART_VALID;
            r_nstate <= WAITING_UART_VALID;
            r_decimal_data <= 1'b0;
            r_decimal_data_prev <= 1'b0;
            r_uart_recived_data <= 0;
    end
    else begin
        
        r_state = r_nstate;
    
        r_decimal_data_prev = r_decimal_data;
        //r_uart_recived_data = i_uart_recived_data;
        
        r_uart_recived_valid_prev = r_uart_recived_valid;
        //r_uart_recived_valid = i_uart_recived_valid;
        
        if(r_counter==1300 ||r_counter==1301 || r_counter==1302) /*(r_counter==13000000 ||r_counter==13000001 || r_counter==13000002)*/ begin
            r_uart_recived_data <= DATA_SENSOR0;
            r_uart_recived_valid <= 1'b0;
            r_counter <= r_counter + 1;
        end
        else if(r_counter>=1303) begin
            r_uart_recived_data <= DATA_SENSOR0;
            r_uart_recived_valid <= 1'b1;
            r_counter <= 0;
        end
        else begin
            r_counter <= r_counter + 1;
        end
        
    end
end

always @(r_state or r_uart_recived_valid or r_uart_recived_valid_prev or r_decimal_data or r_uart_recived_data or i_fifo0_data_out_valid_to_extract or i_uart_send_data_ready)
    begin
        case (r_state)
            WAITING_UART_VALID: begin
                
                if((!r_uart_recived_valid && r_uart_recived_valid_prev) || (r_decimal_data)) begin
                    r_nstate <= WAITING_MESSAGE;
                end            

            end
            WAITING_MESSAGE: begin
                
                if((r_uart_recived_valid && !r_uart_recived_valid_prev) || (r_decimal_data)) begin
                    r_nstate <= READ_MESSAGE;
                end

            end
            READ_MESSAGE: begin
                case (r_uart_recived_data)
                    DATA_SENSOR0: begin

                        if(i_fifo0_data_out_valid_to_extract) begin
                            r_nstate <= SEND_INFO;
                        end

                    end
                    DATA_SENSOR1: begin
                    end
                    DATA_SENSOR2: begin
                    end
                    DATA_SENSOR3: begin
                    end
                    DATA_SENSOR4: begin
                    end
                    DATA_SENSOR5: begin
                    end
                    DATA_SENSOR6: begin
                    end
                    DATA_SENSOR7: begin
                    end
                    FSM_SENSOR0: begin
                    end
                    FSM_SENSOR1: begin
                    end
                    FSM_SENSOR2: begin
                    end
                    FSM_SENSOR3: begin
                    end
                    FSM_SENSOR4: begin
                    end
                    FSM_SENSOR5: begin
                    end
                    FSM_SENSOR6: begin
                    end
                    FSM_SENSOR7: begin
                    end
                    default: begin
                        r_nstate <= WAITING_UART_VALID;
                    end
                endcase

            end
            SEND_INFO: begin

                r_nstate <= WAIT_SEND_INFO;

            end
            WAIT_SEND_INFO: begin

                r_nstate <= SEND_DECIMAL_INFO;
                
            end
            SEND_DECIMAL_INFO: begin

                if(i_uart_send_data_ready) begin
                    r_decimal_data = ~r_decimal_data_prev;
                    r_nstate <= WAITING_UART_VALID;
                end
            end
            RESET: begin
                r_nstate <= WAITING_UART_VALID;
            end
        endcase

    end


endmodule