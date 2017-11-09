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
				       input logic [31:0] cfg_data_in,
`endif				       				       
  output logic 	     decrypt_valid_out, 
  output logic [7:0] decrypted_data,
  output logic [7:0] encrypted_data,
  output logic 	     encrypted_data_valid				       				      
);


  wire encrypt_valid_out;
  wire [7:0] encrypt_data_out;
   


  assign encrypted_data_valid = encrypt_valid_out;
  assign encrypted_data = encrypt_data_out;


`ifndef HP_MODE
   
   wire [31:0] cfg_data_out;
   wire [7:0] 	 k1 , k2 , k3;
   wire [2:0] 	 rot_freq;
   wire 	 shift_en;
   wire [2:0] 	 shift_amt;
   wire 	 mode;
   	   
   assign k1 = cfg_data_out[31:24];
   assign k2 = cfg_data_out [23:16];
   assign k3 = cfg_data_out [15:8];
   assign shift_en = cfg_data_out [7];   
   assign rot_freq = cfg_data_out [6:4];
   assign shift_amt = cfg_data_out [3:1];   
   assign mode = cfg_data_out[0];
	   
   config_register config_register_i (.clk(clk) , .rst(rst) , .wen(config_reg_wen) , .data_in(cfg_data_in) , .data_out(cfg_data_out));
 
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
`endif
			       
 .clk(clk) , .rst(rst) , .v(decrypt_valid_out) , .en (encrypt_valid_out) , .din(encrypt_data_out) , .dout(decrypted_data));

endmodule

`endif  
  
  
  
   
