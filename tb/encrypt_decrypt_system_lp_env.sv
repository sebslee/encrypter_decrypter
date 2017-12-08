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
//`include "../include/encrypt_config.svh"
//`include "../include/test_package.svh"

`define CLK_PERIOD 6

//import encrypt_config::*;
//import test_utils::*;

`timescale 1ns / 1ps

//`define HP_MODE


module encrypt_decrypt_system_lp_env ();

class configuration_t;
rand  bit [7:0] k1 , k2 , k3;
rand bit [2:0] rot_freq;
rand bit [2:0] perm0, perm1 , perm2 , perm3 , perm4 , perm5 , perm6 , perm7;
rand bit shift_en;
rand bit [2:0] 	 shift_amt;

function void print;
$display ("------------------------------Current configuration--------------------------------");
$display ("XOR Key 1 %h", k1);
$display ("XOR Key 2 %h", k2);
$display ("XOR Key 3 %h", k3);
$display ("Rotation frequency %h", rot_freq);
$display ("Shift enable %b", shift_en);
$display ("Shift ammount %d", shift_amt);
$display ("Permutation 7 %h",perm7);
$display ("Permutation 6 %h",perm6);
$display ("Permutation 5 %h",perm5);
$display ("Permutation 4 %h",perm4);
$display ("Permutation 3 %h",perm3);
$display ("Permutation 2 %h",perm2);
$display ("Permutation 1 %h",perm1);
$display ("Permutation 0 %h",perm0);
endfunction

constraint perm_mutex {
(perm0 != perm1)  && (perm0 != perm2) &&  (perm0 != perm3) && (perm0 != perm4) && (perm0 != perm5) && (perm0 != perm6) && (perm0 != perm7) && 
(perm1 != perm0)  && (perm1 != perm2) &&  (perm1 != perm3) && (perm1 != perm4) && (perm1 != perm5) && (perm1 != perm6) && (perm1 != perm7) &&
(perm2 != perm0)  && (perm2 != perm1) &&  (perm2 != perm3) && (perm2 != perm4) && (perm2 != perm5) && (perm2 != perm6) && (perm2 != perm7) &&
(perm3 != perm0)  && (perm3 != perm1) &&  (perm3 != perm2) && (perm3 != perm4) && (perm3 != perm5) && (perm3 != perm6) && (perm3 != perm7) &&
(perm4 != perm0)  && (perm4 != perm1) &&  (perm4 != perm2) && (perm4 != perm3) && (perm4 != perm5) && (perm4 != perm6) && (perm4 != perm7) &&
(perm5 != perm0)  && (perm5 != perm1) &&  (perm5 != perm2) && (perm5 != perm3) && (perm5 != perm4) && (perm5 != perm6) && (perm5 != perm7) &&
(perm6 != perm0)  && (perm6 != perm1) &&  (perm6 != perm2) && (perm6 != perm3) && (perm6 != perm5) && (perm6 != perm4) && (perm6 != perm7) &&
(perm7 != perm0)  && (perm7 != perm1) &&  (perm7 != perm2) && (perm7 != perm3) && (perm7 != perm5) && (perm7 != perm6) && (perm7 != perm4) ;

}


constraint shift_c {
shift_amt <= 6;
//shift_en == 1'b1;
}

endclass


class transaction;
logic [7:0] data;
configuration_t curr_config;

function new (logic [7:0] data , configuration_t curr_config);
this.data = data;
this.curr_config = curr_config;
endfunction


endclass



//MAIN TEST STARTS HERE

   logic clk , rst  , enable , decrypt_valid_out , encrypted_data_valid;
   logic [7:0] data_in_encrypt , decrypted_data , encrypted_data;
   logic [1:0] count;
   logic [7:0] expected_data;
   int err_count;
   logic [7:0] encrypt_data;   
   configuration_t active_config; //current configuration of the system ...
   logic cfg_wen;
   logic [63:0] cfg_data_in;
   mailbox data_to_encrypt; //encrypt checker queue
   mailbox received_data_encrypt; //
   mailbox data_to_decrypt; //to decrypt queue
   mailbox received_data_decrypt ; //compare data_to_decrypt with decrypted data should be the same...
   event done_with_data;
   event decrypt_checker_done;
   encrypt_decrypt_system_wrapper dut(.*);
   logic data_in_valid;

   /*covergroup config_cg @ (posedge dut.cfg_wen);
   shift_en : coverpoint dut.shift_en {
   bins enabled = {1};
   bins disabled = {0};
   }
    endgroup
   config_cg config_cg_i=new; */
  initial begin
      clk = 1'b0;
      forever #(`CLK_PERIOD/2) clk = ~clk;      
   end


   initial begin // main test
      
      count = 0; //for key rot...
      err_count = 0;
      rst = 1'b1;
      enable = 1'b0;
      data_to_encrypt = new;
      received_data_encrypt = new;
      data_to_decrypt = new;
      received_data_decrypt = new;
      #10;

      $display("ITERATION");
      $display("Asserting reset ..");  rst = 1'b0;
      //#1 assert (v == 1'b0) else begin $error ("@ %d Valid asserted while on reset!", $time); err_count++; end 
      #((`CLK_PERIOD/2) * 3) $display ("@ %d De-asserting reset", $time()); rst = 1'b1;
      #1;
       fork
          //drive_data;
          //monitor_data_encrypt;
          //check_data_encrypt;
          monitor_data_decrypt;
          check_data_decrypt; 
        join_none

      config_system;
      drive_data;
      wait(decrypt_checker_done);  
      $display ("Decrypt checker done!");
