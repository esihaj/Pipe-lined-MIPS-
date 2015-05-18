module MEM_WB(input clk, reset, input [7:0] EX_MEM_mem_out_data, EX_MEM_alu_out, EX_MEM_shift_out, input [18:0] EX_MEM_instruction,
							input [1:0] EX_MEM_reg_write_mux,
							output [7:0] MEM_WB_mem_out_data, MEM_WB_alu_out, MEM_WB_shift_out, output [18:0] MEM_WB_instruction,
							output[1:0] MEM_WB_reg_write_mux);
	
	M_S_FF #(24) datapath(clk, reset, {MEM_WB_mem_out_data, EX_MEM_alu_out, EX_MEM_shift_out}, {MEM_WB_mem_out_data, MEM_WB_alu_out, MEM_WB_shift_out});
	M_S_FF #(19) instruction(clk, reset, EX_MEM_instruction, MEM_WB_instruction);
	M_S_FF #(2) controller(clk, reset, EX_MEM_reg_write_mux, MEM_WB_reg_write_mux);

endmodule