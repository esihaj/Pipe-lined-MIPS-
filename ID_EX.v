module ID_EX (input clk, reset, 
	/*data path*/
	input [7:0] reg_in_A, reg_in_B, input [18:0] IF_ID_instruction,
	/*controller*/
	input mem_write, reg_write, alu_use_carry, alu_in_mux, select_c, select_z, write_c, write_z, input [2:0] alu_op,  input [1:0] reg_write_mux, 
	/*data path*/
	output [7:0] ID_EX_A, ID_EX_B, output [18:0] ID_EX_instruction,
	/*controller*/
	output ID_EX_mem_write, ID_EX_reg_write, ID_EX_alu_use_carry, ID_EX_alu_in_mux, ID_EX_select_c, ID_EX_select_z, ID_EX_write_c, ID_EX_write_z, output [2:0] ID_EX_alu_op, output [1:0] ID_EX_reg_write_mux);

	M_S_FF #(8) reg_A(clk, reset, reg_in_A, ID_EX_A);
	M_S_FF #(8) reg_B(clk, reset, reg_in_B, ID_EX_B);
	M_S_FF #(19) instruction(clk, reset, IF_ID_instruction, ID_EX_instruction);
	
	M_S_FF #(13) controller(clk, reset,
		{mem_write, reg_write, alu_use_carry, alu_in_mux, select_c, select_z, write_c, write_z, alu_op, reg_write_mux},
		{ID_EX_mem_write, ID_EX_reg_write, ID_EX_alu_use_carry, ID_EX_alu_in_mux, ID_EX_select_c, ID_EX_select_z, ID_EX_write_z, ID_EX_write_z, ID_EX_alu_op, ID_EX_reg_write_mux} );

	
endmodule