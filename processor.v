`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 01.07.2022 12:08:14
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


module Tristate (in, output_enable, out);

    input   in, output_enable;
    output  out;
   
    bufif1  b1(out, in, output_enable);

endmodule

module TristateReg (in, oe, out);

    input  [7:0] in;
    input oe;
    output[7:0]  out;
    
    bufif1  b1(out[0], in[0], oe);
    bufif1  b2(out[1], in[1], oe);
    bufif1  b3(out[2], in[2], oe);
    bufif1  b4(out[3], in[3], oe);
    bufif1  b5(out[4], in[4], oe);
    bufif1  b6(out[5], in[5], oe);
    bufif1  b7(out[6], in[6], oe);
    bufif1  b8(out[7], in[7], oe);

endmodule

module decoder(in,out);                           // 3*8 decoder

input [2:0]in;

output [7:0]out;

assign out[0]=(~in[2])&(~in[1])&(~in[0]);
assign out[1]=(~in[2])&(~in[1])&(in[0]);
assign out[2]=(~in[2])&(in[1])&(~in[0]);
assign out[3]=(~in[2])&(in[1])&(in[0]);
assign out[4]=(in[2])&(~in[1])&(~in[0]);
assign out[5]=(in[2])&(~in[1])&(in[0]);
assign out[6]=(in[2])&(in[1])&(~in[0]);
assign out[7]=(in[2])&(in[1])&(in[0]);

endmodule

module dff(q,d,rst,clk,en);

input d,rst,clk,en;

output reg q;

always @(posedge(clk))
   begin
       if(en)
       begin
       if(rst) q <= 0;                          // Active high synchronous reset
       else q <= d;
       end
       
   end

endmodule

module dff_reg(q,d,rst,clk,en);                // 8-bit register using 8 d flip-flops
  input [7:0]d;
  input rst,clk,en;
  output [7:0]q;
  
  dff  d1(q[0],d[0],rst,clk,en);
  dff  d2(q[1],d[1],rst,clk,en);
  dff  d3(q[2],d[2],rst,clk,en);
  dff  d4(q[3],d[3],rst,clk,en);
  dff  d5(q[4],d[4],rst,clk,en);
  dff  d6(q[5],d[5],rst,clk,en);
  dff  d7(q[6],d[6],rst,clk,en);
  dff  d8(q[7],d[7],rst,clk,en);
  

endmodule

module fad(a,b,cin,sum,cout);
  input a,b,cin;
  output sum,cout;
  
  wire s1,c1,c2;
  xor(s1,a,b);
  and(c1,a,b);
  
  xor(sum,s1,cin);
  and(c2,s1,cin);
  or(cout,c2,c1);
  
  
endmodule

module fadd(a,b,cin,sum,cout);                    // 8-bit Adder

input [7:0] a,b;
input cin;
wire [7:0] a1;

output [7:0]sum;
output cout;

wire c1,c2,c3,c4,c5,c6,c7;

fad f1(a[0],b[0],1'b0,sum[0],c1);
fad f2(a[1],b[1],c1,sum[1],c2);
fad f3(a[2],b[2],c2,sum[2],c3);
fad f4(a[3],b[3],c3,sum[3],c4);
fad f5(a[4],b[4],c4,sum[4],c5);
fad f6(a[5],b[5],c5,sum[5],c6);
fad f7(a[6],b[6],c6,sum[6],c7);
fad f8(a[7],b[7],c7,sum[7],cout);




endmodule


module mux_8(out, a, b, s);                                // 8 2 to 1 Muxes

	input [7:0]a, b;
	input s;
	
	output [7:0]out;

    genvar p;
 
    generate for(p=0;p<8;p=p+1)
      begin 
      
       assign out[p]= (a[p]&(~s))|(b[p]&s);


      end
    endgenerate
	
	

endmodule

module accumulator(clk,rst,in,write,out,cout,load_a,load_b,sig,out_sig);

input clk,rst,write,load_a,load_b,sig,out_sig;
input [7:0] in; // input data bus

output [7:0] out;
output cout;

wire [7:0] adder_out,a_in,a_out,b_in,temp;

mux_8 M1(a_in,adder_out,in,load_a);                 // load_a =1'b1 means input of A is from bus

dff_reg D1(a_out,a_in,rst,clk,1'b1);

mux_8 M2(temp,in,a_out,load_b);                     // load_b=1 for ADD A

mux_8 M3(b_in,8'b0,temp,sig);

fadd F1(a_out,b_in,1'b0,adder_out,cout);


TristateReg  T(a_out, out_sig, out);

endmodule

module opcode_decoder(instr,source,dest,in_sig,out_sig,add_sig,mov_sig,
sum_sig,load_a,load_b,read_en,write_en);

input [7:0] instr;

output [2:0] source,dest;

output in_sig,out_sig,add_sig,mov_sig,sum_sig,load_a,load_b,read_en,write_en;

assign source=instr[2:0];
assign dest=instr[5:3];

and a1(in_sig,~instr[7],~instr[6]);
and a2(add_sig,~instr[7],instr[6]);
and a3(mov_sig,instr[7],~instr[6]);
and a4(out_sig,instr[7],instr[6]);

or O1(write_en,in_sig,mov_sig);
or O2(read_en,add_sig,mov_sig,out_sig);

wire a_present;
wire a_present2,temp1,temp2;

and a5(a_present,~instr[0],~instr[1],~instr[2]);
and a10(a_present2,~instr[3],~instr[4],~instr[5]);

and a6(temp1,in_sig,a_present2);
and a7(load_b,add_sig,a_present); // For ADD A

and a11(temp2,mov_sig,a_present2);

or O4(load_a,temp1,temp2);

wire n1,n2;

and a8(n1,mov_sig,a_present);
and a9(n2,out_sig,a_present);

or O3(sum_sig,n1,n2);


endmodule

module reg_fetch(in,out,read_en,write_en,clk,rst);

input [7:0] in;
output [7:0] out;

input clk,rst,read_en,write_en;

wire [7:0] b_in,b_out;

mux_8 M1(b_in,b_out,in,write_en);

dff_reg D(b_out,b_in,rst,clk,1'b1);

TristateReg T(b_out, read_en, out);

endmodule

module reg_data(in,out,source,dest,read_en,write_en,clk,rst);

input [7:0] in;
output [7:0] out;
input [2:0] source,dest;
input read_en,write_en,clk,rst;

wire [7:0] src_out, dest_out;

decoder D1(source,src_out);
decoder D2(dest,dest_out);

wire [6:0] write,read;

genvar p;
 
 generate for(p=0;p<7;p=p+1)
      begin 
      and a1(write[p],write_en,dest_out[p+1]);
      and a2(read[p],read_en,src_out[p+1]);

      reg_fetch R(in,out,read[p],write[p],clk,rst);


      end
 endgenerate


endmodule

module ex(in,out,instr,clk,rst, common_line, in_sig,add_sig,mov_sig,out_sig, read_en,write_en,load_a,load_b,sum_sig, source,dest);

input [7:0] in,instr;
input clk,rst;
output [7:0] out;

output [7:0] common_line;
output in_sig,add_sig,mov_sig,out_sig;
output read_en,write_en,load_a,load_b,sum_sig;
output [2:0] source,dest;

wire cout;

opcode_decoder O(instr,source,dest,in_sig,out_sig,add_sig,mov_sig,
sum_sig,load_a,load_b,read_en,write_en);

accumulator A(clk,rst,common_line,write_en,common_line,cout,load_a,load_b,add_sig,sum_sig);

reg_data R(common_line,common_line,source,dest,read_en,write_en,clk,rst);

TristateReg T1(in,in_sig,common_line);
TristateReg T2(common_line,out_sig,out);



endmodule
