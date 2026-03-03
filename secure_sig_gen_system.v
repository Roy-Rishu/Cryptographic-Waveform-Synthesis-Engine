
module secure_sig_gen_system(
    input clk,
    input rst,
    input rx_pin,           
    output tx_pin,          
    output [7:0] wave_out   
);
    wire [7:0] rx_data;
    wire rx_ready;
    wire tx_busy;
    reg [7:0] current_mode;
    reg transmit_en;
    
    wire [7:0] s, c, sq, tr, ur, dr;

    
    uart_top comms (
        .clk(clk), .rst(rst),
        .data_in(current_mode), 
        .wr_en(transmit_en),    
        .rdy_clr(rx_ready),
        .rx_pin(rx_pin), .tx_pin(tx_pin),
        .rdy(rx_ready), .busy(tx_busy),
        .data_out(rx_data)
    );

   
    signal_gen engines (
        .clk(clk), .rst(rst),
        .sine(s), .cosine(c), .square(sq), .triangle(tr), .up_ramp(ur), .dwn_ramp(dr)
    );

    
    always @(posedge clk) begin
        if (rst) begin
            current_mode <= 8'h31; 
            transmit_en <= 1'b0;
        end else begin
            if (rx_ready) begin
                current_mode <= rx_data; 
                transmit_en <= 1'b1;     
            end else begin
                transmit_en <= 1'b0;     
            end
        end
    end

    
    assign wave_out = (current_mode == 8'h31) ? s  : 
                      (current_mode == 8'h32) ? c  : 
                      (current_mode == 8'h33) ? sq : 
                      (current_mode == 8'h34) ? tr : 
                      (current_mode == 8'h35) ? ur : 
                      (current_mode == 8'h36) ? dr : 8'h7F;
endmodule
