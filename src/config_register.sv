/////////////////////////////////////////////////////////////////////
// Design unit: config_register
//            :
// File name  : config_register.sv
//            :
// Description: Configuration register. Mode set bit (0) has to be set to 0
//            : to enable register writing. Write only register (visible only to encrypt/decrypt unit. 
//              Defaults  : '0 (default mode is config mode)
// Limitations: None
//            : 
// System     : SystemVerilog IEEE 1800-2005
//            :
// Revision   : Version 1.0 11/17
// Engineer   : Sebastian Lee (sbslee@gmail.com)
///////////////////////////////////////////////////////////////////


`ifndef CONFIG_REG
 `define CONFIG_REG

module config_register(
		       input logic 	   clk,
		       input logic 	   rst,
		       input logic         wen,
		       input logic [63:0]  data_in,
		       output logic [63:0] data_out);

   always_ff @(posedge clk , negedge rst) begin
      if(rst == 1'b0) begin
	 data_out <= '0;
      end
      else begin
	 if((data_out[0] == 1'b0 || data_in[0] == 1'b0) && wen == 1'b1) begin
	    data_out <= data_in;	    
	 end	 
      end               
   end

endmodule // config_register

   
`endif
