//select_(c,z) : mux to select which input connects to C/Z FF
module DataPath(input clk, reset, mem_write, reg_write, push, pop, alu_use_carry, input [2:0] alu_op, input [1:0] pc_mux, reg_write_mux, input alu_in_mux,reg_B_mux, select_c, select_z, write_c, write_z,
	output reg C, Z, output [18:0] IF_ID_instruction);
//PC
//Instruction memory
//register file
//ALU
//shifter
//dataMemory
//sign extend
	
	//wires and registers
	//C & Z FlipFlop
	reg next_C,next_Z;
	//pc & inst Memory
	reg  [11:0] pc, next_pc;
	wire [18:0] instruction;
	//reg pc_enable;
	
	//IF_ID
	//wire [18:0] IF_ID_instruction; //became output to controller
	wire [11:0] IF_ID_pc;
	wire flush; //comes from hazard control unit
	
	//reg file
	reg  [2:0] reg_addr_A, reg_addr_B, reg_addr_write;
	reg  [7:0] reg_write_data;
	wire [7:0]	reg_data_A, reg_data_B;
	
	//ID_EX
	wire [7:0] ID_EX_A, ID_EX_B;
    wire [18:0] ID_EX_instruction;
	
	//EX_MEM
	wire [7:0] EX_MEM_alu_out, EX_MEM_B, EX_MEM_shift_out;
	wire EX_MEM_mem_write, EX_MEM_reg_write;
	wire [18:0] EX_MEM_instruction;
	wire [1:0] EX_MEM_reg_write_mux;
	
		//controller
	wire ID_EX_mem_write, ID_EX_reg_write, ID_EX_alu_use_carry, ID_EX_alu_in_mux, ID_EX_select_c, ID_EX_select_z, ID_EX_write_c, ID_EX_write_z;
	wire	[2:0] ID_EX_alu_op;
	wire	[1:0] ID_EX_reg_write_mux;
	
	//MEM_WB
	wire [7:0] MEM_WB_mem_out_data, MEM_WB_alu_out, MEM_WB_shift_out;
	wire [18:0] MEM_WB_instruction;
	wire [1:0] MEM_WB_reg_write_mux;
	wire MEM_WB_reg_write;
	
	//data memory
	reg  [7:0] mem_addr, mem_write_data;
	wire [7:0] mem_out_data;
	
	
	
	//stack
	reg  [11:0] stack_in;
	wire [11:0] stack_out;
	
	//ALU
	reg [7:0] alu_A, alu_B;
	reg alu_cin;
	wire [7:0] alu_out;
	wire alu_co, alu_z;

	//Shifter
	wire shift_c, shift_z;
	reg [7:0] shift_data; 
	reg [2:0] bitcount;
	reg dir, sh_roBar;
	wire [7:0] shift_out;
	
	//Modules
	InstMem inst_mem (pc,instruction);
	DataMem data_mem (clk, EX_MEM_mem_write, mem_addr , mem_write_data, mem_out_data);
	RegFile reg_file (clk, MEM_WB_reg_write, reg_addr_A, reg_addr_B, reg_addr_write, reg_write_data, reg_data_A, reg_data_B);
	Stack 	stack(clk, reset, push,pop, stack_in, stack_out);
	ALU 	alu(alu_op , alu_A, alu_B, alu_cin, alu_out, alu_co, alu_z); 
	BarrelShifter bs(shift_data, bitcount,  dir, sh_roBar, shift_out, shift_c, shift_z);
	
	IF_ID if_id(clk, reset, flush, instruction, pc, IF_ID_instruction, IF_ID_pc);
	
	ID_EX id_ex(clk, reset, reg_data_A, reg_data_B, IF_ID_instruction, mem_write, reg_write, alu_use_carry, alu_in_mux, select_c, select_z, write_c, write_z, alu_op, reg_write_mux, ID_EX_A, ID_EX_B, ID_EX_instruction, ID_EX_mem_write, ID_EX_reg_write, ID_EX_alu_use_carry, ID_EX_alu_in_mux, ID_EX_select_c,ID_EX_select_z, ID_EX_write_c, ID_EX_write_z, ID_EX_alu_op, ID_EX_reg_write_mux);

	EX_MEM ex_mem(clk, reset, alu_out, ID_EX_B, shift_out, ID_EX_mem_write, ID_EX_reg_write, ID_EX_instruction, ID_EX_reg_write_mux, EX_MEM_alu_out, EX_MEM_B,EX_MEM_shift_out, EX_MEM_mem_write, EX_MEM_reg_write, EX_MEM_instruction, EX_MEM_reg_write_mux);
	
	MEM_WB mem_wb(clk, reset, mem_out_data, EX_MEM_alu_out, EX_MEM_shift_out, EX_MEM_instruction, EX_MEM_reg_write_mux, EX_MEM_reg_write, MEM_WB_mem_out_data, MEM_WB_alu_out, MEM_WB_shift_out,  MEM_WB_instruction, MEM_WB_reg_write_mux, MEM_WB_reg_write);
	
	always @(*) begin //calculate the new pc
		//PC
		case(pc_mux)
			2'b00: next_pc <= pc + 1;
			2'b01: next_pc <= pc + IF_ID_instruction[7:0]; //Branch Addr | IF_ID_pc+1 == pc  
			2'b10: next_pc <= IF_ID_instruction[11:0]; //JMP Addr | from ID level
			2'b11: next_pc <= stack_out; //RET Addr
		endcase
		
		//Stack
		stack_in <= IF_ID_pc + 1;// 
		
		//ALU
			//$display("ALU time %t", $time);
			//$display("reg A %b", reg_data_A);		
		alu_A <= ID_EX_A;
		//$display("alu A %b", alu_A);
		case(ID_EX_alu_in_mux)
			1'b0: alu_B <= ID_EX_B;
			1'b1:begin $display("alu B %b", ID_EX_instruction[7:0]); alu_B <= ID_EX_instruction[7:0]; end
		endcase 
		alu_cin <= ID_EX_alu_use_carry ? C : 1'b0;
		
		//Data Memory
		mem_addr <= EX_MEM_alu_out;
		mem_write_data <= EX_MEM_B;
		
		//Shifter
		bitcount <= ID_EX_instruction[8:5];
		sh_roBar <= ID_EX_instruction[15];
		dir <= ID_EX_instruction[14];
		shift_data <= ID_EX_A; //@TODO remember to use forwarding
		
		//RegFile
		reg_addr_A <= IF_ID_instruction[10:8];
		case(reg_B_mux)
			1'b0: reg_addr_B <= IF_ID_instruction[7:5];
			1'b1: reg_addr_B <= IF_ID_instruction[13:11];
		endcase
		
		//Write Back to RegFile
		reg_addr_write <= MEM_WB_instruction[13:11];
		case(MEM_WB_reg_write_mux)
			2'b00: reg_write_data <= MEM_WB_alu_out;
			2'b01: reg_write_data <= MEM_WB_shift_out;
			2'b10: reg_write_data <= MEM_WB_mem_out_data;
		endcase
		
		//C & Z FlipFlop
		case(ID_EX_select_c)
			1'b0: next_C <= alu_co;
			1'b1: next_C <= shift_c;
		endcase
		case(ID_EX_select_z)
			1'b0: next_Z <= alu_z;
			1'b1: next_Z <= shift_z;
		endcase
	end
	
	always @(posedge clk, posedge reset)begin //set new values to registers
		if(reset == 1'b0) begin
			pc = next_pc;
			if(ID_EX_write_c)
				C = next_C;
			if(ID_EX_write_z)
				Z = next_Z;
		end
		else begin
			{pc,C,Z} = 0;
		end
	end 
endmodule

module test_data_path();
	
	reg clk = 1'b0, reset, mem_write, reg_write, push, pop, alu_use_carry;
	reg [2:0] alu_op;
	reg [1:0] pc_mux, reg_write_mux;
	reg alu_in_mux,reg_B_mux, select_c, select_z, write_c, write_z;
	wire C, Z;
	wire [18:0] instruction;
	DataPath dp(clk, reset, mem_write, reg_write, push, pop, alu_use_carry, alu_op, pc_mux, reg_write_mux, alu_in_mux,reg_B_mux, select_c, select_z, write_c, write_z, C, Z, instruction); //but in pipeline, current instruction is ID level one
	
	
	
	initial repeat(10) #5 clk = ~clk;
	
	initial begin
		{reset, mem_write, reg_write, push, pop, alu_use_carry, alu_op, pc_mux, reg_write_mux, alu_in_mux,reg_B_mux, select_c, select_z, write_c, write_z} = 0;
		reset = 1'b1;
		{write_c, write_z} = 2'b11;
		reg_write = 1'b1;
		alu_in_mux = 1'b1;
		#10 reset = 1'b0;
		#14 alu_in_mux = 1'b0;
		#30 $stop;
	end

endmodule