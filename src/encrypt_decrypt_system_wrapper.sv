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

module encrypt_decrypt_system_wrapper (

  input logic clk,
  input logic enable,
  input logic [7:0] data_in_encrypt,
  input logic rst,
  output logic decrypt_valid_out, 
  output logic [7:0] decrypted_data,
  output logic [7:0] encrypted_data,
  output logic encrypted_data_valid);


  wire encrypt_valid_out;
  wire [7:0] encrypt_data_out;

  assign encrypted_data_valid = encrypt_valid_out;
  assign encrypted_data = encrypt_data_out;
 
  encrypt_unit encrypt_unit_i (
 .clk (clk) , .rst (rst) , .v(encrypt_valid_out) , .en(enable) , .din(data_in_encrypt) , .dout(encrypt_data_out));

  decrypt_unit decrypt_unit_i (
 .clk(clk) , .rst(rst) , .v(decrypt_valid_out) , .en (encrypt_valid_out) , .din(encrypt_data_out) , .dout(decrypted_data));

endmodule

  
  
  
  
   
