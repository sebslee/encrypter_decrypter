/////////////////////////////////////////////////////////////////////
// Design unit: ecnrypt_pipe_permutation
//            :
// File name  : encrypt_pipe_permutation.sv
//            :
// Description: Implements configurable permutation. Unit consists as a series of 8 multiplexors
// selecting the incoming bit to be shifted according to the programmed register. 
//            :
// Limitations: None
//            : 
// System     : SystemVerilog IEEE 1800-2005
//            :
// Revision   : Version 1.0 11/17
// Engineer   : Sebastian Lee (sbslee@gmail.com)
////////////////////////////////////////////////////////////////////



module encrypt_pipe_permutation (
				    input logic        clk,
				    input logic        rst,
				    input logic        en,
                                    input logic [2:0] perm0,
                                    input logic [2:0] perm1,
                                    input logic [2:0] perm2,
                                    input logic [2:0] perm3,
                                    input logic [2:0] perm4,
                                    input logic [2:0] perm5,
                                    input logic [2:0] perm6,
                                    input logic [2:0] perm7,
                                    input logic [7:0] data_in,
				    //PIPE OUTPUTS
				    output logic       valid_out,
				    output logic [7:0] data_out);
				    
				    
logic [7:0] data_out_int;
logic valid_out_int;

always_comb  begin : MUX_DATA

//Bit 0 MUX
case(perm0)
3'b000: data_out_int[0] = data_in[0];
3'b001: data_out_int[0] = data_in[1];
3'b010: data_out_int[0] = data_in[2];
3'b011: data_out_int[0] = data_in[3];
3'b100: data_out_int[0] = data_in[4];
3'b101: data_out_int[0] = data_in[5];
3'b110: data_out_int[0] = data_in[6];
3'b111: data_out_int[0] = data_in[7];
default: data_out_int[0] = 1'b0;
endcase

//Bit 1 MUX
case(perm1)
3'b000: data_out_int[1] = data_in[0];
3'b001: data_out_int[1] = data_in[1];
3'b010: data_out_int[1] = data_in[2];
3'b011: data_out_int[1] = data_in[3];
3'b100: data_out_int[1] = data_in[4];
3'b101: data_out_int[1] = data_in[5];
3'b110: data_out_int[1] = data_in[6];
3'b111: data_out_int[1] = data_in[7];
default: data_out_int[1] = 1'b0;
endcase

//Bit 2 MUX
case(perm2)
3'b000: data_out_int[2] = data_in[0];
3'b001: data_out_int[2] = data_in[1];
3'b010: data_out_int[2] = data_in[2];
3'b011: data_out_int[2] = data_in[3];
3'b100: data_out_int[2] = data_in[4];
3'b101: data_out_int[2] = data_in[5];
3'b110: data_out_int[2] = data_in[6];
3'b111: data_out_int[2] = data_in[7];
default: data_out_int[2] = 1'b0;
endcase

//Bit 3 MUX
case(perm3)
3'b000: data_out_int[3] = data_in[0];
3'b001: data_out_int[3] = data_in[1];
3'b010: data_out_int[3] = data_in[2];
3'b011: data_out_int[3] = data_in[3];
3'b100: data_out_int[3] = data_in[4];
3'b101: data_out_int[3] = data_in[5];
3'b110: data_out_int[3] = data_in[6];
3'b111: data_out_int[3] = data_in[7];
default: data_out_int[3] = 1'b0;
endcase


//Bit 4 MUX
case(perm4)
3'b000: data_out_int[4] = data_in[0];
3'b001: data_out_int[4] = data_in[1];
3'b010: data_out_int[4] = data_in[2];
3'b011: data_out_int[4] = data_in[3];
3'b100: data_out_int[4] = data_in[4];
3'b101: data_out_int[4] = data_in[5];
3'b110: data_out_int[4] = data_in[6];
3'b111: data_out_int[4] = data_in[7];
default: data_out_int[4] = 1'b0;
endcase


//Bit 5 MUX
case(perm5)
3'b000: data_out_int[5] = data_in[0];
3'b001: data_out_int[5] = data_in[1];
3'b010: data_out_int[5] = data_in[2];
3'b011: data_out_int[5] = data_in[3];
3'b100: data_out_int[5] = data_in[4];
3'b101: data_out_int[5] = data_in[5];
3'b110: data_out_int[5] = data_in[6];
3'b111: data_out_int[5] = data_in[7];
default: data_out_int[5] = 1'b0;
endcase

//Bit 6 MUX
case(perm6)
3'b000: data_out_int[6] = data_in[0];
3'b001: data_out_int[6] = data_in[1];
3'b010: data_out_int[6] = data_in[2];
3'b011: data_out_int[6] = data_in[3];
3'b100: data_out_int[6] = data_in[4];
3'b101: data_out_int[6] = data_in[5];
3'b110: data_out_int[6] = data_in[6];
3'b111: data_out_int[6] = data_in[7];
default: data_out_int[6] = 1'b0;
endcase

//Bit 1 MUX
case(perm7)
3'b000: data_out_int[7] = data_in[0];
3'b001: data_out_int[7] = data_in[1];
3'b010: data_out_int[7] = data_in[2];
3'b011: data_out_int[7] = data_in[3];
3'b100: data_out_int[7] = data_in[4];
3'b101: data_out_int[7] = data_in[5];
3'b110: data_out_int[7] = data_in[6];
3'b111: data_out_int[7] = data_in[7];
default: data_out_int[7] = 1'b0;
endcase

//Make the data valid next clock cycle...
if(en == 1'b1) 
valid_out_int = 1'b1;
else
valid_out_int = 1'b0;

end

//Flop the stuff...
always_ff @(posedge clk, negedge rst) begin
if(rst == 1'b0) begin
data_out <= '0;
valid_out <= 1'b0;
end
else begin
data_out <= data_out_int;
valid_out <= valid_out_int;
end
end

endmodule




