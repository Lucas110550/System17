`include "define.v"
module ex(
	input rst,
	input [31:0] instr_i,
	output [31:0] instr_o,
	input [7:0] op_i,
	output [7:0] op_o,
	input [2:0] type,
	input [31:0] reg1_i,
	output [31:0] reg1_o,
	input [31:0] reg2_i,
	output [31:0] reg2_o,
	input we_i,
	output reg we_o,
	input [4:0] write_addr_i,
	output reg[4:0] write_addr_o,
	input [31:0] write_instr_i,
	output reg[31:0] write_instr_o,
	output reg stallsignal
);

	wire [31:0] reg1_comp = ~reg1_i + 1;
	wire [31:0] reg2_comp = ~reg2_i + 1;
	wire [31:0] reg_sum = reg1_i + (op_i == `op_sub || op_i == `op_subu || op_i == `op_slt ? reg2_comp : reg2_i);
	assign instr_o = instr_i;
	assign op_o = op_i;
	assign reg1_o = reg1_i;
	assign reg2_o = reg2_i;

	reg [31:0] res_logic;
	always @ (*) begin
		if (rst == `RstEnable) begin
			res_logic <= 32'b0;
		end
		else begin
			case (op_i)
				`op_and : begin
					res_logic <= reg1_i & reg2_i;
				end
				`op_or : begin
					res_logic <= reg1_i | reg2_i;
				end
				`op_xor : begin
					res_logic <= reg1_i ^ reg2_i;
				end
				`op_nor : begin
					res_logic <= ~(reg1_i | reg2_i);
				end
				default : begin
					res_logic <= 32'b0;
				end
			endcase
		end
	end
	reg[63:0] res_arith;
	always @ (*) begin
		if (rst == `RstEnable) begin
			res_arith <= 32'b0;
		end
		else begin
			case (op_i)
				`op_slt : begin
					res_arith <= (reg1_i[31] == 1'b1 && reg2_i[31] == 1'b0) || (reg1_i[31] == reg2_i[31] && reg_sum[31] == 1'b1);
				end
				`op_sltu : begin
					res_arith <= reg1_i < reg2_i;
				end
				`op_add, `op_addu, `op_sub, `op_subu : begin
					res_arith <= reg_sum;
				end
				default : begin
					res_arith <= 32'b0;
				end
			endcase
		end
	end
	reg[31:0] res_jmp;
	always @ (*) begin
		if (rst == `RstEnable) begin
			res_jmp <= 32'b0;
		end
		else begin
			res_jmp <= write_instr_i;
		end
	end
	always @ (*) begin
		case (op_i)
			`op_add : begin
				if (reg1_i[31] == reg2_i[31] && reg_sum[31] != reg1_i[31]) begin
					we_o <= `WriteDisable;
				end
				else begin
					we_o <= we_i;
				end
			end
			`op_sub : begin
				if (reg1_i[31] == reg2_comp[31] && reg1_i != reg_sum[31]) begin
					we_o <= `WriteDisable;
				end
				else begin
					we_o <= we_i;
				end
			end
			default : begin
				we_o <= we_i;
			end
		endcase
		write_addr_o <= write_addr_i;
		case (type)
			`type_logic : begin
				write_instr_o <= res_logic;
			end
			`type_arith : begin
				write_instr_o <= res_arith[31:0];
			end
			`type_jmp : begin
				write_instr_o <= res_jmp;
			end
			default : begin
				write_instr_o <= 32'b0;
			end
		endcase
	end
endmodule				
