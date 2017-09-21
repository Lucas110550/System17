`include "define.v"
module ctrl(
	input rst,
	input id_stallsignal,
	input ex_stallsignal,
	output reg[5:0] stall
);
	always @ (*) begin
		if (rst == `RstEnable) begin
			stall <= 6'b000000;
		end
		else begin
			if (ex_stallsignal == `StallEnable) begin
				stall <= 6'b001111;
			end
			else if (id_stallsignal == `StallEnable) begin
				stall <= 6'b000111;
			end
			else begin
				stall <= 6'b000000;
			end
		end
	end
endmodule
