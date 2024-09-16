module FIFO
#(
    parameter ADDR_LENGTH = 8, WORD_LENGTH = 8
)
(
    input wire i_clk,
    input wire [WORD_LENGTH - 1 : 0] i_data_in,
    input wire i_data_in_valid,
    input wire i_ready_out,
    input wire i_reset,
    output reg [WORD_LENGTH - 1 : 0] o_data_out,
    output reg o_data_out_valid,
    output reg o_ready_in,
    output o_full
);

reg r_read_en;
reg r_write_en;
wire w_full;
wire w_empty;

localparam IDLE_IN = 2'b00;
localparam READY_READ = 2'b01;
localparam READING_DATA = 2'b10;

localparam IDLE_OUT = 2'b00;
localparam OUTPUT_DATA = 2'b01;

localparam WAIT_STATE = 2'b11;

reg[1:0] r_state_in;
reg[1:0] r_next_state_in;

reg[1:0] r_state_out;
reg[1:0] r_next_state_out;

wire[WORD_LENGTH - 1 : 0] w_internal_data_out;

FIFO_internal #(ADDR_LENGTH, WORD_LENGTH) fifo_internal (
    .i_clk(i_clk),
    .i_data_in(i_data_in),
    .i_read_en(r_read_en),
    .i_write_en(r_write_en),
    .i_reset(i_reset),
    .o_data_out(w_internal_data_out),
    .o_full(w_full),
    .o_empty(w_empty)
);

assign o_full = w_full;

always @(*) begin
// Input handshake next state logic
    case(r_state_in)
        IDLE_IN : begin
            if(w_full == 1'b0) begin
                r_next_state_in = READY_READ;
            end else begin
                r_next_state_in = IDLE_IN;
            end
        end

        READY_READ : begin
            if(i_data_in_valid == 1'b1) begin
                r_next_state_in = READING_DATA;
            end else begin
                r_next_state_in = READY_READ;
            end
        end

        READING_DATA : begin
            if(i_data_in_valid == 1'b0) begin
                r_next_state_in = IDLE_IN;
            end else begin
                r_next_state_in = WAIT_STATE;
            end
        end

        WAIT_STATE : begin
            if(i_data_in_valid == 1'b0) begin
                if(w_full == 1'b0) begin
                    r_next_state_in = READY_READ;
                end else begin
                    r_next_state_in = IDLE_IN;
                end
            end else begin
                r_next_state_in = WAIT_STATE;
            end
        end

        default : r_next_state_in = IDLE_IN;
    endcase

    if(r_next_state_in == READING_DATA) begin
        r_write_en = 1'b1;
    end else begin
        r_write_en = 1'b0;
    end

// Output handshake next state logic
    case(r_state_out)
        IDLE_OUT : begin
            if(i_ready_out == 1'b1 && w_empty == 1'b0) begin
                r_next_state_out = OUTPUT_DATA;
            end else begin
                r_next_state_out = IDLE_OUT;
            end
        end

        OUTPUT_DATA : begin
            if(i_ready_out == 1'b0) begin
                r_next_state_out = IDLE_OUT;
            end else begin
                r_next_state_out = WAIT_STATE;
            end
        end

        WAIT_STATE : begin
            if(i_ready_out == 1'b0) begin
                r_next_state_out = IDLE_OUT;
            end else begin
                r_next_state_out = WAIT_STATE;
            end
        end

        default : r_next_state_out = IDLE_OUT;
    endcase

    if(r_next_state_out == OUTPUT_DATA) begin
        r_read_en = 1'b1;
    end else begin
        r_read_en = 1'b0;
    end
end

// Output signals logic
always @(*) begin
    if(r_state_in == READY_READ) begin
        o_ready_in = 1'b1;
    end else begin
        o_ready_in = 1'b0;
    end

    if(r_state_out == OUTPUT_DATA || r_state_out == WAIT_STATE) begin
        o_data_out_valid = 1'b1;
    end else begin
        o_data_out_valid = 1'b0;
    end
end

always @(posedge i_clk) begin
    if(i_reset == 1) begin
        r_state_in <= IDLE_IN;
        r_state_out <= IDLE_OUT;
    end else begin
        r_state_in <= r_next_state_in;
        r_state_out <= r_next_state_out;

        if(w_empty == 1'b0) begin
            o_data_out <= w_internal_data_out;
        end
    end
end

endmodule
