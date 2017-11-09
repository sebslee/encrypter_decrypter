/////////////////////////////////////////////////////////////////////
// Design unit: shift_dc_unit_test
//            :
// File name  : encrypt_pipe_shift_dc.sv
//            :
// Description: Decrypt unit test. Basic.
//            :
// Limitations: None
//            : 
// System     : SystemVerilog IEEE 1800-2005
//            :
// Revision   : Version 1.0 11/17
// Engineer   : Sebastian Lee (sbslee@gmail.com)
////////////////////////////////////////////////////////////////////


module decrypt_unit_tb();

			      logic 	  clk;
			      logic 	  rst;
			      logic 	  en;
			      logic [7:0]   din;
			      logic [7:0]   k1 , k2 , k3;
logic [2:0]   rot_freq;
logic 	  shift_en;
 logic 	 [3:0] shift_amt;
logic 	  mode;
logic     en_out;
logic 	  is_alpha_upper_case_out , is_alpha_low_case_out;
logic [31:0] extended_shift_data_out;
logic [7:0] scramble_to_xor;
logic [7:0] k1_xor , k2_xor , k3_xor;
logic [2:0] rot_xor;
logic mode_xor , en_xor;
logic v;
logic [7:0] encyrpted_data;

decrypt_pipe decrypt_pipe_i (.clk(clk) , .rst(rst) , .k1(k1) ,.k2(k2) ,.k3(k3) , .shift_en(shift_en) , .shift_amt(shift_amt) , .rot_freq(rot_freq) , .din(din) , .mode(mode) , .v(v) , .dout(encrypted_data) , .en(en));



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
din = 8'hD3;
en = 1'b1;
shift_amt = 4'b0001;
rot_freq = '0;
k1 = 8'h11;
k2 = 8'hFF;
k3 = 8'hDE;
repeat (2) @(posedge clk);
#5 rst = 1'b1;

//repeat (30) @(posedge clk) din = din + 1 ;
repeat(5) @(posedge clk);
//@(posedge clk) din = 8'h61;
//repeat (30) @(posedge clk) din = din + 1 ;

# 20 $finish();
end

endmodule



