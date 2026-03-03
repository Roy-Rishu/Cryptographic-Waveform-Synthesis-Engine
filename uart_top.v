
module uart_top (
    input clk, rst, wr_en, rdy_clr, rx_pin,
    input [7:0] data_in,
    output tx_pin, rdy, busy,
    output [7:0] data_out
);
    parameter [7:0] SECRET_KEY = 8'hAC;
    wire tx_clk_en, rx_clk_en;
    wire [7:0] encrypted_tx, raw_rx;

    xor_cipher encrypt ( .data_in(data_in), .key(SECRET_KEY), .data_out(encrypted_tx) );
    baud_rate_genrator bg ( .clock(clk), .reset(rst), .enb_tx(tx_clk_en), .enb_rx(rx_clk_en) );
    uart_sender us ( .clk(clk), .wr_en(wr_en), .enb(tx_clk_en), .rst(rst), .data_in(encrypted_tx), .tx(tx_pin), .tx_busy(busy) );
    uart_reciever ur ( .clk(clk), .rst(rst), .rx(rx_pin), .rdy_clr(rdy_clr), .clken(rx_clk_en), .rdy(rdy), .data_out(raw_rx) );
    xor_cipher decrypt ( .data_in(raw_rx), .key(SECRET_KEY), .data_out(data_out) );
endmodule
