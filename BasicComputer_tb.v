//TESTBENCH

`timescale 1ns/1ps
module BasicComputer_tb();

reg clk;
wire [15:0] IR;
wire [15:0] TR;
wire [15:0] DR;
wire [15:0] AC;
wire [11:0] PC;
wire [11:0] AR;
wire [3:0] timeCount;

// instantiate device under test
BasicComputer dut(IR,TR,DR,AC,PC,AR,clk,timeCount);

always begin
	clk = 0; #5; clk = 1; #5;
end

endmodule
