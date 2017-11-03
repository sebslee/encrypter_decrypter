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

`include "../src/encryption_unit.sv"
`include "../include/encrypt_config.svh"
`timescale 1ns / 1ps

module encrypt_unit_basic_tb ();

   logic clk , rst , din , en , v ;
   logic [7:0] din , dout;

   initial begin
      clk = 1'b0;
      forever #`CLK_PERIOD clk = ~clk;      
   end

   encrypt_unit dut (.*);

   initial begin // main test
      rst = 1'b1;
      en = 1'b0;      
      #`CLK_PERIOD*3 rst = 1'b0;
      #`CLK_PERIOD*2 rst = 1'b1;
      //Put data on bus, nothing should happen...
      #`CLK_PERIOD*2 din = 8'hFA;
      #`CLK_PERIOD*1 en = 1'b1;
      #`CLK_PERIOD*3 $finish();  
   end
   

endmodule // encrypt_unit_basic_tb

   
   

   
