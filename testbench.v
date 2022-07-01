`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 01.07.2022 12:09:41
// Design Name: 
// Module Name: 
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


`timescale 1ns / 1ps


module ex_tb();

reg [7:0] in,instr;
reg clk,rst;
wire [7:0] Out;

wire [7:0] common_line;
wire in_sig,add_sig,mov_sig,out_sig;
wire read_en,write_en,load_a,load_b,sum_sig;
wire [2:0] source,dest;

ex dut(in,Out,instr,clk,rst, common_line, in_sig,add_sig,mov_sig,out_sig, read_en,write_en,load_a,load_b,sum_sig, source,dest);



initial
 begin
     rst=1'b1;
     instr=8'b00010000;
     in=8'b00000000;
     clk=1'b0;
     
     
     #10;
     rst=1'b0;
 
 end
 
 always #2.5 clk=~clk;

 
 // for input instruction is {00,Register code,xxx};
 // for addition instruction is {01,xxx,Register code};
 // for MOV instruction is {10,dest,source};
 // for OUT instriction is {11,xxx,Register code};
 
 initial
 begin
     #100;

     
     #5 instr=8'b00000000; // input A=20  
      in=20;
      
     #5 instr=8'b00001000; // input B=30
     in=30;
     
     #5 instr=8'b00010000; // input C=40
     in=40;
     
     #5 instr=8'b00011000; // input D=50
      in=50;
     
     #5 instr=8'b00100000; // input E=60
      in=60;
     
     #5 instr=8'b00101000; // input F=70
      in=70;
     
     #5 instr=8'b00110000; // input G=80
      in=80;
     
     #5 instr=8'b00111000; // input H=90
      in=90;
     
     #5 instr=8'b01000001; // ADD B to A, A=50
     #5 instr=8'b01000011;// ADD D to A, A=50+50=100
     
     #5 instr=8'b10001111; // Assign value of H reg to reg B, B=90
     
     #5 instr=8'b11001001; // output B 90
     
     #5 instr=8'b11001000; // output A 100
     #5 instr=8'b11001101; // output F 70
     #5 instr=8'b11001011; // output D 50
      
      
     #5 instr=8'b00000000; // input A=10
      in=10;
     #5 instr=8'b10001000; // Assign value of A reg to reg B, B=10
     #5 instr=8'b01000000; // ADD A to A, A=20
     #5 instr=8'b01000001; // ADD B to A, A=30
      
     #5 instr=8'b11001000; // output A 30 
     #5 instr=8'b01000000; // ADD A to A, A=60
      
     #5 instr=8'b01011000; // ADD A to A, A=120
     #5 instr=8'b11001000; // output A 120
      
      
      
      
      #10 $finish;
      
 end

endmodule
