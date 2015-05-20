module HazardDetectionUnit (input [18:0]instruction, IF_ID_instruction, input do_branch, output reg IF_ID_loadbar, IF_ID_flush, ID_EX_flush, pc_writebar);

	always@(*) begin
		{IF_ID_loadbar, IF_ID_flush, ID_EX_flush, pc_writebar} = 0;
		//stall 
		if(IF_ID_instruction[18:14] == 5'b10000 &&
		!(instruction[18:14]== 5'b10001 && IF_ID_instruction[13:11] == instruction [13:11] ) &&
		(IF_ID_instruction[13:11] == instruction[10:8] || IF_ID_instruction[13:11] == instruction[7:5]) && 
		IF_ID_instruction[13:11] != 3'b0 &&
		(instruction[18] == 1'b0 || instruction[18:16] == 3'b100)
		)
			begin pc_writebar = 1'b1; IF_ID_loadbar = 1'b1; ID_EX_flush = 1'b1; end 
			
		//flush 
		if(IF_ID_instruction [18:16] == 3'b111 || (IF_ID_instruction[18:16] == 3'b101 && do_branch))
			IF_ID_flush = 1'b1;
	end
endmodule