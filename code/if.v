module iff(
	input clk,
	input rst,
	input [5:0] stall,
	input pc_we,
	input pc_write_instr,
	output reg[31:0] pc_read_instr
);
	always @ (posedge clk) begin
		if (rst == 'RstEnable) begin
			pc_read_instr <= 32'b0;
		else
		else if (stall[0] == 'StallDisable) begin
			if (pc_we == 'WriteEnable) begin
				pc_read_instr <= pc_write_instr;
			end
			else begin
				pc_read_instr <= pc_write_instr + 32'd4;
			end
		end
	end
endmodule