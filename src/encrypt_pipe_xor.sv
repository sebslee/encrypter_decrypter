/////////////////////////////////////////////////////////////////////
// Design unit: ecnrypt_pipe_xor
//            :
// File name  : encrypt_pipe_shift_xor.sv
//            :
// Description: Applies xor key phase and rotates the key according to programmed value
//            :
// Limitations: None
//            : 
// System     : SystemVerilog IEEE 1800-2005
//            :
// Revision   : Version 1.0 11/17
// Engineer   : Sebastian Lee (sbslee@gmail.com)
////////////////////////////////////////////////////////////////////

`ifndef XOR_PIPE
 `define XOR_PIPE
module encrypt_pipe_shift_xor(
			      input logic 	 clk,
			      input logic 	 rst,
			      input logic 	 en,
			      input logic [7:0]  din,
			      input logic [7:0]  k1 , k2 , k3,
			      input logic [2:0]  rot_freq,
			      input 		 mode,
			      output logic [7:0] encrypted_data,
			      output logic 	 encrypted_valid);

   logic [7:0] 					 encrypted_data_int;
   logic [7:0] 					 curr_key;
   logic [2:0] 					 cnt , next_cnt;
   logic [7:0] 					 next_key;
   logic [2:0] 					 curr_key_sel , next_key_sel;
   logic 					 valid_ff;
   
   
   
   
   

   always_comb begin: combo_logic
      
      next_key = k1;
      next_key_sel = 3'b001;
      next_cnt = '0;
      valid_ff = 1'b0;   
      encrypted_data_int = '0;
      
      if(mode == 1'b1 && en == 1'b1) begin
	 encrypted_data_int = din ^ curr_key;
	 valid_ff = 1'b1;      
	 
	 if(cnt == rot_freq) begin
	    next_key_sel = {curr_key_sel[1] , curr_key_sel[0] , curr_key_sel[2]};
            next_cnt = '0;   
	 end
	 else begin
	   next_key_sel = curr_key_sel;
	   next_cnt = cnt + 1;
	 end
	 

	 case(curr_key_sel)
	   3'b001: next_key = k1;
	   3'b010: next_key = k2;
	   3'b100: next_key = k3;
	   default: next_key ='0;
	 endcase // case (curr_key_sel)

                  
      end // if (mode == 1'b1 && en == 1'b1)      
   end // block: combo_logic
   
   always_ff @(posedge clk , negedge rst) begin : seq_logic
      if(rst == 1'b0) begin
	 curr_key <= k1;
	 curr_key_sel <= 3'b001;
	 cnt <= '0;
	 encrypted_data <= '0;
	 encrypted_valid <= '0;	 
      end
      else begin
	 curr_key <= next_key;
	 cnt <= next_cnt;
	 curr_key_sel <= next_key_sel;
	 encrypted_valid <= valid_ff;
	 encrypted_data <= encrypted_data_int;
      end // else: !if(rst == 1'b0)
   end // block: seq_logic
   
endmodule // encrypt_pipe_shift_xor

`endif //  `ifndef XOR_PIPE


  
