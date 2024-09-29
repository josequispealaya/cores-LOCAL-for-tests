module UART_FSM #(
    parameter DATA_DEPTH = 8,
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

//Registro para los estados
reg [2:0] r_state;

//Registros
reg r_uart_recived_valid;
reg r_uart_recived_valid_prev;
reg r_decimal_data;
reg [4:0] r_outputs;
reg [DATA_DEPTH-1:0] r_uart_recived_data;

integer i;

//Estados
parameter RESET=0, WAITING_UART_VALID=1,WAITING_MESSAGE=2,READ_MESSAGE=3,SEND_INFO=4,SEND_DECIMAL_INFO=5;

localparam  GET_SENSOR0_DATA =      'd0,
            GET_SENSOR1_DATA =      'd1,
            GET_SENSOR2_DATA =      'd2,
            GET_SENSOR3_DATA =      'd3,
            GET_SENSOR4_DATA =      'd4,
            GET_SENSOR5_DATA =      'd5,
            GET_SENSOR6_DATA =      'd6,
            GET_SENSOR7_DATA =      'd7,
            GEN_FSM0_RST =      'd8,
            GEN_FSM1_RST =      'd9,
            GEN_FSM2_RST =      'd10,
            GEN_FSM3_RST =      'd11,
            GEN_FSM4_RST =      'd12,
            GEN_FSM5_RST =      'd13,
            GEN_FSM6_RST =      'd14,
            GEN_FSM7_RST =      'd15
;

//Logica de las salidas

always @(r_state or r_outputs)
    begin
        case (r_state)
            WAITING_UART_VALID: begin
                o_fsm_rst = 0;
                o_uart_send_valid = 0;
                o_uart_send_data = 0;
                o_uart_recived_data_ready = 0;
                o_fifo0_data_out_extracted = 0;
            end
            READ_MESSAGE: begin
                case (r_outputs)
                    GET_SENSOR0_DATA: begin
                        o_fifo0_data_out_extracted = 1;
                    end
                    GET_SENSOR1_DATA: begin
                    end
                    GET_SENSOR2_DATA: begin
                    end
                    GET_SENSOR3_DATA: begin
                    end
                    GET_SENSOR4_DATA: begin
                    end
                    GET_SENSOR5_DATA: begin
                    end
                    GET_SENSOR6_DATA: begin
                    end
                    GET_SENSOR7_DATA: begin
                    end
                    GEN_FSM0_RST: begin
                    end
                    GEN_FSM1_RST: begin
                    end
                    GEN_FSM2_RST: begin
                    end
                    GEN_FSM3_RST: begin
                    end
                    GEN_FSM4_RST: begin
                    end
                    GEN_FSM5_RST: begin
                    end
                    GEN_FSM6_RST: begin
                    end
                    GEN_FSM7_RST: begin
                    end
                endcase
            end/*
            SEND_INFO: begin
                case (r_outputs)
                    DATA_SENSOR0: begin
                        o_fifo0_data_out_extracted = 0;
                        o_uart_send_data = i_fifo0_data_out;
                        o_uart_send_valid = 1;
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
                case (r_outputs)
                    DATA_SENSOR0: begin
                        o_uart_send_valid = 0;
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
            end*/
            default: begin
                o_fsm_rst = 1'b0;
                o_uart_send_valid = 1'b0;
                o_uart_send_data = 0;
                o_uart_recived_data_ready = 1'b0;
                o_fifo0_data_out_extracted = 1'b0;
            end
        endcase
    end

//Logica de la maquina de estados

