`include "define.v"
module mem(
	input rst,
	input [31:0] instr,
	input [7:0] op,
	input [31:0] reg1,
	input [31:0] reg2,
	input [31:0] mem_i,
	input we_i,
	input [4:0] write_addr_i,
	input [31:0] write_instr_i,

	output reg mem_re,
	output reg[31:0] mem_read_addr,
	output reg mem_we,
	output reg[31:0] mem_write_addr,
	output reg[3:0] mem_write,
	output reg[31:0] mem_write_instr,
	output reg we_o,
	output reg[4:0] write_addr_o,
	output reg[31:0] write_instr_o
);
	wire [31:0] addr = reg1 + {{16{instr[15]}}, instr[15:0]};
	always @ (*) begin
		if (rst == `RstEnable) begin
			mem_re <= `ReadDisable;
			mem_read_addr <= 5'b0;
			mem_we <= `WriteDisable;
			mem_write_addr <= 5'b0;
			mem_write <= 4'b0;
			mem_write_instr <= 32'b0;
			we_o <= `WriteDisable;
			write_addr_o <= 5'b0;
			write_instr_o <= 32'b0;
		end
		else begin
			mem_re <= `ReadDisable;
			mem_read_addr <= 5'b0;
			mem_we <= `WriteDisable;
			mem_write_addr <= 5'b0;
			mem_write <= 4'b0;
			mem_write_instr <= 32'b0;
			we_o <= we_i;
			write_addr_o <= write_addr_i;
			write_instr_o <= write_instr_i;
			case (op)
				`op_lb : begin
					mem_re <= `ReadEnable;
					mem_read_addr <= addr;
					mem_we <= `WriteDisable;
					case (addr[1:0])
						2'b00 : begin
							write_instr_o <= {{24{mem_i[31]}}, mem_i[31:24]};
						end
						2'b01 : begin
							write_instr_o <= {{24{mem_i[23]}}, mem_i[23:16]};
						end
						2'b10 : begin
							write_instr_o <= {{24{mem_i[15]}}, mem_i[15:8]};
						end
						2'b11 : begin
							write_instr_o <= {{24{mem_i[7]}}, mem_i[7:0]};
						end
						default : begin
							write_instr_o <= 32'b0;
						end
					endcase
				end
				`op_lbu : begin
					mem_re <= `ReadEnable;
					mem_read_addr <= addr;
					mem_we <= `WriteDisable;
					case (addr[1:0])
						2'b00 : begin
							write_instr_o <= {24'b0, mem_i[31:24]};
						end
						2'b01 : begin
							write_instr_o <= {24'b0, mem_i[23:16]};
						end
						2'b10 : begin
							write_instr_o <= {24'b0, mem_i[15:8]};
						end
						2'b11 : begin
							write_instr_o <= {24'b0, mem_i[7:0]};
						end
						default : begin
							write_instr_o <= 32'b0;
						end
					endcase
				end
				`op_lh : begin
					mem_re <= `ReadEnable;
					mem_read_addr <= addr;
					mem_we <= `WriteDisable;
					case (addr[1:0])
						2'b00 : begin
							write_instr_o <= {{16{mem_i[31]}}, mem_i[31:16]};
						end
						2'b10 : begin
							write_instr_o <= {{16{mem_i[15]}}, mem_i[15:0]};
						end
						default : begin
							write_instr_o <= 32'b0;
						end
					endcase
				end
				`op_lhu : begin
					mem_re <= `ReadEnable;
					mem_read_addr <= addr;
					mem_we <= `WriteDisable;
					case (addr[1:0])
						2'b00 : begin
							write_instr_o <= {16'b0, mem_i[31:16]};
						end
						2'b10 : begin
							write_instr_o <= {16'b0, mem_i[15:0]};
						end
						default : begin
							write_instr_o <= 32'b0;
						end
					endcase
				end
				`op_lw : begin
					mem_re <= `ReadEnable;
					mem_read_addr <= addr;
					mem_we <= `WriteDisable;
					write_instr_o <= mem_i;
				end
				`op_lwr : begin
				end
				`op_lwl : begin
				end
				`op_sb : begin
					mem_re <= `ReadDisable;
					mem_write_addr <= addr;
					mem_we <= `WriteEnable;
					mem_write_instr <= {4{reg2[7:0]}};
					case (addr[1:0])
						2'b00 : begin
							mem_write <= 4'b1000;
						end
						2'b01 : begin
							mem_write <= 4'b0100;
						end
						2'b10 : begin
							mem_write <= 4'b0010;
						end
						2'b11 : begin
							mem_write <= 4'b0001;
						end
						default : begin
							mem_write <= 4'b0000;
						end
					endcase
				end
				`op_sh : begin
				end
				`op_sw : begin
					mem_re <= `ReadDisable;
					mem_write_addr <= addr;
					mem_we <= `WriteEnable;
					mem_write_instr <= reg2;
					mem_write <= 4'b1111;
				end
				`op_swl : begin
				end
				`op_swr : begin
				end
			endcase
		end
	end
endmodule
			