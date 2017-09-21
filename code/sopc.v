`include "define.v"
module sopc(
	input clk, 
	input rst
);
	wire [31:0] rom_instr_addr;
	wire rom_ce;
	wire [31:0] rom_instr;
	wire ram_ce;
	wire ram_we;
	wire ram_re;
	wire [31:0] ram_read_addr;
	wire [31:0] ram_read_instr;
	wire [31:0] ram_write_addr;
	wire [31:0] ram_write_instr;
	
	wire [3:0] ram_write;

	cpu cpu(
		.clk(clk), .rst(rst),
		.rom_read_addr(rom_instr_addr), .rom_read_instr(rom_instr),
		.ram_we(ram_we), .ram_re(ram_re),
		.ram_read_addr(ram_read_addr), .ram_read_instr(ram_read_instr),
		.ram_write_addr(ram_write_addr), .ram_write_instr(ram_write_instr),
		.ram_write(ram_write)
	);
	assign rom_ce = (rst == `RstEnable) ? `ChipDisable : `ChipEnable;
	assign ram_ce = (rst == `RstEnable) ? `ChipDisable : `ChipEnable;
	rom rom(
		.ce(rom_ce), .instr_addr(rom_instr_addr), .instr(rom_instr)
	);
	ram ram(
		.clk(clk), .ce(ram.ce), .re(ram.re), .we(ram.we),
		.read_addr(ram_read_addr), .read_instr(ram_read_instr),
		.write_addr(ram_write_addr), .write_instr(ram_write_instr),
		.write(ram_write)
	);
endmodule