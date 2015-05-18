module EX_MEM(input clk, reset, input [7:0] alu_out, ID_EX_B, shift_out, input ID_EX_mem_write, ID_EX_reg_write, input [1:0] ID_EX_reg_write_mux,
							output [7:0] EX_MEM_alu_out, EX_MEM_B, EX_MEM_shift_out, output EX_MEM_mem_write, EX_MEM_reg_write, output [1:0] EX_MEM_reg_write_mux);
							
	M_S_FF #(24) datapath(clk, reset, {alu_out, ID_EX_B, shift_out}, {EX_MEM_alu_out, EX_MEM_B, EX_MEM_shift_out});
	M_S_FF #(4) controller(clk, reset, {ID_EX_mem_write, ID_EX_reg_write, ID_EX_reg_write_mux}, {EX_MEM_mem_write, EX_MEM_reg_write, EX_MEM_reg_write_mux});

endmodule