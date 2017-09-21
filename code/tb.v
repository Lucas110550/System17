`timescale 1ns/1ps
`include "define.v"
module tb();

	reg CLOCK_50;
	reg rst;

	initial begin
		CLOCK_50 = 1'b0;
		forever #10 CLOCK_50 = ~CLOCK_50;
	end

	initial begin
		rst = `RstEnable;
		#195 rst = `RstDisable;
		#1000 $stop;
	end

	sopc sopc(
		.clk(CLOCK_50), .rst(rst)
	);
endmodule
