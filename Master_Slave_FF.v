//Master Slave Flip FLop with asynchronous reset (works on all of 1 side not just edges)
 
module M_S_FF #(parameter width =1)(input clk, enable_bar, rst,[width-1:0]in, output reg [width-1:0] out);
	reg [width-1:0] middle;
	
	always@(clk, in, rst)begin 
		if(rst)
			begin middle = 0; out = 0; end
		else if(~enable_bar) begin//@LATER: how is this implemented in hardware ?
			if(clk)
				middle = in;
			if(~clk)
				out = middle;
		end
	end
endmodule

module test_M_S_FF();
	reg [7:0] in;
	wire [7:0] out;
	wire out2;
	reg clk=1 , rst=0;
	M_S_FF #(8) ins1(clk, 1'b0, rst,in,out);
	M_S_FF ins2 (clk, 1'b0, rst,in,out2);
	initial repeat(100) #10 clk = ~clk;
	
	initial begin 
		in = 8'd10;
		#60 in = 8'd127;
		#65 rst = 1;
		#10 rst =0;
		#60 $stop;
	end
endmodule
