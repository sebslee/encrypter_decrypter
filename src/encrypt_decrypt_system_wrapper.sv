/////////////////////////////////////////////////////////////////////
// Design unit: encrypt_decrypt_system_wrapper
//            :
// File name  : encrypt_decrypt_system_wrapper.sv
//            :
// Description: Top level wrapper for encryption decryption system
//            :
// Limitations: None
//            : 
// System     : SystemVerilog IEEE 1800-2005
//            :
// Revision   : Version 1.0 11/17
// Engineer   : Sebastian Lee (sbslee@gmail.com)
////////////////////////////////////////////////////////////////////

`include "encrypt_unit.sv"
`include "decrypt_unit.sv"
`include "config_register.sv"

`ifndef TOP_WRAPPER
`define TOP_WRAPPER

module encrypt_decrypt_system_wrapper (

  input logic 	     clk,
  input logic 	     enable,
  input logic [7:0]  data_in_encrypt,
  input logic 	     rst,
`ifndef HP_MODE
				       input logic cfg_wen,
				       input logic [63:0] cfg_data_in,
`endif				       				       
  output logic 	     decrypt_valid_out, 
  output logic [7:0] decrypted_data,
  output logic [7:0] encrypted_data,
  output logic 	     encrypted_data_valid				       				      
);


  logic encrypt_valid_out;
  logic [7:0] encrypt_data_out;
   


  assign encrypted_data_valid = encrypt_valid_out;
  assign encrypted_data = encrypt_data_out;


`ifndef HP_MODE
   
   logic [63:0] cfg_data_out;
   logic [7:0] 	 k1 , k2 , k3;
   logic [2:0] 	 rot_freq;
   logic 	 shift_en;
   logic [2:0] 	 shift_amt;
   logic 	 mode;
   logic [2:0] perm0, perm1 , perm2 , perm3 , perm4 , perm5 , perm6 , perm7;
   	   
   assign k1 = cfg_data_out[31:24];
   assign k2 = cfg_data_out [23:16];
   assign k3 = cfg_data_out [15:8];
   assign shift_en = cfg_data_out [7];   
   assign rot_freq = cfg_data_out [6:4];
   assign shift_amt = cfg_data_out [3:1];   
   assign mode = cfg_data_out[0];
   assign perm0 = cfg_data_out [34:32];
assign perm1 = cfg_data_out [37:35];
assign perm2 = cfg_data_out [40:38];
assign perm3 = cfg_data_out [43:41];
assign perm4 = cfg_data_out [46:44];
assign perm5 = cfg_data_out [49:47];
   assign perm6 = cfg_data_out [52:50];
   assign perm7 = cfg_data_out [55:53];
   
   config_register config_register_i (.clk(clk) , .rst(rst) , .wen(cfg_wen) , .data_in(cfg_data_in) , .data_out(cfg_data_out));
 
`endif
 
  encrypt_unit encrypt_unit_i (
`ifndef HP_MODE
			       .k1(k1),
			       .k2(k2),
			       .k3(k3),
			       .rot_freq(rot_freq),
			       .shift_en(shift_en),
			       .mode(mode),
			       .shift_amt(shift_amt),	
			       .perm0(perm0),
			       .perm1(perm1),
			       .perm2(perm2),
			       .perm3(perm3),
			       .perm4(perm4),
			       .perm5(perm5),
			       .perm6(perm6),
			       .perm7(perm7),
`endif
			       
 .clk (clk) , .rst (rst) , .v(encrypt_valid_out) , 
.en(enable) , .din(data_in_encrypt) , .dout(encrypt_data_out));

  decrypt_unit decrypt_unit_i (
`ifndef HP_MODE
			       .k1(k1),
			       .k2(k2),
			       .k3(k3),
			       .rot_freq(rot_freq),
			       .shift_en(shift_en),
			       .mode(mode),
			       .shift_amt(shift_amt),
		       .perm0(perm0),
			       .perm1(perm1),
			       .perm2(perm2),
			       .perm3(perm3),
			       .perm4(perm4),
			       .perm5(perm5),
			       .perm6(perm6),
			       .perm7(perm7),			       
`endif
			       
 .clk(clk) , .rst(rst) , .v(decrypt_valid_out) , .en (encrypt_valid_out) , .din(encrypt_data_out) , .dout(decrypted_data));

endmodule

`endif  
  
  
  
   