always @(posedge i_clk or posedge i_rst)
    begin
        if (i_rst) begin
            r_uart_recived_valid = i_uart_recived_valid;
            r_uart_recived_valid_prev = i_uart_recived_valid;
            r_state = WAITING_UART_VALID;
            r_decimal_data = 1'b0;
            r_uart_recived_data = 0;
        end
        else begin
            case (r_state)
                WAITING_UART_VALID: begin
                    if(!r_uart_recived_valid && r_uart_recived_valid_prev) begin
                        r_state = WAITING_MESSAGE;
                    end

                    r_uart_recived_valid_prev = r_uart_recived_valid;
                    r_uart_recived_valid = i_uart_recived_valid;

                end
                WAITING_MESSAGE: begin
                    if(r_uart_recived_valid && !r_uart_recived_valid_prev) begin
                        r_state = READ_MESSAGE;
                    end

                    r_uart_recived_valid_prev = r_uart_recived_valid;
                    r_uart_recived_valid = i_uart_recived_valid;
                end
                READ_MESSAGE: begin
                    if(r_uart_recived_data>=DATA_SENSOR0 && r_uart_recived_data<=FSM_SENSOR7)begin
                        case (r_uart_recived_data)
                            DATA_SENSOR0: begin
                                r_outputs = GET_SENSOR0_DATA;
                                if(i_fifo0_data_out_valid_to_extract) begin
                                    r_state = SEND_INFO;
                                end
                            end
                            DATA_SENSOR1: begin
                                if(i_fifo0_data_out_valid_to_extract) begin
                                    r_state = SEND_INFO;
                                end
                            end
                            DATA_SENSOR2: begin
                                if(i_fifo0_data_out_valid_to_extract) begin
                                    r_state = SEND_INFO;
                                end
                            end
                            DATA_SENSOR3: begin
                                if(i_fifo0_data_out_valid_to_extract) begin
                                    r_state = SEND_INFO;
                                end
                            end
                            DATA_SENSOR4: begin
                                if(i_fifo0_data_out_valid_to_extract) begin
                                    r_state = SEND_INFO;
                                end
                            end
                            DATA_SENSOR5: begin
                                if(i_fifo0_data_out_valid_to_extract) begin
                                    r_state = SEND_INFO;
                                end
                            end
                            DATA_SENSOR6: begin
                                if(i_fifo0_data_out_valid_to_extract) begin
                                    r_state = SEND_INFO;
                                end
                            end
                            DATA_SENSOR7: begin
                                if(i_fifo0_data_out_valid_to_extract) begin
                                    r_state = SEND_INFO;
                                end
                            end
                            FSM_SENSOR0: begin
                                if(i_fifo0_data_out_valid_to_extract) begin
                                    r_state = SEND_INFO;
                                end
                            end
                            FSM_SENSOR1: begin
                                if(i_fifo0_data_out_valid_to_extract) begin
                                    r_state = SEND_INFO;
                                end
                            end
                            FSM_SENSOR2: begin
                                if(i_fifo0_data_out_valid_to_extract) begin
                                    r_state = SEND_INFO;
                                end
                            end
                            FSM_SENSOR3: begin
                                if(i_fifo0_data_out_valid_to_extract) begin
                                    r_state = SEND_INFO;
                                end
                            end
                            FSM_SENSOR4: begin
                                if(i_fifo0_data_out_valid_to_extract) begin
                                    r_state = SEND_INFO;
                                end
                            end
                            FSM_SENSOR5: begin
                                if(i_fifo0_data_out_valid_to_extract) begin
                                    r_state = SEND_INFO;
                                end
                            end
                            FSM_SENSOR6: begin
                                if(i_fifo0_data_out_valid_to_extract) begin
                                    r_state = SEND_INFO;
                                end
                            end
                            FSM_SENSOR7: begin
                                if(i_fifo0_data_out_valid_to_extract) begin
                                    r_state = SEND_INFO;
                                end
                            end
                        endcase
                        
                    end
                    else begin
                        r_state = WAITING_UART_VALID;
                    end
                end
                SEND_INFO: begin
                    if(i_uart_send_data_ready) begin
                        r_decimal_data = ~r_decimal_data;
                        if(r_decimal_data) begin
                            r_state = SEND_DECIMAL_INFO;
                        end
                        else begin
                            r_state = WAITING_UART_VALID;
                        end
                    end
                end
                SEND_DECIMAL_INFO: begin
                    if(i_uart_send_data_ready) begin
                        r_state = READ_MESSAGE;
                    end
                end
                RESET: begin
                    r_state = WAITING_UART_VALID;
                end
            endcase

            for (i=0; i<DATA_DEPTH; i++) begin
                r_uart_recived_data[i] = i_uart_recived_data[DATA_DEPTH-i-1];  
            end
        end
    end

endmodule