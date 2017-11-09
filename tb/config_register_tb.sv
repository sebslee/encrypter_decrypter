/////////////////////////////////////////////////////////////////////
// Design unit: config_register_tb
//            :
// File name  : config_register_tb.sv
//            :
// Description: Simple test bench for config register.
// Validating results initially visually... 
// Limitations: None
//            : 
// System     : SystemVerilog IEEE 1800-2005
//            :
// Revision   : Version 1.0 11/17
// Engineer   : Sebastian Lee (sbslee@gmail.com)
///////////////////////////////////////////////////////////////////

`include "../src/config_register.sv"

module config_register_tb();

   logic clk , rst , wen;
   logic [31:0] data_in , data_out;

   config_register config_register_i(.*);
   

   initial begin: clk_gen
      clk = 1'b0;
      forever #10 clk = ~clk;
   end
   

   initial begin : stimuli
      rst = 1'b1;
      #5 rst = 1'b0;
      #6 rst = 1'b1;
      $display ("Coming out of reset, default mode should be config performing data write..");
      @(posedge clk) ;
      #1 wen = 1'b1;
      #1 data_in = 32'hCAFECAF0;
      @(posedge clk);
      $display("Going into operation mode..");
      @(posedge clk) ;
      #1 wen = 1'b1;
      #1 data_in = 32'hCAFECAF1;
      @(posedge clk);
      #1 assert (data_out == 32'hCAFECAF1);      
      $display ("Trying to write on operation mode");
      @(posedge clk) ;
      #1 wen = 1'b1;
      #1 data_in = 32'hCAFECAFF;
      @(posedge clk);
      #1 assert (data_out == 32'hCAFECAF1);  
      $display ("Going to config again");
      @(posedge clk) ;
      #1 wen = 1'b1;
      #1 data_in = 32'h00000000;
      @(posedge clk);
      $display ("Writing on config mode");
      @(posedge clk) ;
      #1 wen = 1'b1;
      #1 data_in = 32'hFACEFAC1;
      @(posedge clk);
      #1 assert (data_out == 32'hFACEFAC1);  
      $display("Test finished..");      
      #10 $finish;                      
   end // block: stimuli   
   
endmodule // config_register_tb


