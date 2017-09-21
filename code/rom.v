`include "define.v"
module rom(
	input ce,
	input [31:0] instr_addr,
	output reg[31:0] instr
);
	reg [31:0] instr_mem[0:1023];
	initial $readmemh("inst_rom.data", instr_mem);
	always @ (*) begin
		if (ce == `ChipDisable) begin
			instr <= 32'b0;
		end
		else begin
			instr <= instr_mem[instr_addr[18:2]];
		end
	end
endmodule