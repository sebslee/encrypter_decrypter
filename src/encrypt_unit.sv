/////////////////////////////////////////////////////////////////////
// Design unit: encrypt_unit
//            :
// File name  : encrypt_unit.sv
//            :
// Description: Top module for encryption
//            :
// Limitations: None
//            : 
// System     : SystemVerilog IEEE 1800-2005
//            :
// Revision   : Version 1.0 11/17
// Engineer   : Sebastian Lee (sbslee@gmail.com)
////////////////////////////////////////////////////////////////////
`ifndef ENCRYPT_UNIT
`define ENCRYPT_UNIT
`include "../include/encrypt_config.svh"
import encrypt_config::*;

module encrypt_unit (
		     input logic 	clk,
		     input logic 	rst,
		     input logic [7:0] 	din,
		     input logic 	en,
`ifndef HP_MODE
		     input logic [7:0] 	k1 , k2 , k3,
		     input logic [2:0] 	rot_freq,
		     input logic 	shift_en,
		     input logic [2:0] 	shift_amt,
		     input logic mode,		     
`endif
		     
		     output logic [7:0] dout,
		     output logic 	v);
`ifdef HP_MODE
   
   logic                                v_ff;
   logic [7:0] 				din_ff;
   logic [7:0] 				dout_int;   
   wire [7:0] 				scrambled_in;
   logic [23:0] 			curr_key;      
   logic [23:0] 			curr_key_rot ;

   	   
   assign scrambled_in[0] = din_ff [`PERM_0];
   assign scrambled_in[1] = din_ff [`PERM_1];
   assign scrambled_in[2] = din_ff [`PERM_2];
   assign scrambled_in[3] = din_ff [`PERM_3];
   assign scrambled_in[4] = din_ff [`PERM_4];
   assign scrambled_in[5] = din_ff [`PERM_5];
   assign scrambled_in[6] = din_ff [`PERM_6];
   assign scrambled_in[7] = din_ff [`PERM_7];   


  always_ff @(posedge clk , negedge rst) begin : seq_logic
     if(rst == 1'b0) begin
       din_ff <= '0;
        dout <= '0;
        v_ff <= 1'b0;
        v <= 1'b0;
        //dout_int <= '0;        

	curr_key <= {`XOR_KEY2 , `XOR_KEY3 , `XOR_KEY1};		
	
     end     
     else begin if( en == 1'b1) begin
        din_ff <= din;
        v_ff <= 1'b1;
	curr_key <= curr_key_rot;
     end
     else begin
//	dout <= '0; save logic, if valid not asserted data shouldnt matter...
	v_ff <= 1'b0;	
	end     
        v <= v_ff;
	dout <= dout_int;
      end
  end // block: seq_logic

   always_comb begin: xor_stage

   
   //Rotate key every clock cycle 8 bits if cycle frequency is set to 1
   always_comb begin : auto_shifter
      curr_key_rot = {curr_key[15:8] , curr_key[7:0] , curr_key[23:16]};
   end
`else // !`ifdef HP_MODE // CODE FOR CONFIGURABLE MODE STARTS HERE
   logic [31:0] extended_shift_data; //for 1 clock cycle rotation
   logic 	is_alpha_upper_case , is_alpha_low_case;
   

   always_comb begin : shift_data_compare // 1st pipe stage
      //defaults to avoid latches ..
      is_alpha_upper_case = 1'b0;
      is_alpha_low_case = 1'b0;
      extended_shift_data = '0;      
      if(mode == 1'b1 ) begin
	 if(shift_en == 1'b1) begin
	 //Compare incoming data with boundaries of ascii alphabetic characters ...
	 if(din > 65 && din < 90)begin
	    is_alpha_upper_case = 1'b1;	    
	 end
	 else(din > 97 && din < 122) begin
	    is_alpha_low_case = 1'b1;
	 end
	 extended_shift_data[31:25] = '0;	 
         case (din)
	   //Upper case ..
	   65: extended_shift_data[24:0] = 25'b1 << 0;
	   66: extended_shift_data[24:0] = 25'b1 << 1;
	   67: extended_shift_data[24:0] = 25'b1 << 2;
	   68: extended_shift_data[24:0] = 25'b1 << 3;
	   69: extended_shift_data[24:0] = 25'b1 << 4;
	   70: extended_shift_data[24:0] = 25'b1 << 5;
	   71: extended_shift_data[24:0] = 25'b1 << 6;
	   72: extended_shift_data[24:0] = 25'b1 << 7;
	   73: extended_shift_data[24:0] = 25'b1 << 8;
	   74: extended_shift_data[24:0] = 25'b1 << 9;
	   75: extended_shift_data[24:0] = 25'b1 << 10;
	   76: extended_shift_data[24:0] = 25'b1 << 11;
	   77: extended_shift_data[24:0] = 25'b1 << 12;
	   78: extended_shift_data[24:0] = 25'b1 << 13;
	   79: extended_shift_data[24:0] = 25'b1 << 14;
	   80: extended_shift_data[24:0] = 25'b1 << 15;
	   81: extended_shift_data[24:0] = 25'b1 << 16;
	   82: extended_shift_data[24:0] = 25'b1 << 17;
	   83: extended_shift_data[24:0] = 25'b1 << 18;
	   84: extended_shift_data[24:0] = 25'b1 << 19;
	   85: extended_shift_data[24:0] = 25'b1 << 20;
	   86: extended_shift_data[24:0] = 25'b1 << 21;
	   87: extended_shift_data[24:0] = 25'b1 << 22;
	   88: extended_shift_data[24:0] = 25'b1 << 23;
	   89: extended_shift_data[24:0] = 25'b1 << 24;
	   90: extended_shift_data[24:0] = 25'b1 << 25;
	   //low case
           97: extended_shift_data[24:0] = 25'b1 << 0;
           98: extended_shift_data[24:0] = 25'b1 << 1;
           99: extended_shift_data[24:0] = 25'b1 << 2;
           100: extended_shift_data[24:0] = 25'b1 << 3;
           101: extended_shift_data[24:0] = 25'b1 << 4;
           102: extended_shift_data[24:0] = 25'b1 << 5;
           103: extended_shift_data[24:0] = 25'b1 << 6;
           104: extended_shift_data[24:0] = 25'b1 << 7;
           105: extended_shift_data[24:0] = 25'b1 << 8;
           106: extended_shift_data[24:0] = 25'b1 << 9;
           107: extended_shift_data[24:0] = 25'b1 << 10;
           108: extended_shift_data[24:0] = 25'b1 << 11;
           109: extended_shift_data[24:0] = 25'b1 << 12;
           110: extended_shift_data[24:0] = 25'b1 << 13;
           111: extended_shift_data[24:0] = 25'b1 << 14;
           112: extended_shift_data[24:0] = 25'b1 << 15;
           113: extended_shift_data[24:0] = 25'b1 << 16;
           114: extended_shift_data[24:0] = 25'b1 << 17;
           115: extended_shift_data[24:0] = 25'b1 << 18;
           116: extended_shift_data[24:0] = 25'b1 << 19;
           117: extended_shift_data[24:0] = 25'b1 << 20;
           118: extended_shift_data[24:0] = 25'b1 << 21;
           119: extended_shift_data[24:0] = 25'b1 << 22;
           120: extended_shift_data[24:0] = 25'b1 << 23;
           121: extended_shift_data[24:0] = 25'b1 << 24;
           122: extended_shift_data[24:0] = 25'b1 << 25;	   
	   default :  extended_shift_data [24:0] = {12{0} , din};  
	 endcase // case (din)
	 end // if (shift_en == 1'b1)
	 extended_shift_data [31:8] = '0;
	 extended_shift_data [7:0] = din;	 
      end // if (mode == 1'b1 )      
      end 
      
   end
   
   
`endif // !`ifdef HP_MODE
   

endmodule// encrypt_unit
`endif
   
      

   



  

   
   
   
   
     
   
   
		     
		     