/*
repeat(2) begin
       $display("Asserting reset ..");  rst = 1'b0;
      //#1 assert (v == 1'b0) else begin $error ("@ %d Valid asserted while on reset!", $time); err_count++; end 
      #((`CLK_PERIOD/2) * 3) $display ("@ %d De-asserting reset", $time()); rst = 1'b1;
      #1;
      config_system;
      drive_data;
        //wait (done_with_data);
        //data_in_valid = 1'b0;
        $display ("@%d INFO : Waiting for checkers on current configuration to finish..." , $time());   
        wait(decrypt_checker_done);  
        $display ("@%d INFO : Checkers finished starting next iteration!" , $time()); 
         
   end*/
      global_stop;
end

task config_system;

logic [63:0] cfg_data;
$display ("Starting system configuration ...");

active_config = new();
assert(active_config.randomize());
cfg_wen = 1'b1;
cfg_data [63:56] = '0;

//$display ("Randomized configuration");
active_config.print();
cfg_data [34:32] = active_config.perm0;   
cfg_data [37:35] = active_config.perm1;
cfg_data [40:38] = active_config.perm2;
cfg_data [43:41] = active_config.perm3;
cfg_data [46:44] = active_config.perm4;
cfg_data [49:47] = active_config.perm5;
cfg_data [52:50] = active_config.perm6;
cfg_data [55:53] = active_config.perm7;
cfg_data [31:24] = active_config.k1;
cfg_data [23:16] = active_config.k2;
cfg_data [15:8] = active_config.k3;
cfg_data [7] = active_config.shift_en;
cfg_data [6:4] = active_config.rot_freq;
cfg_data [3:1] = active_config.shift_amt;
cfg_data [0] = 1'b1;
cfg_data_in = cfg_data;

@(posedge clk);
cfg_wen = 1'b0;

endtask


task drive_data ;
      transaction tr_e ;
      logic [7:0] tr_d;
      wait (rst);
      $display ("Driving data...");
      repeat (400) begin   
      @(posedge clk) begin 
#4;
      data_in_valid = 1'b1;
          enable = 1'b1; 
      
          data_in_encrypt <= $urandom_range(96,123);
      
      //tr_e = new(data_in_encrypt , curr_xor_key);
      tr_d = data_in_encrypt;
      //tr.print();
      //$display ("@ %d Data transaction! Data to encrypt %h Curr xor key %h" ,$time , encrypt_data , curr_xor_key);
      //data_to_encrypt.put(tr_e);
      data_to_decrypt.put(tr_d);
      
      end

      //$stop();
end
      enable = 1'b0;
      -> done_with_data;
      $display ("INFO: Done with data");
endtask


task global_stop ;
$display("@ %d Global stop called....", $time());
@(posedge clk);
@(posedge clk);
#200;
$display("Simulation finished!");
if(err_count == 0) 
$display ("No errors found SIMULATION PASSED");
else
$display ("%d Errors found SIMULATION FAILED" , err_count);
$finish();
endtask

task monitor_data_encrypt;
//logic [7:0] received_data;
forever begin 
@ (posedge clk) begin
if( encrypted_data_valid == 1'b1) begin
   //$display ("@ %d DEBUG Putting data %h", $time(), encrypted_data);
   #1 received_data_encrypt.put(encrypted_data);
end
end
end
endtask


/*task check_data_encrypt ;
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
*/

task monitor_data_decrypt;
//logic [7:0] received_data;
forever begin 
@ (posedge clk) begin
if( decrypt_valid_out == 1'b1) begin
  //$display ("@ %d DEBUG Putting data %h", $time(), encrypted_data);
  received_data_decrypt.put(decrypted_data);
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
//$display ("Number of pending elements .. %d" , data_to_decrypt.num());
if(data_to_decrypt.num() == 1)
-> decrypt_checker_done;
end
endtask;


endmodule






