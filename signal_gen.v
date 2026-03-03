module signal_gen (
    input clk, 
    input rst,
    output [7:0] sine, 
    output [7:0] cosine, 
    output [7:0] square, 
    output [7:0] triangle, 
    output [7:0] up_ramp, 
    output [7:0] dwn_ramp
);

    

    square_wave_integ     S1 (.clk(clk), .rst(rst), .square(square));
    triangular_wave_integ S2 (.clk(clk), .rst(rst), .triangle(triangle));
    rising_ramp_integ     S3 (.clk(clk), .rst(rst), .up_ramp(up_ramp));
    falling_ramp_integ    S4 (.clk(clk), .rst(rst), .dwn_ramp(dwn_ramp));
    
   
    sine_cosine_integ     S5_6 (.clk(clk), .rst(rst), .sine_wave(sine), .cos_wave(cosine));

endmodule



module square_wave_integ(input clk, rst, output [7:0] square);
    reg [7:0] count; 
    reg toggle;
    assign square = toggle ? 8'hFF : 8'h00;
    always @(posedge clk) begin
        if (rst) begin 
            toggle <= 0; count <= 0; 
        end else begin 
            {toggle, count} <= {toggle, count} + 1'b1; 
        end
    end
endmodule

module triangular_wave_integ(input clk, rst, output [7:0] triangle);
    reg [7:0] count; 
    reg dir;
    assign triangle = count;
    always @(posedge clk) begin
        if (rst) begin 
            dir <= 1'b1; count <= 0; 
        end else if (dir) begin
            if (count == 8'hFF) dir <= 1'b0;
            else count <= count + 1'b1;
        end else begin
            if (count == 8'h00) dir <= 1'b1;
            else count <= count - 1'b1;
        end
    end
endmodule

module rising_ramp_integ(input clk, rst, output [7:0] up_ramp);
    reg [7:0] count;
    assign up_ramp = count;
    always @(posedge clk) begin
        if (rst) count <= 0;
        else count <= count + 1'b1;
    end
endmodule

module falling_ramp_integ(input clk, rst, output [7:0] dwn_ramp);
    reg [7:0] count;
    assign dwn_ramp = count;
    always @(posedge clk) begin
        if (rst) count <= 8'hFF;
        else count <= count - 1'b1;
    end
endmodule

module sine_cosine_integ(
    input clk, rst,
    output reg [7:0] sine_wave, 
    output reg [7:0] cos_wave
);

    reg [4:0] step; 

    always @(posedge clk) begin
        if (rst) 
            step <= 0;
        else 
            step <= step + 5'd1; 
    end

    wire [4:0] cos_step;
    assign cos_step = step + 5'd8; 

    function [7:0] get_wave_value(input [4:0] phase);
        case(phase)
            5'd0  : get_wave_value = 8'd128; 
            5'd1  : get_wave_value = 8'd153;
            5'd2  : get_wave_value = 8'd177;
            5'd3  : get_wave_value = 8'd199;
            5'd4  : get_wave_value = 8'd218;
            5'd5  : get_wave_value = 8'd234;
            5'd6  : get_wave_value = 8'd245;
            5'd7  : get_wave_value = 8'd252;
            5'd8  : get_wave_value = 8'd255; 
            5'd9  : get_wave_value = 8'd252;
            5'd10 : get_wave_value = 8'd245;
            5'd11 : get_wave_value = 8'd234;
            5'd12 : get_wave_value = 8'd218;
            5'd13 : get_wave_value = 8'd199;
            5'd14 : get_wave_value = 8'd177;
            5'd15 : get_wave_value = 8'd153;
            5'd16 : get_wave_value = 8'd128; 
            5'd17 : get_wave_value = 8'd103;
            5'd18 : get_wave_value = 8'd79;
            5'd19 : get_wave_value = 8'd57;
            5'd20 : get_wave_value = 8'd38;
            5'd21 : get_wave_value = 8'd22;
            5'd22 : get_wave_value = 8'd11;
            5'd23 : get_wave_value = 8'd4;
            5'd24 : get_wave_value = 8'd0;
            5'd25 : get_wave_value = 8'd4;
            5'd26 : get_wave_value = 8'd11;
            5'd27 : get_wave_value = 8'd22;
            5'd28 : get_wave_value = 8'd38;
            5'd29 : get_wave_value = 8'd57;
            5'd30 : get_wave_value = 8'd79;
            5'd31 : get_wave_value = 8'd103;
        endcase
    endfunction

    
    always @(posedge clk) begin
        sine_wave <= get_wave_value(step);     
        cos_wave  <= get_wave_value(cos_step); 
    end

endmodule
