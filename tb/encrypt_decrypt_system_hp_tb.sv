/////////////////////////////////////////////////////////////////////
// Design unit: encrypt_unit_basic_tb.sv
//            :
// File name  : encrypt_unit_basic_tb.sv
//            :
// Description: Basic test for encryption module. Standalone verirication, no configuration enable, no shifter stage enabled. 
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
//`include "../include/test_package.svh"

import encrypt_config::*;
//import test_utils::*;

`timescale 1ns / 1ps

`define HP_MODE
`define CLK_PERIOD 3.7

module encrypt_decrypt_system_hp_tb ();


function logic [7:0] encrypt (input logic [7:0] data_in , input logic [7:0] key);
logic [7:0] data_enc;
data_enc [0] = data_in[`PERM_0];
data_enc [1] = data_in[`PERM_1];
data_enc [2] = data_in[`PERM_2];
data_enc [3] = data_in[`PERM_3];
data_enc [4] = data_in[`PERM_4];
data_enc [5] = data_in[`PERM_5];
data_enc [6] = data_in[`PERM_6];
data_enc [7] = data_in[`PERM_7];
data_enc = data_enc ^ key;
return data_enc;
endfunction


class transaction;
logic [7:0] data;
logic [7:0] xor_key;

function new (logic [7:0] data , logic [7:0] xor_key);
this.data = data;
this.xor_key = xor_key;
endfunction

function void print;
$display ("Transaction with data %h and key %h" , this.data , this.xor_key);
endfunction

endclass

/*
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
); */


   logic clk , rst  , enable , decrypt_valid_out , encrypted_data_valid;
   logic [7:0] data_in_encrypt , decrypted_data , encrypted_data;
   logic [7:0] curr_xor_key;
   //logic [7:0] encrypt_data;
   //event data_trans , scoreboard_check;
   logic [1:0] count;
   logic [7:0] expected_data;
   int err_count;
   logic [7:0] encrypt_data;
  
   mailbox data_to_encrypt; //encrypt checker queue
   mailbox received_data_encrypt; //
   mailbox data_to_decrypt; //to decrypt queue
   mailbox received_data_decrypt ; //compare data_to_decrypt with decrypted data should be the same...
  
   encrypt_decrypt_system_wrapper dut(.*);
   
  initial begin
      clk = 1'b0;
      forever #(`CLK_PERIOD/2) clk = ~clk;      
   end


   initial begin // main test

      count = 0; //for key rot...
      err_count = 0;
      curr_xor_key = `XOR_KEY1;
      rst = 1'b1;
      enable = 1'b0;
      data_to_encrypt = new;
      received_data_encrypt = new;
      data_to_decrypt = new;
      received_data_decrypt = new;

      #((`CLK_PERIOD/2) * 3) $display("Asserting reset ..");  rst = 1'b0;
      //#1 assert (v == 1'b0) else begin $error ("@ %d Valid asserted while on reset!", $time); err_count++; end 
      #((`CLK_PERIOD/2) * 3) $display ("@ %d De-asserting reset", $time()); rst = 1'b1;
        fork
          drive_data;
          monitor_data_encrypt;
          check_data_encrypt;
          monitor_data_decrypt;
          check_data_decrypt; 
        join_none
   end


task drive_data ;
      transaction tr_e ;
      logic [7:0] tr_d;
      wait (rst);
      
      repeat (500) begin   
      @(posedge clk) begin 
          enable = 1'b1; 
          data_in_encrypt <= $urandom_range(256,0);
          //#1-> data_trans;
     case(count)
       0: curr_xor_key = `XOR_KEY1;
       1: curr_xor_key = `XOR_KEY2;
       2: curr_xor_key = `XOR_KEY3;
     endcase

     //->scoreboard_check;    
     if(count+1 < 3) 
     count++   ;  
     else
     count = 0;
      end
      #1;
      tr_e = new(data_in_encrypt , curr_xor_key);
      tr_d = data_in_encrypt;
      //tr.print();
      //$display ("@ %d Data transaction! Data to encrypt %h Curr xor key %h" ,$time , encrypt_data , curr_xor_key);
      data_to_encrypt.put(tr_e);
      data_to_decrypt.put(tr_d);
      
      end

      //$stop();
      global_stop;
      //tr.data = encrytp_data;
      //tr.key = curr_xor_key;
endtask


task global_stop ;
$display("@ %d Data sent finished! Waiting for checkers to finish...", $time());
@(posedge clk);
@(posedge clk);
#200;
$display("Simulation finished!");
if(err_count == 0) 
$display ("No errors found SIMULATION PASSED");
else
$display ("%d Errors found SIMULATION FAILED" , err_count);
$stop();
endtask

task monitor_data_encrypt;
//logic [7:0] received_data;
forever begin 
@ (posedge clk) begin
if( encrypted_data_valid == 1'b1) begin
  #0 received_data_encrypt.put(encrypted_data);
end
end
end
endtask


task check_data_encrypt ;
transaction data_trans_e;
logic [7:0] rcv_data_e , expected_data_e;
forever begin
data_to_encrypt.get(data_trans_e);
//$display("@ %d Data transction got from qeue!" , $time());
//data_trans.print();
//Calculate expected data
expected_data_e = encrypt(data_trans_e.data , data_trans_e.xor_key);
received_data_encrypt.get(rcv_data_e);
$display ("@ %d ENCRYPT_CHECKER: Received data %h expected data %h" , $time() ,rcv_data_e , expected_data_e);
if(rcv_data_e != expected_data_e)begin
$display ("@ %d DATA MISSMATCH!!!!!", $time());
err_count = err_count + 1;
end
end
endtask;


task monitor_data_decrypt;
//logic [7:0] received_data;
forever begin 
@ (posedge clk) begin
if( decrypt_valid_out == 1'b1) begin
  #0 received_data_decrypt.put(decrypted_data);
end
end
end
endtask

task check_data_decrypt ;
transaction data_trans;
logic [7:0] rcv_data , expected_data;
forever begin
data_to_decrypt.get(expected_data);
//$display("@ %d Data transction got from qeue!" , $time());
//data_trans.print();
//Calculate expected data
//expected_data = encrypt(data_trans.data , data_trans.xor_key);
received_data_decrypt.get(rcv_data);
$display ("@ %d DECRYPT_CHECKER : Received data %h expected data %h" , $time() ,rcv_data , expected_data);
if(rcv_data != expected_data)begin
$display ("@ %d DATA MISSMATCH!!!!!", $time());
err_count = err_count + 1;
end
end
endtask;


endmodule






