/////////////////////////////////////////////////////////////////////
// Design unit: decrypt_unit_basic_tb.sv
//            :
// File name  : decrypt_unit_basic_tb.sv
//            :
// Description: Basic test for decryption module. Standalone verirication, no configuration enable, no shifter stage enabled. 
//            :
// Limitations: None
//            : 
// System     : SystemVerilog IEEE 1800-2005
//            :
// Revision   : Version 1.0 11/17
// Engineer   : Sebastian Lee (sbslee@gmail.com)
////////////////////////////////////////////////////////////////////

//`include "../src/encrypt_unit.sv"
`include "../include/encrypt_config.svh"
`include "../include/test_package.svh"

import encrypt_config::*;
import test_utils::*;

`timescale 1ns / 1ps

module decrypt_unit_basic_tb ();
  // `define CLK_PERIOD 10
   logic clk , rst  , en , v ;
   logic [7:0] din , dout;
   logic [7:0] curr_xor_key;
   logic [7:0] decrypt_data;
   event data_trans , scoreboard_check;
   logic [1:0] count;
   logic [7:0] expected_data;
   int err_count;

   initial begin
      clk = 1'b0;
      forever #(`CLK_PERIOD/2) clk = ~clk;      
   end

   decrypt_unit dut (.*);

   assign din = decrypt_data;

   initial begin // main test

      count = 0; //for key rot...
      err_count = 0;
      curr_xor_key = `XOR_KEY1;
      rst = 1'b1;
      en = 1'b0;
      
      #((`CLK_PERIOD/2) * 3) $display("Asserting reset ..");  rst = 1'b0;
      #1 assert (v == 1'b0) else begin $error ("@ %d Valid asserted while on reset!", $time); err_count++; end 
      #((`CLK_PERIOD/2) * 3) $display ("De-asserting reset"); rst = 1'b1;
        
      $display ("Enable asserted ...");  
      repeat (100) begin   
      @(posedge clk) begin 
          en = 1'b1; 
          decrypt_data <= $urandom_range(256,0);
          #1-> data_trans;
      end
      end
      // take out enable on the fly , after two clock cycles valid should be de-asserted and remain like that
      $display ("De-asserting enable");
      @(posedge clk) #1 en = 1'b0;
      @(posedge clk);
      @(posedge clk);
      #1 assert(v == 1'b0) else begin
        $error("@ %d ERROR: Valid asserted after two clock cycles of deasserting enable, valid shoud not be asserted!!", $time);
        err_count++;
      end
      //Send another stream of data
      repeat (100) begin   
      @(posedge clk) begin 
          en = 1'b1; 
          decrypt_data <= $urandom_range(256,0);
          #1-> data_trans;
      end
      end      
      #(`CLK_PERIOD * 10) 
      if(err_count == 0)
      $display("Simulation finished succesfully no errors found!!!");
      else
      $display("Test failed. %d errors were found!", err_count);
      #50 $finish();  
   
   end
   
//Capture data transaction
   always @(data_trans) begin
     case(count)
       0: curr_xor_key = `XOR_KEY1;
       1: curr_xor_key = `XOR_KEY2;
       2: curr_xor_key = `XOR_KEY3;
     endcase
     $display ("Data transaction! Data to decrypt %h Curr xor key %h" , decrypt_data , curr_xor_key);
     ->scoreboard_check;    
     if(count+1 < 3) 
     count++   ;  
     else
     count = 0;
     
   end

   //Scoreboarding
   always @(scoreboard_check) begin
     logic[7:0] scoreboard_data_in , xor_curr;
     #0 scoreboard_data_in = decrypt_data;
     #0 xor_curr = curr_xor_key;
     expected_data = test_utils::decrypt(decrypt_data , curr_xor_key);
     repeat(2) @(posedge clk);    
     //wait for 2 clock cycles and check valid signal...
     if(v == 1'b1)
     #1 assert (expected_data == dout) else begin
     err_count++;
     $display ("Data transaction failed on : Data %h Key %h", scoreboard_data_in , xor_curr);
     $error("ERROR: Expected data = %h Actual data = %h ", expected_data , dout);
     end
   end

endmodule // decrypt_unit_basic_tb
