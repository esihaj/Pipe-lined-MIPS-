module IF_ID (input clk, reset, flush, [18:0]instruction, input [11:0] pc,
	output [18:0]IF_ID_instruction, output [11:0] IF_ID_pc );
	
	M_S_FF #(19) inst_reg(clk, reset|flush, instruction, IF_ID_instruction);
	M_S_FF #(12) pc_reg(clk, reset|flush, pc, IF_ID_pc);

endmodule


module test_IF_ID();
	reg clk;
	reg reset;
	reg flush;
	reg [18:0] instruction_in;
	reg [11:0] pc_in;
	wire [18:0] instruction_out;
	wire [11:0] pc_out;
	IF_ID uut(clk,reset,flush,instruction_in,pc_in,instruction_out,pc_out);
	initial repeat (100) #10 clk = ~clk;
	
	initial begin 
		reset = 0; flush = 0; clk = 0;
		instruction_in = 18'd110;
		pc_in = 12'd72;
		#30 instruction_in = 18'd12400;
		#20 flush = 1;
		#20 flush = 0;
		#20 $stop;
		
	end
endmodule