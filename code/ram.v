`include "define.v"
module ram(
	input clk,
	input ce,
	input re,
	input we,
	input [31:0] read_addr,
	output reg[31:0] read_instr,
	input [31:0] write_addr,
	input [31:0] write_instr,
	input [3:0] write
);
	reg [31:0] instr_mem[0:1023];
	always @ (*) begin
		if (ce == `ChipEnable && re == `ReadEnable) begin
			read_instr <= instr_mem[read_addr[18:2]];
		end
		else begin
			read_instr <= 32'b0;
		end
	end

	always @ (negedge clk) begin
		if (ce == `ChipEnable && we == `WriteEnable) begin
			if (write[3] == 1'b1) begin
				instr_mem[write_addr[18:2]][31:24] <= write_instr[31:24];
			end
			if (write[2] == 1'b1) begin
				instr_mem[write_addr[18:2]][23:16] <= write_instr[23:16];
			end
			if (write[1] == 1'b1) begin
				instr_mem[write_addr[18:2]][15:8] <= write_instr[15:8];
			end
			if (write[0] == 1'b1) begin
				instr_mem[write_addr[18:2]][7:0] <= write_instr[7:0];
			end
		end
	end
endmodule