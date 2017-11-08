/////////////////////////////////////////////////////////////////////
// Design unit: ecnrypt_pipe
//            :
// File name  : encrypt_pipe.sv
//            :
// Description: Top level wrapper connecting encryption pipeline stages
//            :
// Limitations: None
//            : 
// System     : SystemVerilog IEEE 1800-2005
//            :
// Revision   : Version 1.0 11/17
// Engineer   : Sebastian Lee (sbslee@gmail.com)
////////////////////////////////////////////////////////////////////


module encrypt_pipe(
		    input logic        clk,
		    input logic        rst,
		    input logic        en,
		    input logic [7:0]  din,
		    input logic [7:0]  k1 , k2 , k3,
		    input logic [2:0]  rot_freq,
		    input logic        shift_en,
		    input logic [3:0]  shift_amt,
		    input logic        mode,
		    output logic       v,
		    output logic [7:0] dout);


   //Internal pipe wiring...
   //From DC to SHIFT                   
   wire 			       en_out_dc;
   wire 			       is_alpha_upper_case_out , is_alpha_low_case_out;
   wire [31:0] 			       extended_shift_data_out_dc;
   //From SHIFT to XOR
   wire 			       en_out_shift;
   wire [7:0] 			       data_out_shift;

   //Pipe instances...
   encrypt_pipe_shift_dc encrypt_pipe_shift_dc_i ( .clk(clk), .rst(rst) , .en(en) , .k1(k1) , .k2(k2) , .k3(k3) , .rot_freq(rot_freq), .shift_en(shift_en)  , .shift_amt(shift_amt) , .mode(mode) ,  .din(din)  , .en_out(en_out_dc) , 
						   .is_alpha_upper_case_out(is_alpha_upper_case_out) , .is_alpha_low_case_out(is_alpha_low_case_out) , .extended_shift_data_out(extended_shift_data_out_dc));

   encrypt_pipe_shift_scramble encrypt_pipe_shift_scramble_i ( .clk(clk), .rst(rst) , .en(en_out_dc) , .k1(k1) , .k2(k2) , .k3(k3) , .rot_freq(rot_freq), .shift_en(shift_en)  , .shift_amt(shift_amt) , .mode(mode) , .extended_shift_in( extended_shift_data_out_dc) ,  
							       .is_alpha_upper_case(is_alpha_upper_case_out) , .is_alpha_low_case(is_alpha_low_case_out) , .en_out (en_out_shift) , .data_out(data_out_shift));

   encrypt_pipe_shift_xor encrypt_pipe_shift_xor_i ( .clk(clk), .rst(rst) , .en(en_out_shift) , .k1(k1) , .k2(k2) , .k3(k3) , .rot_freq(rot_freq), .mode(mode) , .din(data_out_shift), .encrypted_data (dout) , .encrypted_valid(v));

endmodule

