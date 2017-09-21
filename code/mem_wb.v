`include "define.v"
module mem_wb(
	input clk,
	input rst,
	input [5:0] stall,
	input mem_we,
	input [4:0] mem_write_addr,
	input [31:0] mem_write_instr,
	
	output reg wb_we,
	output reg[4:0] wb_write_addr,
	output reg[31:0] wb_write_instr
);
	always @ (posedge clk) begin
		if (rst == `RstEnable || (stall[4] == `StallEnable && stall[5] == `StallDisable)) begin
			wb_we <= `WriteDisable;
			wb_write_addr <= 5'b0;
			wb_write_instr <= 32'b0;
		end
		else if (stall[4] == `StallDisable) begin
			wb_we <= mem_we;
			wb_write_addr <= mem_write_addr;
			wb_write_instr <= mem_write_instr;
		end
	end
endmodule