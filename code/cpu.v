`include "define.v"
module cpu(
	input clk,
	input rst,
	input [31:0] rom_read_instr,
	input [31:0] ram_read_instr,
	output [31:0] rom_read_addr,
	output ram_re,
	output [31:0] ram_read_addr,
	output ram_we,
	output [31:0] ram_write_addr,
	output [3:0] ram_write,
	output [31:0] ram_write_instr
);
	wire [5:0] ctrl_stall;
	wire re1;
	wire [4:0] read_addr1;
	wire [31:0] read_instr1;
	wire re2;
	wire [4:0] read_addr2;
	wire [31:0] read_instr2;
	wire we;
	wire [4:0] write_addr;
	wire [31:0] write_instr;

	wire [31:0] if_pc_read_instr;
	wire [31:0] if_instr;

	wire [31:0] id_instr_i;
	wire [31:0] id_instr_o;
	wire id_pc_we;
	wire [31:0] id_pc_write_instr;
	wire [31:0] id_pc_read_instr;
	wire id_re1;
	wire [4:0] id_read_addr1;
	wire [31:0] id_read_instr1;
	wire id_re2;
	wire [4:0] id_read_addr2;
	wire [31:0] id_read_instr2;
	wire [7:0] id_op;
	wire [2:0] id_type;
	wire [31:0] id_reg1;
	wire [31:0] id_reg2;
	wire id_we;
	wire [4:0] id_write_addr;
	wire [31:0] id_write_instr;
	wire id_stallsignal;

	wire [31:0] ex_instr_i;
	wire [31:0] ex_instr_o;
	wire [7:0] ex_op_i;
	wire [7:0] ex_op_o;
	wire [2:0] ex_type;
	wire [31:0] ex_reg1_i;
	wire [31:0] ex_reg1_o;
	wire [31:0] ex_reg2_i;
	wire [31:0] ex_reg2_o;
	wire ex_we_i;
	wire ex_we_o;
	wire [4:0] ex_write_addr_i;
	wire [4:0] ex_write_addr_o;
	wire [31:0] ex_write_instr_i;
	wire [31:0] ex_write_instr_o;
	wire ex_stallsignal;
	
	wire [31:0] mem_instr;
	wire [7:0] mem_op;
	wire [31:0] mem_reg1;
	wire [31:0] mem_reg2;
	wire mem_we_i;
	wire mem_we_o;
	wire [4:0] mem_write_addr_i;
	wire [4:0] mem_write_addr_o;
	wire [31:0] mem_write_instr_i;
	wire [31:0] mem_write_instr_o;
	
	wire wb_we;
	wire [4:0] wb_write_addr;
	wire [31:0] wb_write_instr;
	
	ctrl ctrl(
		.rst(rst),
		.id_stallsignal(id_stallsignal),
		.ex_stallsignal(ex_stallsignal),
		.stall(ctrl_stall)
	);
	register register(
		.clk(clk), .rst(rst),
		.re1(re1), .read_addr1(read_addr1), .read_instr1(read_instr1),
		.re2(re2), .read_addr2(read_addr2), .read_instr2(read_instr2),
		.we(we), .write_addr(write_addr), .write_instr(write_instr)
	);
	iff iff(
		.clk(clk), .rst(rst), .stall(ctrl_stall),
		.pc_we(id_pc_we), .pc_write_instr(id_pc_write_instr),
		.pc_read_instr(if_pc_read_instr)
	);
	
	assign rom_read_addr = if_pc_read_instr;
	assign if_instr = rom_read_instr;
	
	if_id if_id(
		.clk(clk), .rst(rst), .stall(ctrl_stall),
		.if_pc(if_pc_read_instr), .if_instr(if_instr),
		.id_pc(id_pc_read_instr), .id_instr(id_instr_i)
	);
	
	id id(
		.rst(rst), .instr_i(id_instr_i), .instr_o(id_instr_o),
		.pc_we(id_pc_we), .pc_write_instr(id_pc_write_instr), .pc_i(id_pc_read_instr),
		.reg1_re(id_re1), .reg1_read_addr(id_read_addr1), .reg1_read_instr(id_read_instr1),
		.reg2_re(id_re2), .reg2_read_addr(id_read_addr2), .reg2_read_instr(id_read_instr2),
		.op(id_op), .type(id_type), .reg1(id_reg1), .reg2(id_reg2),
		.we(id_we), .write_addr(id_write_addr), .write_instr(id_write_instr),
		.ex_op(ex_op_o), .ex_we(ex_we_o), .ex_write_addr(ex_write_addr_o), .ex_write_instr(ex_write_instr_o),
		.mem_we(mem_we_o), .mem_write_addr(mem_write_addr_o), .mem_write_instr(mem_write_instr_o),
		.stallsignal(id_stallsignal)
	);
	assign re1 = id_re1;
	assign read_addr1 = id_read_addr1;
	assign id_read_instr1 = read_instr1;
	assign re2 = id_re2;
	assign read_addr2 = id_read_addr2;
	assign id_read_instr2 = read_instr2;

	id_ex id_ex(
		.clk(clk), .rst(rst), .stall(ctrl_stall), 
		.id_instr(id_instr_o), .id_op(id_op), .id_type(id_type), 
		.id_reg1(id_reg1), .id_reg2(id_reg2), .id_we(id_we), .id_write_addr(id_write_addr),
		.id_write_instr(id_write_instr),
		.ex_instr(ex_instr_i), .ex_op(ex_op_i), .ex_type(ex_type),
		.ex_reg1(ex_reg1_i), .ex_reg2(ex_reg2_i), .ex_we(ex_we_i),
		.ex_write_addr(ex_write_addr_i), .ex_write_instr(ex_write_instr_i)
	);

	ex ex(
		.rst(rst), .instr_i(ex_instr_i), .instr_o(ex_instr_o),
		.op_i(ex_op_i), .op_o(ex_op_o), .type(ex_type),
		.reg1_i(ex_reg1_i), .reg1_o(ex_reg1_o), .reg2_i(ex_reg2_i), .reg2_o(ex_reg2_o),
		.we_i(ex_we_i), .we_o(ex_we_o), .write_addr_i(ex_write_addr_i), .write_addr_o(ex_write_addr_o),
		.write_instr_i(ex_write_instr_i), .write_instr_o(ex_write_instr_o),
		.stallsignal(ex_stallsignal)
	);
	
	ex_mem ex_mem(
		.clk(clk), .rst(rst), .stall(ctrl_stall),
		.ex_instr(ex_instr_o), .ex_op(ex_op_o), .ex_reg1(ex_reg1_o), .ex_reg2(ex_reg2_o),
		.ex_we(ex_we_o), .ex_write_addr(ex_write_addr_o), .ex_write_instr(ex_write_instr_o),
		.mem_instr(mem_instr), .mem_op(mem_op), .mem_reg1(mem_reg1), .mem_reg2(mem_reg2),
		.mem_we(mem_we_i), .mem_write_addr(mem_write_addr_i), .mem_write_instr(mem_write_instr_i)
	);
	
	mem mem(
		.rst(rst), .instr(mem_instr), .op(mem_op), .reg1(mem_reg1), .reg2(mem_reg2),
		.mem_re(ram_re), .mem_read_addr(ram_read_addr), .mem_i(ram_read_instr),
		.mem_we(ram_we), .mem_write_addr(ram_write_addr), .mem_write(ram_write), 
		.mem_write_instr(ram_write_instr), 
		.we_i(mem_we_i), .we_o(mem_we_o), .write_addr_i(mem_write_addr_i), .write_addr_o(mem_write_addr_o),
		.write_instr_i(mem_write_instr_i), .write_instr_o(mem_write_instr_o)
	);
	
	mem_wb mem_wb(
		.clk(clk), .rst(rst), .stall(ctrl_stall),
		.mem_we(mem_we_o), .mem_write_addr(mem_write_addr_o), .mem_write_instr(mem_write_instr_o),
		.wb_we(wb_we), .wb_write_addr(wb_write_addr), .wb_write_instr(wb_write_instr)
	);

	assign we = wb_we;
	assign write_addr = wb_write_addr;
	assign write_instr = wb_write_instr;

	wb wb(
		.clk(clk), .rst(rst)
	);
endmodule
