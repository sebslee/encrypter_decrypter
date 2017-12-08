/////////////////////////////////////////////////////////////////////
// Design unit: ecnrypt_pipe_shift_scramble
//            :
// File name  : encrypt_pipe_shift_scramble.sv
//            :
// Description: Receives encoded data. Applies pseudo shift and scrambles ,  data for xor stage.
//            :
// Limitations: None
//            : 
// System     : SystemVerilog IEEE 1800-2005
//            :
// Revision   : Version 1.0 11/17
// Engineer   : Sebastian Lee (sbslee@gmail.com)
////////////////////////////////////////////////////////////////////
//`include "../include/encrypt_config.svh"
`ifndef SHIFT_SCRAMBLE_PIPE
 `define SHIFT_SCRAMBLE_PIPE
//`include "../include/"

//import encrypt_config::*;


module encrypt_pipe_shift_scramble (
				    input logic        clk,
				    input logic        rst,
				    input logic        en,
				    input logic        shift_en,
				    input logic [2:0]  shift_amt,
				    input logic        mode,
				    input [25:0]       extended_shift_in,
				    input logic        is_alpha_upper_case ,
				    input logic        is_alpha_low_case,
				    //PIPE OUTPUTS
				    output logic       en_out,
				    output logic [7:0] data_out);

   logic [7:0] 					       data_out_int;
  // logic [7:0] 					       scrambled_data;
   logic [31:0] 				       shifted_data;
   logic [25:0] 				       aligned_data;
   logic [25:0] 				       aligned_data_f;
   logic [31:0]                                        extended_shift_int;
   logic [25:0]                                        extended_shift_in_f;
   logic en_f;
   logic mode_f;
   logic is_alpha_upper_case_f;
   logic is_alpha_low_case_f;
  // flop data out ...
   always_ff @ (posedge clk, negedge rst) begin : seq_logic
      if(rst == 1'b0) begin
	 en_out <= '0;
	 data_out <= '0;
      end // if (rst == 1'b0)      
      else begin
         mode_f <= mode;	
	 en_f <= en;
         en_out <= en_f;
	// data_out <= scrambled_data;	          
	data_out <= data_out_int;
        aligned_data_f <= aligned_data;
        extended_shift_in_f <= extended_shift_in;
        is_alpha_low_case_f <= is_alpha_low_case;
        is_alpha_upper_case_f <= is_alpha_upper_case;
      end // else: !if(rst == 1'b0)
   end // block: seq_logic 

   
   
   always_comb begin : comb_logic
      data_out_int = 'x;
     // scrambled_data = '0;     
      aligned_data = 'x;
      shifted_data ='x;
      extended_shift_int = 'x;

      if(en == 1'b1 && mode == 1'b1) begin      
	 if(shift_en && (is_alpha_upper_case || is_alpha_low_case)) begin
            extended_shift_int = {{6{1'b0}}, extended_shift_in};
	    shifted_data = extended_shift_int << shift_amt;
	    aligned_data[25:6] = shifted_data[25:6];
	    aligned_data[5:0] = shifted_data[31:26] | shifted_data[5:0];
	    //decode data back
         end 
         end


          //We are splitting this stage ...
          if(en_f == 1'b1 && mode_f == 1'b1) begin
	    if(is_alpha_upper_case_f) begin
	       case(aligned_data_f)
		 
		 26'b00000000000000000000000001: data_out_int = 8'd65;
		 26'b00000000000000000000000010: data_out_int = 8'd66;
		 26'b00000000000000000000000100: data_out_int = 8'd67;
		 26'b00000000000000000000001000: data_out_int = 8'd68;
		 26'b00000000000000000000010000: data_out_int = 8'd69;
		 26'b00000000000000000000100000: data_out_int = 8'd70;
		 26'b00000000000000000001000000: data_out_int = 8'd71;
		 26'b00000000000000000010000000: data_out_int = 8'd72;
		 26'b00000000000000000100000000: data_out_int = 8'd73;
		 26'b00000000000000001000000000: data_out_int = 8'd74;
		 26'b00000000000000010000000000: data_out_int = 8'd75;
		 26'b00000000000000100000000000: data_out_int = 8'd76;
		 26'b00000000000001000000000000: data_out_int = 8'd77;
		 26'b00000000000010000000000000: data_out_int = 8'd78;
		 26'b00000000000100000000000000: data_out_int = 8'd79;
		 26'b00000000001000000000000000: data_out_int = 8'd80;
		 26'b00000000010000000000000000: data_out_int = 8'd81;
		 26'b00000000100000000000000000: data_out_int = 8'd82;
		 26'b00000001000000000000000000: data_out_int = 8'd83;
		 26'b00000010000000000000000000: data_out_int = 8'd84;
		 26'b00000100000000000000000000: data_out_int = 8'd85;
		 26'b00001000000000000000000000: data_out_int = 8'd86;
		 26'b00010000000000000000000000: data_out_int = 8'd87;
		 26'b00100000000000000000000000: data_out_int = 8'd88;
		 26'b01000000000000000000000000: data_out_int = 8'd89;
		 26'b10000000000000000000000000: data_out_int = 8'd90;
		   
		 
	       endcase // case (aligned_data)
	       
	    end	  
	    else if(  is_alpha_low_case_f == 1'b1) begin
	       case(aligned_data_f)
		 
		 26'b00000000000000000000000001: data_out_int = 8'd97;
		 26'b00000000000000000000000010: data_out_int = 8'd98;
		 26'b00000000000000000000000100: data_out_int = 8'd99;
		 26'b00000000000000000000001000: data_out_int = 8'd100;
		 26'b00000000000000000000010000: data_out_int = 8'd101;
		 26'b00000000000000000000100000: data_out_int = 8'd102;
		 26'b00000000000000000001000000: data_out_int = 8'd103;
		 26'b00000000000000000010000000: data_out_int = 8'd104;
		 26'b00000000000000000100000000: data_out_int = 8'd105;
		 26'b00000000000000001000000000: data_out_int = 8'd106;
		 26'b00000000000000010000000000: data_out_int = 8'd107;
		 26'b00000000000000100000000000: data_out_int = 8'd108;
		 26'b00000000000001000000000000: data_out_int = 8'd109;
		 26'b00000000000010000000000000: data_out_int = 8'd110;
		 26'b00000000000100000000000000: data_out_int = 8'd111;
		 26'b00000000001000000000000000: data_out_int = 8'd112;
		 26'b00000000010000000000000000: data_out_int = 8'd113;
		 26'b00000000100000000000000000: data_out_int = 8'd114;
		 26'b00000001000000000000000000: data_out_int = 8'd115;
		 26'b00000010000000000000000000: data_out_int = 8'd116;
		 26'b00000100000000000000000000: data_out_int = 8'd117;
		 26'b00001000000000000000000000: data_out_int = 8'd118;
		 26'b00010000000000000000000000: data_out_int = 8'd119;
		 26'b00100000000000000000000000: data_out_int = 8'd120;
		 26'b01000000000000000000000000: data_out_int = 8'd121;
		 26'b10000000000000000000000000: data_out_int = 8'd122;
		   
		 
	       endcase // case (aligned_data)	       
	    end 	    	    
         else
	      data_out_int = extended_shift_in_f[7:0];
	 //end // if (shift_en && (is_alpha_upper_case || is_alpha_low_case))
      end // if (en == 1'b1 && mode == 1'b1)
   end // block: comb_logic

endmodule // encrypt_pipe_shift_scramble

`endif      


   
   
  
