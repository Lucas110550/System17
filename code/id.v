`include "define.v"
module id(
	input rst,
	input [31:0] instr_i,
	input [31:0] reg1_read_instr,
	input [31:0] reg2_read_instr,
	input [31:0] pc_i,
	input [7:0] ex_op,
	input ex_we,
	input [4:0] ex_write_addr,
	input [31:0] ex_write_instr,
	input mem_we,
	input [4:0] mem_write_addr,
	input [31:0] mem_write_instr,
	
	output [31:0] instr_o,
	output reg[7:0] op,
	output reg[2:0] type,
	output reg[31:0] reg1,
	output reg[31:0] reg2,
	output reg reg1_re,
	output reg[4:0] reg1_read_addr,
	output reg reg2_re,
	output reg[4:0] reg2_read_addr,
	output reg we,
	output reg[4:0] write_addr,
	output reg[31:0] write_instr,
	output reg pc_we,
	output reg[31:0] pc_write_instr,
	output reg stallsignal
);
	wire [31:0] pc_nxt = pc_i + 32'd4;
	wire [31:0] pc_jmp = {pc_nxt[31:28], instr_i[25:0], 2'b0};
	wire [31:0] pc_branch = pc_nxt + {{14{instr_i[15]}}, instr_i[15:0], 2'b00};
	wire [31:0] ex_op_status = ex_op == `op_lb || ex_op == `op_lbu || ex_op == `op_lh || ex_op == `op_lhu || ex_op == `op_lw || ex_op == `op_lwl || ex_op == `op_lwr;
	assign instr_o = instr_i;
	reg[31:0] immediatevalue;
	always @ (*) begin
		if (rst == `RstEnable) begin
			op <= `op_null;
			type <= `type_null;
			reg1_re <= `ReadDisable;
			reg1_read_addr <= 5'b0;
			reg2_re <= `ReadDisable;
			reg2_read_addr <= 5'b0;
			we <= `WriteDisable;
			write_addr <= 5'b0;
			write_instr <= 32'b0;
			pc_we <= `WriteDisable;
			pc_write_instr <= 32'b0;
			immediatevalue <= 32'b0;
		end
		else begin
			op <= `op_null;
			type <= `type_null;
			reg1_re <= `ReadDisable;
			reg1_read_addr <= instr_i[25:21];
			reg2_re <= `ReadDisable;
			reg2_read_addr <= instr_i[20:16];
			we <= `WriteDisable;
			write_addr <= instr_i[15:11];
			write_instr <= 32'b0;
			pc_we <= `WriteDisable;
			pc_write_instr <= 32'b0;
			immediatevalue <= 32'b0;
			
			case (instr_i[31:26])
				6'b000000 : begin
					case (instr_i[10:6])
						5'b00000 : begin
							case (instr_i[5:0])
								`opc_and : begin
									op <= `op_and;
									type <= `type_logic;
									reg1_re <= `ReadEnable;
									reg2_re <= `ReadEnable;
									we <= `WriteEnable;
								end
								`opc_or : begin
									op <= `op_or;
									type <= `type_logic;
									reg1_re <= `ReadEnable;
									reg2_re <= `ReadEnable;
									we <= `WriteEnable;
								end
								`opc_xor : begin
									op <= `op_xor;
									type <= `type_logic;
									reg1_re <= `ReadEnable;
									reg2_re <= `ReadEnable;
									we <= `WriteEnable;
								end
								`opc_nor : begin
									op <= `op_nor;
									type <= `type_logic;
									reg1_re <= `ReadEnable;
									reg2_re <= `ReadEnable;
									we <= `WriteEnable;
								end
								`opc_sll : begin
									op <= `op_sll;
									type <= `type_shift;
									reg1_re <= `ReadEnable;
									reg2_re <= `ReadEnable;
									we <= `WriteEnable;
								end
								`opc_srl : begin
									op <= `op_srl;
									type <= `type_shift;
									reg1_re <= `ReadEnable;
									reg2_re <= `ReadEnable;
									we <= `WriteEnable;
								end
								`opc_sra : begin
									op <= `op_sra;
									type <= `type_shift;
									reg1_re <= `ReadEnable;
									reg2_re <= `ReadEnable;
									we <= `WriteEnable;
								end
								`opc_null : begin
									op <= `op_null;
									type <= `type_null;
									reg1_re <= `ReadDisable;
									reg2_re <= `ReadEnable;
									we <= `WriteDisable;
								end
								`opc_mfhi : begin
									op <= `op_mfhi;
									type <= `type_move;
									reg1_re <= `ReadDisable;
									reg2_re <= `ReadDisable;
									we <= `WriteEnable;
								end
								`opc_mfho : begin
									op <= `op_mfho;
									type <= `type_move;
									reg1_re <= `ReadDisable;
									reg2_re <= `ReadDisable;
									we <= `WriteEnable;
								end
								`opc_mthi : begin
									op <= `op_mthi;
									type <= `type_move;
									reg1_re <= `ReadEnable;
									reg2_re <= `ReadDisable;
									we <= `WriteDisable;
								end
								`opc_mtho : begin
									op <= `op_mtho;
									type <= `type_move;
									reg1_re <= `ReadEnable;
									reg2_re <= `ReadDisable;
									we <= `WriteDisable;
								end
								`opc_movn : begin
									op <= `op_movn;
									type <= `type_move;
									reg1_re <= `ReadEnable;
									reg2_re <= `ReadEnable;
									we <= (reg2 == 32'b0) ? `WriteDisable : `WriteEnable;
								end
								`opc_movz : begin
									op <= `op_movz;
									type <= `type_move;
									reg1_re <= `ReadEnable;
									reg2_re <= `ReadEnable;
									we <= (reg2 == 32'b0) ? `WriteDisable : `WriteEnable;
								end
								`opc_slt : begin
									op <= `op_slt;
									type <= `type_arith;
									reg1_re <= `ReadEnable;
									reg2_re <= `ReadEnable;
									we <= `WriteEnable;
								end
								`opc_sltu : begin
									op <= `op_sltu;
									type <= `type_arith;
									reg1_re <= `ReadEnable;
									reg2_re <= `ReadEnable;
									we <= `WriteEnable;
								end
								`opc_add : begin
									op <= `op_add;
									type <= `type_arith;
									reg1_re <= `ReadEnable;
									reg2_re <= `ReadEnable;
									we <= `WriteEnable;
								end
								`opc_addu : begin
									op <= `op_addu;
									type <= `type_arith;
									reg1_re <= `ReadEnable;
									reg2_re <= `ReadEnable;
									we <= `WriteEnable;
								end
								`opc_sub : begin
									op <= `op_sub;
									type <= `type_arith;
									reg1_re <= `ReadEnable;
									reg2_re <= `ReadEnable;
									we <= `WriteEnable;
								end
								`opc_subu : begin
									op <= `op_subu;
									type <= `type_arith;
									reg1_re <= `ReadEnable;
									reg2_re <= `ReadEnable;
									we <= `WriteEnable;
								end
								`opc_mult : begin
									op <= `op_mult;
									type <= `type_arith;
									reg1_re <= `ReadEnable;
									reg2_re <= `ReadEnable;
									we <= `WriteDisable;
								end
								`opc_multu : begin
									op <= `op_multu;
									type <= `type_arith;
									reg1_re <= `ReadEnable;
									reg2_re <= `ReadEnable;
									we <= `WriteDisable;
								end
								`opc_jr : begin
									op <= `op_jr;
									type <= `type_jmp;
									reg1_re <= `ReadEnable;
									reg2_re <= `ReadDisable;
									we <= `WriteDisable;
									pc_we <= `WriteEnable;
									pc_write_instr <= reg1;
								end
								`opc_jalr : begin
									op <= `op_jalr;
									type <= `type_jmp;
									reg1_re <= `ReadEnable;
									reg2_re <= `ReadDisable;
									we <= `WriteEnable;
									pc_we <= `WriteEnable;
									pc_write_instr <= reg1;
									write_addr <= instr_i[15:11];
									write_instr <= pc_i + 32'd8;
								end
							endcase
						end
					endcase
				end
				6'b000001 : begin
					case (instr_i[20:16]) 
						`opc_bgez : begin
							op <= `op_bgez;
							type <= `type_jmp;
							reg1_re <= `ReadEnable;
							reg2_re <= `ReadDisable;
							we <= `WriteDisable;
							pc_we <= (reg1[31] == 1'b0) ? `WriteEnable : `WriteDisable;
							pc_write_instr <= pc_branch;
						end
						`opc_bgezal : begin
							op <= `op_bgezal;
							type <= `type_jmp;
							reg1_re <= `ReadEnable;
							reg2_re <= `ReadDisable;
							we <= `WriteEnable;
							pc_we <= (reg1[31] == 1'b0) ? `WriteEnable : `WriteDisable;
							pc_write_instr <= pc_branch;
							write_addr <= 5'b11111;
							write_instr <= pc_i + 32'd8;
						end
						`opc_bltz : begin
							op <= `op_bltz;
							type <= `type_jmp;
							reg1_re <= `ReadEnable;
							reg2_re <= `ReadDisable;
							we <= `WriteDisable;
							pc_we <= (reg1[31] == 1'b1) ? `WriteEnable : `WriteDisable;
							pc_write_instr <= pc_branch;
						end
						`opc_bltzal : begin
							op <= `op_bltzal;
							type <= `type_jmp;
							reg1_re <= `ReadEnable;
							reg2_re <= `ReadDisable;
							we <= `WriteEnable;
							pc_we <= (reg1[31] == 1'b1) ? `WriteEnable : `WriteDisable;
							pc_write_instr <= pc_branch;
							write_addr <= 5'b11111;
							write_instr <= pc_i + 32'd8;
						end
					endcase
				end
				6'b011100 : begin
					case (instr_i[5:0])
						`opc_clz : begin
							op <= `op_clz;
							type <= `type_arith;
							reg1_re <= `ReadEnable;
							reg2_re <= `ReadDisable;
							we <= `WriteEnable;
						end
						`opc_clo : begin
							op <= `op_clo;
							type <= `type_arith;
							reg1_re <= `ReadEnable;
							reg2_re <= `ReadDisable;
							we <= `WriteEnable;
						end
						`opc_mul : begin
							op <= `op_mul;
							type <= `type_arith;
							reg1_re <= `ReadEnable;
							reg2_re <= `ReadEnable;
							we <= `WriteEnable;
						end
					endcase
				end
				`opc_andi : begin
					op <= `op_and;
					type <= `type_logic;
					reg1_re <= `ReadEnable;
					reg2_re <= `ReadDisable;
					we <= `WriteEnable;
					write_addr <= instr_i[20:16];
					immediatevalue <= {16'b0, instr_i[15:0]};
				end
				`opc_ori : begin
					op <= `op_or;
					type <= `type_logic;
					reg1_re <= `ReadEnable;
					reg2_re <= `ReadDisable;
					we <= `WriteEnable;
					write_addr <= instr_i[20:16];
					immediatevalue <= {16'b0, instr_i[15:0]};
				end
				`opc_xori : begin
					op <= `op_xor;
					type <= `type_logic;
					reg1_re <= `ReadEnable;
					reg2_re <= `ReadDisable;
					we <= `WriteEnable;
					write_addr <= instr_i[20:16];
					immediatevalue <= {16'b0, instr_i[15:0]};
				end
				`opc_lui : begin
					op <= `op_or;
					type <= `type_logic;
					reg1_re <= `ReadEnable;
					reg2_re <= `ReadDisable;
					we <= `WriteEnable;
					write_addr <= instr_i[20:16];
					immediatevalue <= {instr_i[15:0], 16'b0};
				end
				`opc_pref : begin
					op <= `op_null;
					type <= `type_null;
					reg1_re <= `ReadDisable;
					reg2_re <= `ReadEnable;
					we <= `WriteDisable;
				end
				`opc_slti : begin
					op <= `op_slt;
					type <= `type_arith;
					reg1_re <= `ReadEnable;
					reg2_re <= `ReadDisable;
					we <= `WriteEnable;
					write_addr <= instr_i[20:16];
					immediatevalue <= {{16{instr_i[15]}}, instr_i[15:0]};
				end
				`opc_sltiu : begin
					op <= `op_sltu;
					type <= `type_arith;
					reg1_re <= `ReadEnable;
					reg2_re <= `ReadDisable;
					we <= `WriteEnable;
					write_addr <= instr_i[20:16];
					immediatevalue <= {{16{instr_i[15]}}, instr_i[15:0]};
				end
				`opc_addi : begin
					op <= `op_add;
					type <= `type_arith;
					reg1_re <= `ReadEnable;
					reg2_re <= `ReadDisable;
					we <= `WriteEnable;
					write_addr <= instr_i[20:16];
					immediatevalue <= {{16{instr_i[15]}}, instr_i[15:0]};
				end
				`opc_addiu : begin
					op <= `op_addu;
					type <= `type_arith;
					reg1_re <= `ReadEnable;
					reg2_re <= `ReadDisable;
					we <= `WriteEnable;
					write_addr <= instr_i[20:16];
					immediatevalue <= {{16{instr_i[15]}}, instr_i[15:0]};
				end
				`opc_lb : begin
					op <= `op_lb;
					type <= `type_memory;
					reg1_re <= `ReadEnable;
					reg2_re <= `ReadDisable;
					we <= `WriteEnable;
					write_addr <= instr_i[20:16];
				end
				`opc_lbu : begin
					op <= `op_lbu;
					type <= `type_memory;
					reg1_re <= `ReadEnable;
					reg2_re <= `ReadDisable;
					we <= `WriteEnable;
					write_addr <= instr_i[20:16];
				end
				`opc_lh : begin
					op <= `op_lh;
					type <= `type_memory;
					reg1_re <= `ReadEnable;
					reg2_re <= `ReadDisable;
					we <= `WriteEnable;
					write_addr <= instr_i[20:16];
				end
				`opc_lhu : begin
					op <= `op_lhu;
					type <= `type_memory;
					reg1_re <= `ReadEnable;
					reg2_re <= `ReadDisable;
					we <= `WriteEnable;
					write_addr <= instr_i[20:16];
				end
				`opc_lw : begin
					op <= `op_lw;
					type <= `type_memory;
					reg1_re <= `ReadEnable;
					reg2_re <= `ReadDisable;
					we <= `WriteEnable;
					write_addr <= instr_i[20:16];
				end
				`opc_lwl : begin
					op <= `op_lwl;
					type <= `type_memory;
					reg1_re <= `ReadEnable;
					reg2_re <= `ReadEnable;
					we <= `WriteEnable;
					write_addr <= instr_i[20:16];
				end
				`opc_lwr : begin
					op <= `op_lwr;
					type <= `type_memory;
					reg1_re <= `ReadEnable;
					reg2_re <= `ReadEnable;
					we <= `WriteEnable;
					write_addr <= instr_i[20:16];
				end
				`opc_sb : begin
					op <= `op_sb;
					type <= `type_memory;
					reg1_re <= `ReadEnable;
					reg2_re <= `ReadEnable;
					we <= `WriteDisable;
				end
				`opc_sh : begin
					op <= `op_sh;
					type <= `type_memory;
					reg1_re <= `ReadEnable;
					reg2_re <= `ReadEnable;
					we <= `WriteDisable;
				end
				`opc_sw : begin
					op <= `op_sw;
					type <= `type_memory;
					reg1_re <= `ReadEnable;
					reg2_re <= `ReadEnable;
					we <= `WriteDisable;
				end
				`opc_swl : begin
					op <= `op_swl;
					type <= `type_memory;
					reg1_re <= `ReadEnable;
					reg2_re <= `ReadEnable;
					we <= `WriteDisable;
				end
				`opc_swr : begin
					op <= `op_swr;
					type <= `type_memory;
					reg1_re <= `ReadEnable;
					reg2_re <= `ReadEnable;
					we <= `WriteDisable;
				end
				`opc_j : begin
					op <= `op_j;
					type <= `type_jmp;
					reg1_re <= `ReadDisable;
					reg2_re <= `ReadDisable;
					we <= `WriteDisable;
					pc_we <= `WriteEnable;
					pc_write_instr <= pc_jmp;
				end
				`opc_jal : begin
					op <= `op_jal;
					type <= `type_jmp;
					reg1_re <= `ReadDisable;
					reg2_re <= `ReadDisable;
					we <= `WriteEnable;
					pc_we <= `WriteEnable;
					pc_write_instr <= pc_jmp;
					write_addr <= 5'b11111;
					write_instr <= pc_i + 32'd8;
				end
				`opc_beq : begin
					op <= `op_beq;
					type <= `type_jmp;
					reg1_re <= `ReadEnable;
					reg2_re <= `ReadEnable;
					we <= `WriteDisable;
					pc_we <= (reg1 == reg2) ? `WriteEnable : `WriteDisable;
					pc_write_instr <= pc_branch;
				end
				`opc_bne : begin
					op <= `op_bne;
					type <= `type_jmp;
					reg1_re <= `ReadEnable;
					reg2_re <= `ReadEnable;
					we <= `WriteDisable;
					pc_we <= (reg1 != reg2) ? `WriteEnable : `WriteDisable;
					pc_write_instr <= pc_branch;
				end
				`opc_bgtz : begin
					op <= `op_bgtz;
					type <= `type_jmp;
					reg1_re <= `ReadEnable;
					reg2_re <= `ReadDisable;
					we <= `WriteDisable;
					pc_we <= (reg1[31] == 1'b0 && reg1 != 32'b0) ? `WriteEnable : `WriteDisable;
					pc_write_instr <= pc_branch;
				end
				`opc_blez : begin
					op <= `op_blez;
					type <= `type_jmp;
					reg1_re <= `ReadEnable;
					reg2_re <= `ReadDisable;
					we <= `WriteDisable;
					pc_we <= (reg1[31] == 1'b1 || reg1 == 32'b0) ? `WriteEnable : `WriteDisable;
					pc_write_instr <= pc_branch;
				end
			endcase
			if (instr_i[31:21] == 11'b0) begin
				case (instr_i[5:0])
					`opc_sll : begin
						op <= `op_sll;
						type <= `type_shift;
						reg1_re <= `ReadDisable;
						reg2_re <= `ReadEnable;
						we <= `WriteEnable;
						write_addr <= instr_i[15:11];
						immediatevalue[4:0] <= instr_i[10:6];
					end
					`opc_srl : begin
						op <= `op_srl;
						type <= `type_shift;
						reg1_re <= `ReadDisable;
						reg2_re <= `ReadEnable;
						we <= `WriteEnable;
						write_addr <= instr_i[15:11];
						immediatevalue[4:0] <= instr_i[10:6];
					end
					`opc_sra : begin
						op <= `op_sra;
						type <= `type_shift;
						reg1_re <= `ReadDisable;
						reg2_re <= `ReadEnable;
						we <= `WriteEnable;
						write_addr <= instr_i[15:11];
						immediatevalue[4:0] <= instr_i[10:6];
					end
				endcase
			end
		end
	end
	always @ (*) begin
		if (rst == `RstEnable) begin
			stallsignal <= `StallDisable;
		end
		else begin
			if (reg1_re == `ReadEnable && ex_op_status == 1'b1 && ex_write_addr == reg1_read_addr) begin
				stallsignal <= `StallEnable;
			end
			else if (reg2_re == `ReadEnable && ex_op_status == 1'b1 && ex_write_addr == reg2_read_addr) begin
				stallsignal <= `StallEnable;
			end
			else begin
				stallsignal <= `StallDisable;
			end
		end
	end
	always @ (*) begin
		if (rst == `RstEnable) begin
			reg1 <= 32'b0;
		end
		else if (reg1_re == `ReadEnable && ex_we == `WriteEnable && ex_write_addr == reg1_read_addr) begin
			reg1 <= ex_write_instr;
		end
		else if (reg1_re == `ReadEnable && mem_we == `WriteEnable && mem_write_addr == reg1_read_addr) begin
			reg1 <= mem_write_instr;
		end
		else if (reg1_re == `ReadEnable) begin
			reg1 <= reg1_read_instr;
		end
		else if (reg1_re == `ReadDisable) begin
			reg1 <= immediatevalue;
		end
		else begin
			reg1 <= 32'b0;
		end
	end
	always @ (*) begin
		if (rst == `RstEnable) begin
			reg2 <= 32'b0;
		end
		else if (reg2_re == `ReadEnable && ex_we == `WriteEnable && ex_write_addr == reg2_read_addr) begin
			reg2 <= ex_write_instr;
		end
		else if (reg2_re == `ReadEnable && mem_we == `WriteEnable && mem_write_addr == reg2_read_addr) begin
			reg2 <= mem_write_instr;
		end
		else if (reg2_re == `ReadEnable) begin
			reg2 <= reg2_read_instr;
		end
		else if (reg2_re == `ReadDisable) begin
			reg2 <= immediatevalue;
		end
		else begin
			reg2 <= 32'b0;
		end
	end
endmodule