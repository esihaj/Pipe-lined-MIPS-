module HazardDetectionUnit (input clk,reset,  input [18:0]instruction, IF_ID_instruction, input do_branch, output reg IF_ID_loadbar, IF_ID_flush, ID_EX_flush, pc_writebar);
	reg [1:0] state, next_state;
	reg hazard;
	always@(reset)
	begin
		hazard = 1'b0;
		state = 2'b0;
	end
	
	always @(clk) begin
		
		if(~hazard)
			state = 2'b0;
		else if(hazard)
			state = state + 1'b1;
		if(state == 2'b0)
			hazard = 1'b0;
			
		$display ("hazard @%t : clk %b, hazard %b, state %d",$time,  clk, hazard, state);
	end
	
	always@(hazard) begin
		{IF_ID_loadbar, ID_EX_flush, pc_writebar} = 0;	
		if(hazard)
			{IF_ID_loadbar, ID_EX_flush, pc_writebar}  = 3'b111;
	end
	
	always@(*) begin
		IF_ID_flush = 1'b0;
		//stall 
		if(IF_ID_instruction[18:14] == 5'b10000 &&
		!(instruction[18:14]== 5'b10001 && IF_ID_instruction[13:11] == instruction [13:11] ) &&
		(IF_ID_instruction[13:11] == instruction[10:8] || IF_ID_instruction[13:11] == instruction[7:5]) && 
		IF_ID_instruction[13:11] != 3'b0 &&
		(instruction[18] == 1'b0 || instruction[18:16] == 3'b100)
		)
		begin
			$display("Hazard time %t", $time);
			$display("inst  %b\nIF_ID %b", instruction[18:14], IF_ID_instruction[18:14]);
			$display("IF_ID dst %b", IF_ID_instruction[13:11]);
			$display("inst A %b, B %b", instruction[10:8], instruction[7:5]);
			//pc_writebar = 1'b1; IF_ID_loadbar = 1'b1; ID_EX_flush = 1'b1; 
			hazard = 1'b1;
			state = 2'b01;
		end 
			
		//flush 
		if(IF_ID_instruction [18:16] == 3'b111 || (IF_ID_instruction[18:16] == 3'b101 && do_branch))
			IF_ID_flush = 1'b1;
	end
endmodule