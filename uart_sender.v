
module uart_sender(
    input clk, wr_en, enb, rst,
    input [7:0] data_in,
    output reg tx,
    output tx_busy
);
    parameter IDLE=2'b00, START=2'b01, DATA=2'b10, STOP=2'b11;
    reg [7:0] data;
    reg [2:0] bitpos;
    reg [1:0] state;

    always @(posedge clk) begin
        if (rst) begin
            tx <= 1'b1;
            state <= IDLE;
        end else begin
            case (state)
                IDLE: if (wr_en) begin state <= START; data <= data_in; bitpos <= 0; end
                START: if (enb) begin tx <= 1'b0; state <= DATA; end
                DATA: if (enb) begin
                        tx <= data[bitpos];
                        if (bitpos == 7) state <= STOP;
                        else bitpos <= bitpos + 1;
                      end
                STOP: if (enb) begin tx <= 1'b1; state <= IDLE; end
            endcase
        end
    end
    assign tx_busy = (state != IDLE);
endmodule
