/////////////////////////////////////////////////////////////////////
// Design unit: defines
//            :
// File name  : encrypt_config.svh
//            :
// Description: Constants for non-config operation mode
//            :
// Limitations: None
//            : 
// System     : SystemVerilog IEEE 1800-2005
//            :
// Revision   : Version 1.0 11/17
// Engineer   : Sebastian Lee (sbslee@gmail.com)
////////////////////////////////////////////////////////////////////

`ifndef ENCRYPT_CONFIG
`define ENCRYPT_CONFIG

package encrypt_config;

//`define HP_MODE
`define PERM_0 0
`define PERM_1 1
`define PERM_2 2
`define PERM_3 5
`define PERM_4 6
`define PERM_5 7
`define PERM_6 3
`define PERM_7 4

`define XOR_KEY1 8'h67
`define XOR_KEY2 8'd167
`define XOR_KEY3 8'd221

`define CLK_PERIOD 2.9   

endpackage // encrypt_config
   
   
`endif 
