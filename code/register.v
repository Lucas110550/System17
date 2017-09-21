`include "define.v"
module register(
	input clk,
	input rst,
	input re1,
	input [4:0] read_addr1,
	input re2,
	input [4:0] read_addr2,
	input we,
	input [4:0] write_addr,
	input [31:0] write_instr,
	output reg[31:0] read_instr1,
	output reg[31:0] read_instr2
);

	reg[31:0] instr[31:0];
	always @ (*) begin
		if (rst == `RstDisable && re1 == `ReadEnable && read_addr1 != 5'b0) begin
			read_instr1 <= instr[read_addr1];
		end
		else begin
			read_instr1 <= 32'b0;
		end
	end

	always @ (*) begin
		if (rst == `RstDisable && re2 == `ReadEnable && read_addr2 != 5'b0) begin
			read_instr2 <= instr[read_addr2];
		end
		else begin
			read_instr2 <= 32'b0;
		end
	end
	
	always @ (negedge clk) begin
		if (rst == `RstDisable && we == `WriteEnable && write_addr != 5'b0) begin
			instr[write_addr] <= write_instr;
		end
	end
endmodule
