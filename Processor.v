	module Processor(input clk, reset);
	wire [18:0] instruction;
	wire mem_write, reg_write, push, pop, alu_use_carry;
	wire [2:0] alu_op;
	wire [1:0] pc_mux, reg_write_mux, forward_A, forward_B;
	wire alu_B_mux, ID_EX_alu_B_mux, reg_B_mux, select_c, select_z, write_c, write_z;
	wire C, Z;
	
	Controller cntrl(clk ,reset, C, Z, instruction,
					mem_write, reg_write, push, pop, alu_use_carry,
					alu_op, pc_mux, 
					reg_write_mux, alu_B_mux,reg_B_mux,
					select_c, select_z, write_c, write_z);
					
	//ForwardingUnit fu(alu_B_mux,       forward_A, forward_B);
	assign forward_A = 2'b0;
	assign forward_B = {1'b0, ID_EX_alu_B_mux};
	
	DataPath dp(clk, reset, 
				mem_write, reg_write, push, pop, alu_use_carry, alu_op,
				pc_mux, reg_write_mux, forward_A, forward_B, alu_B_mux, reg_B_mux,
				select_c, select_z, write_c, write_z,
				C, Z, instruction, ID_EX_alu_B_mux);
endmodule

module test_processor();
	reg clk = 1'b0, reset = 1'b1;
	Processor prc(clk, reset);
	initial repeat(1000) #5 clk = ~clk;
	initial begin
		#6 reset = 1'b0;
		#500 $stop;
	end
endmodule
