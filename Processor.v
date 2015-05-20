	module Processor(input clk, reset);
	wire [18:0] instruction, IF_ID_instruction;
	wire IF_ID_loadbar, pc_writebar, ID_EX_flush, mem_write, reg_write, push, pop, alu_use_carry;
	wire [2:0] alu_op;
	wire [1:0] pc_mux, reg_write_mux, forward_A, forward_B;
	wire forward_mem_MEM, alu_B_mux, ID_EX_alu_B_mux, reg_B_mux, select_c, select_z, write_c, write_z;
	wire C, Z, next_C, next_Z, do_branch;
	
	Controller cntrl(clk ,reset, C, Z, next_C, next_Z, IF_ID_instruction,
					mem_write, reg_write, push, pop, alu_use_carry,
					alu_op, pc_mux, 
					reg_write_mux, alu_B_mux,reg_B_mux,
					select_c, select_z, write_c, write_z, do_branch);
					
	//ForwardingUnit fu(alu_B_mux,       forward_A, forward_B);
	HazardDetectionUnit hdu (instruction, IF_ID_instruction, do_branch, IF_ID_loadbar, IF_ID_flush, ID_EX_flush, pc_writebar);
	assign forward_A = 2'b0;
	assign forward_B = {1'b0, ID_EX_alu_B_mux};
	assign forward_mem_MEM = 1'b0;
	assign IF_ID_loadbar = 1'b0;
	assign pc_writebar = 1'b0;
	DataPath dp(clk, reset, IF_ID_loadbar, pc_writebar, ID_EX_flush,
				mem_write, reg_write, push, pop, alu_use_carry, alu_op,
				pc_mux, reg_write_mux, forward_A, forward_B, forward_mem_MEM, alu_B_mux, reg_B_mux,
				select_c, select_z, write_c, write_z,
				C, Z, next_C, next_Z, instruction, IF_ID_instruction, ID_EX_alu_B_mux);
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
