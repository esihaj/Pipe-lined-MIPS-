module ForwardUnit (input [18:0]  ID_EX_instruction, EX_MEM_instruction, MEM_WB_instruction,
                    input [1:0] ID_EX_alu_B_mux,  output reg [1:0]forward_A, forward_B, output reg forward_mem_MEM, [1:0] forward_mem_EX);
	//aliases
  	wire [2:0] ID_EX_A, ID_EX_B, ID_EX_DST;
  	wire [2:0] EX_MEM_DST, MEM_WB_DST;
	reg type_alu, type_imm, type_lw, type_sw;
	reg next_type_lw, next_type_alu;
	reg next2_type_alu, next2_type_lw;//really bad name
  	reg L_1_dependency;
	
	assign ID_EX_A = ID_EX_instruction[10:8];
	assign ID_EX_B = ID_EX_instruction[7:5];
	assign ID_EX_DST = ID_EX_instruction[13:11];
	assign EX_MEM_DST = EX_MEM_instruction[13:11];
	assign MEM_WB_DST = MEM_WB_instruction[13:11];
	always@(*) begin
		{type_alu, type_imm, type_lw, next_type_lw, next_type_alu, next2_type_alu, next2_type_lw} = 0;
		if(ID_EX_instruction[18] == 1'b0)
			type_alu = 1'b1;
		if(ID_EX_instruction[17] == 1'b1)
			type_imm = 1'b1;
		
		if (ID_EX_instruction[18:14] == 5'b10000) // Load Word
			type_lw = 1'b1;
		if (EX_MEM_instruction[18:14] == 5'b10000) // NEXT OP: Load Word
			next2_type_lw = 1'b1;
		if (MEM_WB_instruction[18:14] == 5'b10000) // NEXT OP: Load Word
			next2_type_lw = 1'b1;
			
		if(ID_EX_instruction[18:14] == 5'b10001)//Store Word
			type_sw = 1'b1;
		
		if(EX_MEM_instruction[18] == 1'b0)
			next_type_alu = 1'b1;		
		if(MEM_WB_instruction[18] == 1'b0)
			next2_type_alu = 1'b1;
			
	end
	
	always@(*) begin
		//default values
		L_1_dependency = 0;
		{forward_A,forward_mem_EX,forward_mem_MEM} = 0;
		forward_B = ID_EX_alu_B_mux;
	  
		//iR-Type
		if(type_alu) //R-Type instructions
			if(EX_MEM_DST != 3'b0) //not $r0
			begin
				//rtype -> rtype
				//L-1
				if(ID_EX_A == EX_MEM_DST && next_type_alu)
					begin 
					forward_A = 2'b10;//EX_MEM_alu_out; 
					L_1_dependency = 1; 
					end //
				else if(ID_EX_B == EX_MEM_DST && !type_imm && next_type_alu)
					forward_B = 2'b10; //EX_MEM_ alu out
				//L-2
				if(!L_1_dependency) 
				begin
					if(ID_EX_A == MEM_WB_DST && next2_type_alu)
						forward_A = 2'b11; //reg write data
					else if(ID_EX_B == MEM_WB_DST && !type_imm && next2_type_alu)
						forward_B = 2'b11; //reg write data
				end
				
				//lw -> rtype
				if(next2_type_lw)
				begin
					if(ID_EX_A == MEM_WB_DST)
						forward_A = 2'b11; //reg write data
					else if (ID_EX_B == MEM_WB_DST && ! type_imm)
						forward_B = 2'b11; //reg write data
				end
            end
			
		if(type_lw) //rtype -> lw 
			if(EX_MEM_DST != 3'b0) //not $r0
			begin
				if(ID_EX_A == EX_MEM_DST && next_type_alu)//L-1
				begin
					forward_A = 2'b10; //EX_MEM_alu_out
					L_1_dependency = 1'b1;
				end
				else if(ID_EX_A == MEM_WB_DST && !L_1_dependency && next2_type_alu)//L-2
					forward_A = 2'b11;// reg wire data
			end
		
		if(type_sw)//RT-SW
		begin
			// add ($r1), ... -> SW ($r1), ...
			if(ID_EX_DST != 3'b000) // not $r0
			begin
				if(next_type_alu && ID_EX_DST == EX_MEM_DST)//L-1
				begin 
					L_1_dependency = 1'b1;
					forward_mem_EX = 2'b10; //EX/MEM alu out
				end
				else if(!L_1_dependency && next2_type_alu && ID_EX_DST == MEM_WB_DST)//L-2
					forward_mem_EX = 2'b11; // reg write data
			end
			
			// add ($r1), ... -> SW $r0, 100($r1)
			if(ID_EX_A != 3'b000) // not $r0
			begin
				if(next_type_alu && ID_EX_A == EX_MEM_DST)//L-1
				begin 
					L_1_dependency = 1'b1;
					forward_A = 2'b10; //EX/MEM alu out
				end
				else if(!L_1_dependency && next2_type_alu && ID_EX_A == MEM_WB_DST)//L-2
					forward_A = 2'b11; // reg write data
			end
		end	
	end
endmodule