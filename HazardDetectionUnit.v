module HazardDetectionUnit (input clk,reset,  input [18:0]instruction, IF_ID_instruction, input do_branch, output reg IF_ID_loadbar, IF_ID_flush, ID_EX_flush, pc_writebar);
	always@(posedge clk, reset) begin
		{IF_ID_loadbar, ID_EX_flush, pc_writebar} = 0;
		if(~reset)begin 
			//stall 
			if(IF_ID_instruction[18:14] == 5'b10000 &&
			!(instruction[18:14]== 5'b10001 && IF_ID_instruction[13:11] == instruction [13:11] ) &&
			(IF_ID_instruction[13:11] == instruction[10:8] || IF_ID_instruction[13:11] == instruction[7:5]) && 
			IF_ID_instruction[13:11] != 3'b0 &&
			(instruction[18] == 1'b0 || instruction[18:16] == 3'b100)
			)
				begin pc_writebar = 1'b1; IF_ID_loadbar = 1'b1; ID_EX_flush = 1'b1; end 
		end
	end

	always@(posedge clk, reset, do_branch) begin
		IF_ID_flush = 1'b0;
		//flush 
		if(~reset)
			if(IF_ID_instruction [18:16] == 3'b111 || (IF_ID_instruction[18:16] == 3'b101 && do_branch))
				IF_ID_flush = 1'b1;
	end
	
	/*
	reg [1:0] hazard_state, jmp_state;
	always @(clk, reset) begin//state
		if(reset)
			{hazard_state, jmp_state} = 2'b0;//#
		if(hazard_state > 2'b0)
			hazard_state = hazard_state + 1'b1;
		if(jmp_state > 2'b0)
			jmp_state = jmp_state +1'b1;
		//$display ("hazard @%t : clk %b,  hazard_state %d",$time,  clk, hazard_state);
		$display ("jmp hazard @%t : clk %b,  jmp_state %d",$time,  clk, jmp_state);
	end
	
	always@(hazard_state) begin//output flags
		{IF_ID_loadbar, ID_EX_flush, IF_ID_flush, pc_writebar} = 0;	
		if(hazard_state == 2'b10|| hazard_state == 2'b01)
			pc_writebar  = 1'b1;
		if (hazard_state == 2'b10)
			IF_ID_flush = 1'b1;
	end
<<<<<<< Updated upstream
	
=======
	/*
>>>>>>> Stashed changes
	always@(jmp_state)
	begin
		IF_ID_loadbar = 1'b0;
		IF_ID_flush = 1'b0;
		if(jmp_state == 2'b10 || jmp_state == 2'b01)
			IF_ID_loadbar = 1'b1;
		if (jmp_state == 2'b10)
			IF_ID_flush = 1'b1;
	end
<<<<<<< Updated upstream
	
=======
	*/
>>>>>>> Stashed changes
	always@(*) begin//deciding conditions
		//jmp_state = 2'b0;
		//stall 
		if(IF_ID_instruction[18:14] == 5'b10000 &&
		!(instruction[18:14]== 5'b10001 && IF_ID_instruction[13:11] == instruction [13:11] ) &&
		(IF_ID_instruction[13:11] == instruction[10:8] || IF_ID_instruction[13:11] == instruction[7:5]) && 
		IF_ID_instruction[13:11] != 3'b0 &&
		(instruction[18] == 1'b0 || instruction[18:16] == 3'b100)
		)
		begin
			/*$display("Hazard time %t", $time);
			$display("inst  %b\nIF_ID %b", instruction[18:14], IF_ID_instruction[18:14]);
			$display("IF_ID dst %b", IF_ID_instruction[13:11]);
			$display("inst A %b, B %b", instruction[10:8], instruction[7:5]);*/
			//pc_writebar = 1'b1; IF_ID_loadbar = 1'b1; ID_EX_flush = 1'b1; 
	/*		hazard_state = 2'b01;
		end 
			
		//flush 
		if(IF_ID_instruction [18:16] == 3'b111 || (IF_ID_instruction[18:16] == 3'b101 && do_branch))
			jmp_state = 2'b01;
	end
	*/
endmodule