`include "define.v"
module id_ex(
	input clk,
	input rst,
	input [5:0] stall,
	input [31:0] id_instr,
	input [7:0] id_op,
	input [2:0] id_type,
	input [31:0] id_reg1,
	input [31:0] id_reg2,
	input id_we,
	input [4:0] id_write_addr,
	input [31:0] id_write_instr,

	output reg[31:0] ex_instr,
	output reg[7:0] ex_op,
	output reg[2:0] ex_type,
	output reg[31:0] ex_reg1,
	output reg[31:0] ex_reg2,
	output reg ex_we,
	output reg[4:0] ex_write_addr,
	output reg[31:0] ex_write_instr
);
	always @ (posedge clk) begin
		if (rst == `RstEnable || (stall[2] == `StallEnable && stall[3] == `StallDisable)) begin
			ex_instr <= 32'b0;
			ex_op <= `op_null;
			ex_type <= `type_null;
			ex_reg1 <= 32'b0;
			ex_reg2 <= 32'b0;
			ex_we <= `WriteDisable;
			ex_write_addr <= 32'b0;
			ex_write_instr <= 32'b0;
		end
		else if (stall[2] == `StallDisable) begin
			ex_instr <= id_instr;
			ex_op <= id_op;
			ex_type <= id_type;
			ex_reg1 <= id_reg1;
			ex_reg2 <= id_reg2;
			ex_we <= id_we;
			ex_write_addr <= id_write_addr;
			ex_write_instr <= id_write_instr;
		end
	end
endmodule