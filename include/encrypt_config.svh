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


`define PERM_0 7
`define PERM_1 6
`define PERM_2 5
`define PERM_3 4
`define PERM_4 3
`define PERM_5 2
`define PERM_6 1
`define PERM_7 0

`define XOR_KEY1 8'hDE
`define XOR_KEY2 8'hAD
`define XOR_KEY3 8'hBE
`define CLK_PERIOD 10

endpackage // encrypt_config
   
   
`endif 
