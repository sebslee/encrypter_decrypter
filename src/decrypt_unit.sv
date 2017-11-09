/////////////////////////////////////////////////////////////////////
// Design unit: decrypt_unit
//            :
// File name  : decrypt_unit.sv
//            :
// Description: Top module for decryption. Module is completely simetric to encryption 
//            : unit in high performance mode (permutation order reversed, xor operation symetric)
// Limitations: None
//            : 
// System     : SystemVerilog IEEE 1800-2005
//            :
// Revision   : Version 1.0 11/17
// Engineer   : Sebastian Lee (sbslee@gmail.com)
////////////////////////////////////////////////////////////////////
`ifndef DECRYPT_UNIT
`define DECRYPT_UNIT
`include "../include/encrypt_config.svh"
import encrypt_config::*;

module decrypt_unit (
		     input logic 	clk,
		     input logic 	rst,
		     input logic [7:0] 	din,
		     input logic 	en,
`ifndef HP_MODE
		     input logic [7:0] 	k1 , k2 , k3,
		     input logic [2:0] 	rot_freq,
		     input logic 	shift_en,
		     input logic [2:0] 	shift_amt,
		     input logic mode,
`endif
		     
		     output logic [7:0] dout,
		     output logic 	v);
`ifdef HP_MODE
   logic                                v_ff;
   logic [7:0] 				din_ff;
   logic [7:0] 				dout_int;   
   logic [7:0] 				scrambled_out;
   logic [23:0] 		        curr_key;      
   logic [23:0] 			curr_key_rot ;

   	   

   assign dout_int[`PERM_0] = scrambled_out [0];
   assign dout_int[`PERM_1] = scrambled_out [1];
   assign dout_int[`PERM_2] = scrambled_out [2];
   assign dout_int[`PERM_3] = scrambled_out [3];
   assign dout_int[`PERM_4] = scrambled_out  [4];
   assign dout_int[`PERM_5] = scrambled_out  [5];
   assign dout_int[`PERM_6] = scrambled_out  [6];
   assign dout_int[`PERM_7] = scrambled_out  [7];   


  always_ff @(posedge clk , negedge rst) begin : seq_logic
     if(rst == 1'b0) begin
       din_ff <= '0;
        dout <= '0;
        v_ff <= 1'b0;
        v <= 1'b0;

	curr_key <= {`XOR_KEY2 , `XOR_KEY3 , `XOR_KEY1};		

     end     
     else begin  if( en == 1'b1) begin
       din_ff <= din;
        v_ff <= 1'b1;
	curr_key <= curr_key_rot;
     end
     else begin
//	dout <= '0; save logic, if valid not asserted data shouldnt matter...
	v_ff <= 1'b0;	
	end     
        v <= v_ff;
	dout <= dout_int;
     end
  end // block: seq_logic

   always_comb begin: xor_stage
     scrambled_out = din_ff ^ curr_key[15:8];
   end
   
   //Rotate key every clock cycle 8 bits if cycle frequency is set to 1
   always_comb begin : auto_shifter
      curr_key_rot = {curr_key[15:8] , curr_key[7:0] , curr_key[23:16]};
   end

`else // CODE FOR CONFIGURABLE MODE STARTS HERE

   //Pipe instance
   decrypt_pipe decrypt_pipe_i (
				.clk(clk),
				.rst(rst),
				.en(en),
				.k1(k1),
				.k2(k2),
				.k3(k3),
				.rot_freq(rot_freq),
				.shift_en(shift_en),
				.shift_amt(shift_amt),
				.mode(mode),
				.v(v),
				.dout(dout));
   
   
`endif // !`ifdef HP_MODE
        
endmodule// encrypt_unit
`endif //  `ifndef DECRYPT_UNIT

