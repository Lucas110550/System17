`include "define.v"
module if_id(
	input clk,
	input rst,
	input [5:0] stall,
	input [31:0] if_pc,
	input [31:0] if_instr,
	output reg[31:0] id_pc,
	output reg[31:0] id_instr
);

	always @ (posedge clk) begin
		if (rst == `RstEnable || (stall[1] == `StallEnable && stall[2] == `StallDisable)) begin
			id_pc <= 32'b0;
			id_instr <= 32'b0;
		end
		else if (stall[1] == `StallDisable) begin
			id_pc <= if_pc;
			id_instr <= if_instr;
		end
	end
endmodule