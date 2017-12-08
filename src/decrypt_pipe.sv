/////////////////////////////////////////////////////////////////////
// Design unit: decrypt_pipe
//            :
// File name  : decrypt_pipe.sv
//            :
// Description: Top level wrapper for decrypt pipeline. This module
// reuses data compare  stage from encrypt pipe. 
//            :
// Limitations: None
//            : 
// System     : SystemVerilog IEEE 1800-2005
//            :
// Revision   : Version 1.0 11/17
// Engineer   : Sebastian Lee (sbslee@gmail.com)
////////////////////////////////////////////////////////////////////
`ifndef DECRYPT_PIPE_TOP
`define DECRYPT_PIPE_TOP
`include "decrypt_pipe_xor.sv"
`include "decrypt_pipe_dc.sv"
`include "decrypt_pipe_shift.sv"
`include "decrypt_pipe_permutation.sv"

module decrypt_pipe (
		     input logic 	clk,
		     input logic 	rst,
		     input logic 	en,
		     input logic [7:0] 	din,
		     input logic [7:0] 	k1 , k2 , k3,
		     input logic [2:0] 	rot_freq,
		     input logic 	shift_en,
		     input logic [2:0] 	shift_amt,
		     input logic 	mode,
		     output logic 	v,
                     input logic [2:0] perm0,
                                    input logic [2:0] perm1,
                                    input logic [2:0] perm2,
                                    input logic [2:0] perm3,
                                    input logic [2:0] perm4,
                                    input logic [2:0] perm5,
                                    input logic [2:0] perm6,
                                    input logic [2:0] perm7,
		     output logic [7:0] dout);


   //Internal pipe wiring...
   //From DC to SHIFT                   
   logic 				xor_data_valid;
   logic 				is_alpha_upper_case_out , is_alpha_low_case_out;
   logic [31:0] 				extended_shift_data_out_dc;
   //From SHIFT to XOR
   logic 				en_out_shift;
   logic [7:0] 				data_out_xor;
   logic en_out_dc;

   logic [7:0] permutation_data_out;
   logic permutation_valid;
   
   decrypt_pipe_xor decrypt_pipe_xor_i ( .clk(clk), .rst(rst) , .en(en) , .k1(k1) , .k2(k2) , .k3(k3) , .rot_freq(rot_freq), .mode(mode) , .din(din), .encrypted_data (data_out_xor) , .encrypted_valid(xor_data_valid) );
				    
   decrypt_pipe_permutation decrypt_pipe_permutation_i (.clk(clk), .rst(rst) , .en(xor_data_valid) , .perm0 (perm0) , .perm1 (perm1) , .perm2 (perm2) , .perm3 (perm3) , .perm4 (perm4)  , .perm5 (perm5) , .perm6 (perm6) , .perm7 (perm7) , .data_in(data_out_xor) , .data_out(permutation_data_out) , .valid_out(permutation_valid));
   
   decrypt_pipe_dc decrypt_pipe_dc_i ( .clk(clk), .rst(rst) , .en(permutation_valid) , .shift_en(shift_en)   , .mode(mode) ,  .din(permutation_data_out)  , .en_out(en_out_dc) , 
						   .is_alpha_upper_case_out(is_alpha_upper_case_out) , .is_alpha_low_case_out(is_alpha_low_case_out) , .extended_shift_data_out(extended_shift_data_out_dc));


   decrypt_pipe_shift decrypt_pipe_shift_i (.clk(clk), .rst(rst) , .en(en_out_dc) ,   .shift_en(shift_en)  , .shift_amt(shift_amt) , .mode(mode) , .extended_shift_in( extended_shift_data_out_dc) ,  
					    .is_alpha_upper_case(is_alpha_upper_case_out) , .is_alpha_low_case(is_alpha_low_case_out) , .en_out (v) , .data_out(dout));
   
   
endmodule // decrypt_pipe
`endif
   
   
