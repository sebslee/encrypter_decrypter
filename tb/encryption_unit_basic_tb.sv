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
module encrypt_unit_basic_tb ();


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

  // `define CLK_PERIOD 10
   logic clk , rst  , en , v ;
   logic [7:0] din , dout;
   logic [7:0] curr_xor_key;
   logic [7:0] encrypt_data;
   event data_trans , scoreboard_check;
   logic [1:0] count;
   logic [7:0] expected_data;
   int err_count;

   mailbox data_transactions;
   mailbox received_data;

  initial begin
      clk = 1'b0;
      forever #(`CLK_PERIOD/2) clk = ~clk;      
   end

   encrypt_unit dut (.*);

   assign din = encrypt_data;

   initial begin // main test

      count = 0; //for key rot...
      err_count = 0;
      curr_xor_key = `XOR_KEY1;
      rst = 1'b1;
      en = 1'b0;
      data_transactions = new;
      received_data = new;
      #((`CLK_PERIOD/2) * 3) $display("Asserting reset ..");  rst = 1'b0;
      #1 assert (v == 1'b0) else begin $error ("@ %d Valid asserted while on reset!", $time); err_count++; end 
      #((`CLK_PERIOD/2) * 3) $display ("@ %d De-asserting reset", $time()); rst = 1'b1;
        fork
          drive_data;
          monitor_data;
          check_data;
        join_none
   end



task drive_data ;
      transaction tr;
      wait (rst);
      
      repeat (500) begin   
      @(posedge clk) begin 
          en = 1'b1; 
          encrypt_data <= $urandom_range(256,0);
          //#1-> data_trans;
     case(count)
       0: curr_xor_key = `XOR_KEY1;
       1: curr_xor_key = `XOR_KEY2;
       2: curr_xor_key = `XOR_KEY3;
     endcase

     ->scoreboard_check;    
     if(count+1 < 3) 
     count++   ;  
     else
     count = 0;
      end
      #1;
      tr = new(encrypt_data , curr_xor_key);
      //tr.print();
      $display ("@ %d Data transaction! Data to encrypt %h Curr xor key %h" ,$time , encrypt_data , curr_xor_key);
      data_transactions.put(tr);
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
#30;
$display("Simulation finished!");
if(err_count == 0) 
$display ("No errors found SIMULATION PASSED");
else
$display ("%d Errors found SIMULATION FAILED" , err_count);
$stop();
endtask

task monitor_data ;
//logic [7:0] received_data;
forever begin 
@ (posedge clk) begin
if( v == 1'b1) begin
  #0 received_data.put(dout);
end
end
end
endtask

task check_data ;
transaction data_trans;
logic [7:0] rcv_data , expected_data;
forever begin
data_transactions.get(data_trans);
$display("@ %d Data transction got from qeue!" , $time());
//data_trans.print();
//Calculate expected data
expected_data = encrypt(data_trans.data , data_trans.xor_key);
received_data.get(rcv_data);
$display ("@ %d Received data %h expected data %h" , $time() ,rcv_data , expected_data);
if(rcv_data != expected_data)begin
$display ("@ %d DATA MISSMATCH!!!!!", $time());
err_count = err_count + 1;
end
end
endtask;



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



endmodule // encrypt_unit_basic_tb

 
   
