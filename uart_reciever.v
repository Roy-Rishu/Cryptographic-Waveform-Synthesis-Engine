
module uart_reciever(
    input clk,
    input rst,
    input rx,
    input rdy_clr,
    input clken, 
    output reg rdy,
    output reg [7:0] data_out
);

   
    reg rx_sync_0, rx_sync_1;
    always @(posedge clk) begin
        if (rst) begin
            rx_sync_0 <= 1'b1;
            rx_sync_1 <= 1'b1;
        end else begin
            rx_sync_0 <= rx;
            rx_sync_1 <= rx_sync_0;
        end
    end

    parameter RX_STATE_IDLE = 2'b00;
    parameter RX_STATE_DATA = 2'b01;
    parameter RX_STATE_STOP = 2'b10;

    reg [1:0] state;
    reg [3:0] sample_count;
    reg [3:0] bit_index;
    reg [7:0] shift_reg;

    always @(posedge clk) begin
        if (rst) begin
            rdy <= 0;
            data_out <= 0;
            state <= RX_STATE_IDLE;
            sample_count <= 0;
            bit_index <= 0;
        end else begin
            if (rdy_clr) rdy <= 0;

            if (clken) begin
                case (state)
                    RX_STATE_IDLE: begin
                        
                        if (!rx_sync_1 || sample_count != 0)
                            sample_count <= sample_count + 1;

                        if (sample_count == 15) begin
                            state <= RX_STATE_DATA;
                            bit_index <= 0;
                            sample_count <= 0;
                        end
                    end

                    RX_STATE_DATA: begin
                        sample_count <= sample_count + 1;
                        
                        if (sample_count == 4'h8) begin
                            shift_reg[bit_index] <= rx_sync_1;
                            bit_index <= bit_index + 1;
                        end
                        if (bit_index == 8 && sample_count == 15) begin
                            state <= RX_STATE_STOP;
                        end
                    end

                    RX_STATE_STOP: begin
                        if (sample_count == 15) begin
                            state <= RX_STATE_IDLE;
                            data_out <= shift_reg;
                            rdy <= 1'b1;
                            sample_count <= 0;
                        end else begin
                            sample_count <= sample_count + 1;
                        end
                    end
                    default: state <= RX_STATE_IDLE;
                endcase
            end
        end
    end
endmodule
