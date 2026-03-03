
module xor_cipher ( input [7:0] data_in, input [7:0] key, output [7:0] data_out );
    assign data_out = data_in ^ key;
endmodule
