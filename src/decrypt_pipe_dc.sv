/////////////////////////////////////////////////////////////////////
// Design unit: ecnrypt_pipe_shift_dc
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

module decrypt_pipe_dc (
			      input logic 	  clk,
			      input logic 	  rst,
			      input logic 	  en,
			      input logic [7:0]   din,
			      input logic [7:0]   k1 , k2 , k3,
			      input logic [2:0]   rot_freq,
			      input logic 	  shift_en,
			      input logic [2:0]	  shift_amt,
			      input logic 	  mode,
			      //PIPE OUTPUTS
			      output logic        en_out,
			      output logic 	  is_alpha_upper_case_out , is_alpha_low_case_out,
			      output logic [31:0] extended_shift_data_out);

   logic [31:0] extended_shift_data; //for 1 clock cycle rotation
   logic 	is_alpha_upper_case , is_alpha_low_case;

   // flop data out ...
   always_ff @ (posedge clk, negedge rst) begin : seq_logic
      if(rst == 1'b0) begin
	 en_out <= '0;
	 is_alpha_upper_case_out <= '0;
	 is_alpha_low_case_out <= '0;
	 extended_shift_data_out <= '0;
      end // if (rst == 1'b0)      
      else begin	
	 en_out <= en;
	 is_alpha_upper_case_out <= is_alpha_upper_case;
	 is_alpha_low_case_out <= is_alpha_low_case;
	 extended_shift_data_out <= extended_shift_data;
      end // else: !if(rst == 1'b0)
   end // block: seq_logic   		 	 

   always_comb begin : shift_data_compare // 1st pipe stage
      //defaults to avoid latches ..
      is_alpha_upper_case = 1'b0;
      is_alpha_low_case = 1'b0;
      extended_shift_data = '0;      
      if(mode == 1'b1 && en == 1'b1 ) begin
	 if(shift_en == 1'b1) begin
	 //Compare incoming data with boundaries of ascii alphabetic characters ...
	 if(din > 64 && din < 91)begin
	    is_alpha_upper_case = 1'b1;	    
	 end
	 else if (din > 96 && din < 123) begin
	    is_alpha_low_case = 1'b1;
	 end
	 extended_shift_data[31:25] = '0;	 
         case (din)
	   //Upper case ..
	   65: extended_shift_data[31:6] = 26'b1 << 0;
	   66: extended_shift_data[31:6] = 26'b1 << 1;
	   67: extended_shift_data[31:6] = 26'b1 << 2;
	   68: extended_shift_data[31:6] = 26'b1 << 3;
	   69: extended_shift_data[31:6] = 26'b1 << 4;
	   70: extended_shift_data[31:6] = 26'b1 << 5;
	   71: extended_shift_data[31:6] = 26'b1 << 6;
	   72: extended_shift_data[31:6] = 26'b1 << 7;
	   73: extended_shift_data[31:6] = 26'b1 << 8;
	   74: extended_shift_data[31:6] = 26'b1 << 9;
	   75: extended_shift_data[31:6] = 26'b1 << 10;
	   76: extended_shift_data[31:6] = 26'b1 << 11;
	   77: extended_shift_data[31:6] = 26'b1 << 12;
	   78: extended_shift_data[31:6] = 26'b1 << 13;
	   79: extended_shift_data[31:6] = 26'b1 << 14;
	   80: extended_shift_data[31:6] = 26'b1 << 15;
	   81: extended_shift_data[31:6] = 26'b1 << 16;
	   82: extended_shift_data[31:6] = 26'b1 << 17;
	   83: extended_shift_data[31:6] = 26'b1 << 18;
	   84: extended_shift_data[31:6] = 26'b1 << 19;
	   85: extended_shift_data[31:6] = 26'b1 << 20;
	   86: extended_shift_data[31:6] = 26'b1 << 21;
	   87: extended_shift_data[31:6] = 26'b1 << 22;
	   88: extended_shift_data[31:6] = 26'b1 << 23;
	   89: extended_shift_data[31:6] = 26'b1 << 24;
	   90: extended_shift_data[31:6] = 26'b1 << 25;
	   //low case
           97: extended_shift_data[31:6] = 26'b1 << 0;
           98: extended_shift_data[31:6] = 26'b1 << 1;
           99: extended_shift_data[31:6] = 26'b1 << 2;
           100: extended_shift_data[31:6] = 26'b1 << 3;
           101: extended_shift_data[31:6] = 26'b1 << 4;
           102: extended_shift_data[31:6] = 26'b1 << 5;
           103: extended_shift_data[31:6] = 26'b1 << 6;
           104: extended_shift_data[31:6] = 26'b1 << 7;
           105: extended_shift_data[31:6] = 26'b1 << 8;
           106: extended_shift_data[31:6] = 26'b1 << 9;
           107: extended_shift_data[31:6] = 26'b1 << 10;
           108: extended_shift_data[31:6] = 26'b1 << 11;
           109: extended_shift_data[31:6] = 26'b1 << 12;
           110: extended_shift_data[31:6] = 26'b1 << 13;
           111: extended_shift_data[31:6] = 26'b1 << 14;
           112: extended_shift_data[31:6] = 26'b1 << 15;
           113: extended_shift_data[31:6] = 26'b1 << 16;
           114: extended_shift_data[31:6] = 26'b1 << 17;
           115: extended_shift_data[31:6] = 26'b1 << 18;
           116: extended_shift_data[31:6] = 26'b1 << 19;
           117: extended_shift_data[31:6] = 26'b1 << 20;
           118: extended_shift_data[31:6] = 26'b1 << 21;
           119: extended_shift_data[31:6] = 26'b1 << 22;
           120: extended_shift_data[31:6] = 26'b1 << 23;
           121: extended_shift_data[31:6] = 26'b1 << 24;
           122: extended_shift_data[31:6] = 26'b1 << 25;	   
	   default :  extended_shift_data [25:0] = { {12{1'b0}} , din};  
	 endcase // case (din)
	 end // if (shift_en == 1'b1)
         else begin
	 extended_shift_data [31:8] = '0;
	 extended_shift_data [7:0] = din;	
         end 
      end // if (mode == 1'b1 )
   end // block: shift_data_compare
   
endmodule // encrypt_pipe_shift_dc
