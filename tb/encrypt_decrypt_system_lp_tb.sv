/////////////////////////////////////////////////////////////////////
// Design unit: encrypt_decrypt_system_hp_tb
//            :
// File name  : encrypt_decrypt_system_hp_tb.sv
//            :
// Description: Test bench for low performance (configurable) mode of encrypt decrypt system. 
//            :
// Limitations: None
//            : 
// System     : SystemVerilog IEEE 1800-2005
//            :
// Revision   : Version 1.0 11/17
// Engineer   : Sebastian Lee (sbslee@gmail.com)
////////////////////////////////////////////////////////////////////

//`include "../include/encrypt_config.svh"
`include "/home/sl9n17/project/encrypter_decrypter/synth_lp/netlist/encrypt_decrypt_system_wrapper_netlist.v"

`define CLK_PERIOD 10
`timescale 1ns / 1ps
import encrypt_config::*;

module encrypt_decrypt_system_lp_tb();

  logic clk, enable , rst , decrypt_valid_out , encrypted_data_valid;
  logic [7:0] data_in_encrypt ,encrypted_data , decrypted_data; 
  event data_trans , scoreboard_check; // signal data transaction to scoreboard...
  int unsigned err_count;
  integer DATA_IN , DATA_OUT , DATA_ENCRYPT;
   logic cfg_wen;
   logic [31:0] cfg_data_in;
int cnt_data_sent, cnt_data_received , cnt_data_encrypted;
 
covergroup config_cg @ (posedge cfg_wen);
shift_en : coverpoint cfg_data_in {
bins enabled = {1};
bins disabled = {1};
}
endgroup
 
  encrypt_decrypt_system_wrapper uut (.*);

  
  initial begin
  cnt_data_sent = 0;
  cnt_data_received = 0;
  cnt_data_encrypted =0;

  DATA_IN = $fopen("/home/sl9n17/project/encrypter_decrypter/data_sent.log", "w");
  DATA_OUT = $fopen("/home/sl9n17/project/encrypter_decrypter/data_received.log" , "w");
   DATA_ENCRYPT = $fopen("/home/sl9n17/project/encrypter_decrypter/data_encrypt.log" , "w");
  if (!DATA_IN)
    $display("Could not open LOG");
    
  else begin
    $display("File log opened succesfully! Test results being stored on resuls/data_sent.log");
    $fwrite(DATA_IN , "DATA SENT TRACKER\n");
    $fwrite (DATA_OUT , "DATA OUT TRACKER\n");
   $fwrite (DATA_ENCRYPT , "DATA ENCRYPTTED TRACKER\n");
    $fwrite (DATA_IN , "\t time\tcnt\tdata\n");
    $fwrite (DATA_OUT , "\t time\tcnt\tdata\n");
        $fwrite (DATA_ENCRYPT , "\t time\tcnt\tdata\n");
  end

end

   initial begin
      clk = 1'b0;
      forever #(`CLK_PERIOD/2) clk = ~clk;      
   end

   initial begin
      enable = 1'b0;
      rst = 1'b1;
      #((`CLK_PERIOD/2) * 3) $display("Asserting reset ..");  rst = 1'b0;
      //#1 assert (v == 1'b0) else begin $error ("@ %d Valid asserted while on reset!", $time); err_count++; end 
      #((`CLK_PERIOD/2) * 3) $display ("De-asserting reset"); rst = 1'b1;
      #1 cfg_wen = 1'b1;
      $display("Configuring system ..");
      cfg_data_in [31:24] = 8'hFA;
      cfg_data_in [23:16] = 8'hAF;
      cfg_data_in [15:8] = 8'hBA;
      cfg_data_in [7] = 1'b1;
      cfg_data_in [6:4] = 3'b111;
      cfg_data_in [3:1] = 3'b011;
      cfg_data_in [0] = 1'b1;
      @(posedge clk);
      #1;
      $display("Entering operation mode!");
      
      repeat(100) begin
       
      @(posedge clk) #1 data_in_encrypt = $urandom_range(256,0); enable = 1'b1;
      //#1 -> data_trans;
      end
      #1 enable =1'b0;
      repeat (7) @(posedge clk);
      $fclose(DATA_IN);
      $fclose(DATA_OUT);
      #3 $finish();
   end

//Capture data transaction
   always @(posedge clk) begin
     if(enable == 1'b1 && rst == 1'b1) begin
     $display ("Data transaction! Data sent %h " , data_in_encrypt );
     $fwrite (DATA_IN , "%d\t%d\t%h\n" ,$time(), cnt_data_sent, data_in_encrypt);
     cnt_data_sent = cnt_data_sent + 1;
     //->scoreboard_check;     
     end    
   end

   //Scoreboarding
   always @(scoreboard_check) begin
    
always @ (posedge clk) begin
if(enable == 1'b1 && encrypted_data_valid == 1'b1) begin
   $fwrite (DATA_ENCRYPT , "%d\t%d \t\t%h\n" ,$time(), cnt_data_encrypted, encrypted_data);
   cnt_data_encrypted = cnt_data_encrypted +1;
end
end
     #0 scoreboard_data_in = data_in_encrypt;
     repeat(5) @(posedge clk);    
     //wait for 3 clock cycles and check valid signal, data must be the one we sent orignally...
   always @(posedge clk) begin
   if(decrypt_valid_out == 1'b1) begin
   $fwrite (DATA_OUT , "%d\t%d\t%h\n" ,$time(), cnt_data_received, decrypted_data);
   cnt_data_received = cnt_data_received +1;
end
     #2;
   end
     #1 assert (scoreboard_data_in == decrypted_data ) else begin
     err_count++;
     $error("@ %d ERROR: Expected data = %h Actual data = %h ", $time(), scoreboard_data_in , decrypted_data);
     end
     $display ("@ %d Scoreboard check completed!  Expected data = %h Actual data = %h ", $time(), scoreboard_data_in , decrypted_data);
   end


endmodule
  
