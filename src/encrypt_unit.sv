/////////////////////////////////////////////////////////////////////
// Design unit: encrypt_unit
//            :
// File name  : encrypt_unit.sv
//            :
// Description: Top module for encryption
//            :
// Limitations: None
//            : 
// System     : SystemVerilog IEEE 1800-2005
//            :
// Revision   : Version 1.0 11/17
// Engineer   : Sebastian Lee (sbslee@gmail.com)
////////////////////////////////////////////////////////////////////
`ifndef ENCRYPT_UNIT
`define ENCRYPT_UNIT
`include "../include/encrypt_config.svh"
import encrypt_config::*;

module encrypt_unit (
		     input logic 	clk,
		     input logic 	rst,
		     input logic [7:0] 	din,
		     input logic 	en,
`ifdef CONFIG_EN
		     input logic [7:0] 	k1 , k2 , k3,
		     input logic [2:0] 	rot_freq,
`endif
		     
		     output logic [7:0] dout,
		     output logic 	v);
   
   logic                                v_ff;
   logic [7:0] 				din_ff;
   logic [7:0] 				dout_int;   
   wire [7:0] 				scrambled_in;
   logic [23:0] 				curr_key;
   
`ifndef CONFIG_EN   
   logic [23:0] 			curr_key_rot ;
`endif
   	   
`ifndef CONFIG_EN
   assign scrambled_in[0] = din_ff [`PERM_0];
   assign scrambled_in[1] = din_ff [`PERM_1];
   assign scrambled_in[2] = din_ff [`PERM_2];
   assign scrambled_in[3] = din_ff [`PERM_3];
   assign scrambled_in[4] = din_ff [`PERM_4];
   assign scrambled_in[5] = din_ff [`PERM_5];
   assign scrambled_in[6] = din_ff [`PERM_6];
   assign scrambled_in[7] = din_ff [`PERM_7];   
`endif

  always_ff @(posedge clk , negedge rst) begin : seq_logic
     if(rst == 1'b0) begin
       din_ff <= '0;
        dout <= '0;
        v_ff <= 1'b0;
        v <= 1'b0;
        //dout_int <= '0;        
`ifndef CONFIG_EN
	curr_key <= {`XOR_KEY2 , `XOR_KEY3 , `XOR_KEY1};		
`endif	
     end     
     else begin if( en == 1'b1) begin
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
     dout_int = scrambled_in ^ curr_key[15:8];
   end
   
`ifndef CONFIG_EN
   //Rotate key every clock cycle 8 bits if cycle frequency is set to 1
   always_comb begin : auto_shifter
      curr_key_rot = {curr_key[15:8] , curr_key[7:0] , curr_key[23:16]};
   end
`endif

endmodule// encrypt_unit
`endif
   
      

   



  

   
   
   
   
     
   
   
		     
		     


