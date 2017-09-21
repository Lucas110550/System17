`include "define.v"
module ex_mem(
	input clk,
	input rst,
	input [5:0] stall,
	input [31:0] ex_instr,
	input [7:0] ex_op,
	input [31:0] ex_reg1,
	input [31:0] ex_reg2,
	input ex_we,
	input [4:0] ex_write_addr,
	input [31:0] ex_write_instr,
	output reg[31:0] mem_instr,
	output reg[7:0] mem_op,
	output reg[31:0] mem_reg1,
	output reg[31:0] mem_reg2,
	output reg mem_we,
	output reg[4:0] mem_write_addr,
	output reg[31:0] mem_write_instr
);
	always @ (posedge clk) begin
		if (rst == `RstEnable || (stall[3] == `StallEnable && stall[4] == `StallDisable)) begin
			mem_instr <= 32'b0;
			mem_op <= `op_null;
			mem_reg1 <= 32'b0;
			mem_reg2 <= 32'b0;
			mem_we <= `WriteDisable;
			mem_write_addr <= 5'b0;
			mem_write_instr <= 32'b0;
		end
		else if (stall[3] == `StallDisable) begin
			mem_instr <= ex_instr;
			mem_op <= ex_op;
			mem_reg1 <= ex_reg1;
			mem_reg2 <= ex_reg2;
			mem_we <= ex_we;
			mem_write_addr <= ex_write_addr;
			mem_write_instr <= ex_write_instr;
		end
	end
endmodule