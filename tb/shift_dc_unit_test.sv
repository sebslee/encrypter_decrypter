/////////////////////////////////////////////////////////////////////
// Design unit: shift_dc_unit_test
//            :
// File name  : encrypt_pipe_shift_dc.sv
//            :
// Description: Data compare stage. Signal generated if incoming data is alpha (upp and low case).
// A stream of 25 bits is generated, facilitating rotation in the next stage. 
//            :
// Limitations: None
//            : 
// System     : SystemVerilog IEEE 1800-2005
//            :
// Revision   : Version 1.0 11/17
// Engineer   : Sebastian Lee (sbslee@gmail.com)
////////////////////////////////////////////////////////////////////


module shift_dc_unit_test();

			      logic 	  clk;
			      logic 	  rst;
			      logic 	  en;
			      logic [7:0]   din;
			      logic [7:0]   k1 , k2 , k3;
logic [2:0]   rot_freq;
logic 	  shift_en;
 logic 	  shift_amt;
logic 	  mode;
 logic [7:0]  k1_out , k2_out , k3_out;
 logic [2:0]  rot_freq_out;
logic 	  shift_en_out;
logic 	  shift_amt_out;
logic 	  mode_out;
logic        en_out;
logic 	  is_alpha_upper_case_out , is_alpha_low_case_out;
logic [31:0] extended_shift_data_out;


encrypt_pipe_shift_dc uut(.*);


initial begin
clk = 1'b0;
forever #10 clk = ~clk;
end

initial begin
rst = 1'b1;
repeat(3) @(posedge clk);
#4 rst = 1'b0;

mode = 1'b1;
shift_en = 1'b1;
din = 8'h41;
en = 1'b1;

repeat (2) @(posedge clk);
#5 rst = 1'b1;

repeat (30) @(posedge clk) din = din + 1 ;

@(posedge clk) din = 8'h61;
repeat (30) @(posedge clk) din = din + 1 ;

# 20 $finish();
end

endmodule



