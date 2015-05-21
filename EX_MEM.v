module EX_MEM(input clk, reset, input [7:0] alu_out, ID_EX_B, shift_out, input ID_EX_mem_write, ID_EX_reg_write, input [18:0] ID_EX_instruction, input [1:0] ID_EX_reg_write_mux,
							output [7:0] EX_MEM_alu_out, EX_MEM_B, EX_MEM_shift_out, output EX_MEM_mem_write, EX_MEM_reg_write, output [18:0] EX_MEM_instruction, output [1:0] EX_MEM_reg_write_mux);
							
	M_S_FF #(24) datapath(clk, 1'b0,  reset, {alu_out, ID_EX_B, shift_out}, {EX_MEM_alu_out, EX_MEM_B, EX_MEM_shift_out});
	M_S_FF #(19) instruction(clk, 1'b0, reset, ID_EX_instruction, EX_MEM_instruction);
	M_S_FF #(4) controller(clk, 1'b0, reset, {ID_EX_mem_write, ID_EX_reg_write, ID_EX_reg_write_mux}, {EX_MEM_mem_write, EX_MEM_reg_write, EX_MEM_reg_write_mux});

endmodule