/////////////////////////////////////////////////////////////////////
// Design unit: encrypt_decrypt_system_hp_tb
//            :
// File name  : encrypt_decrypt_system_hp_tb.sv
//            :
// Description: Test bench for high performance mode of encrypt decrypt system. 
//            :
// Limitations: None
//            : 
// System     : SystemVerilog IEEE 1800-2005
//            :
// Revision   : Version 1.0 11/17
// Engineer   : Sebastian Lee (sbslee@gmail.com)
////////////////////////////////////////////////////////////////////
`timescale 1ns/1ps
`include "../include/encrypt_config.svh"
//`include "../src/encrypt_decrypt_system_wrapper.sv"

import encrypt_config::*;
`define HP_MODE 
module encrypt_decrypt_system_hp_tb();

  logic clk, enable , rst , decrypt_valid_out , encrypted_data_valid;
  logic [7:0] data_in_encrypt ,encrypted_data , decrypted_data; 
  event data_trans , scoreboard_check; // signal data transaction to scoreboard...
  int unsigned err_count;

  encrypt_decrypt_system_wrapper uut (.*);

   initial begin
      clk = 1'b0;
      forever #(`CLK_PERIOD/2) clk = ~clk;      
   end

   initial begin
      enable = 1'b0;
      rst = 1'b1;
      #((`CLK_PERIOD/2) * 3) $display("Asserting reset ..");  rst = 1'b0;
      //#1 assert (v == 1'b0) else begin $error ("@ %d Valid asserted while on reset!", $time); err_count++; end 
      #((`CLK_PERIOD/2) * 3) $display ("De-asserting reset"); rst = 1'b1;

      repeat(100) begin
       
      @(posedge clk) #1 data_in_encrypt = $urandom_range(256,0); enable = 1'b1;
      //#1 -> data_trans;
      end
      enable = 1'b0;
      $display ("Sending back to back vectors.. ");
      repeat(5) begin
      @(posedge clk) #1 data_in_encrypt = $urandom_range(256,0); enable = 1'b1;
      //#1 -> data_trans;
      end
      @(posedge clk) #1 data_in_encrypt = $urandom_range(256,0); enable = 1'b1;
      $display ("Applying reset in middle of transaction");
      #8 rst = 1'b0;
      $display ("Checking defaults");
      #1 assert ( encrypted_data_valid == 1'b0);
      #150 $finish();
   end

//Capture data transaction
   always @(posedge clk) begin
     if(enable == 1'b1 && rst == 1'b1) begin
     $display ("Data transaction! Data sent %h " , data_in_encrypt );
     ->scoreboard_check;     
     end    
   end

   //Scoreboarding
   always @(scoreboard_check) begin
     logic[7:0] scoreboard_data_in;
     #0 scoreboard_data_in = data_in_encrypt;
     repeat(3) @(posedge clk);    
     //wait for 3 clock cycles and check valid signal, data must be the one we sent orignally...
     #2;
     if(decrypt_valid_out == 1'b1)
     #1 assert (scoreboard_data_in == decrypted_data ) else begin
     err_count++;
     $error("@ %d ERROR: Expected data = %h Actual data = %h ", $time(), scoreboard_data_in , decrypted_data);
     end
   end

   final  begin
      if(err_count == 0)
        $display ("Simulation finished! No errors found , 100 vectors applied");
      else
        $display ("Simulation failed!! %d errors found ", err_count);
   end
endmodule
  
