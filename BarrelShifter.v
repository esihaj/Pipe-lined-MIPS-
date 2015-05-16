module BarrelShifter (input [7:0] data,input [2:0] bitcount, input dir, ro_shBar,
											output reg [7:0] out, output reg c, z );
			reg [15:0] tmp;
			always@(data,bitcount,dir, ro_shBar)begin 
				//R => 1 , L =>0
				out = data; c = 0;
				if(bitcount >0) begin
					if(dir)begin // Right 
						if(ro_shBar)begin
							tmp = {data,data};
							out = tmp[bitcount +: 8];
							c = data[bitcount - 3'b1];
							//out = {data[bitcount-3'b1 +:bitcount],tmp[4'd8-bitcount +:bitcount]};
						end
						else begin
							out = data >> bitcount;
							c = data[bitcount - 3'b1];
						end
					end
					else begin // Left
						if(ro_shBar)begin
							tmp = {data,data};
							out =  tmp[4'd15 - bitcount -: 8];
							c = data[4'd8 - bitcount];
							//out = {tmp[3'd7 +: 4'd8-bitcount],data[3'd7 +:bitcount]};
						end
						else begin
							out = data << bitcount;
							c = data[4'd8 - bitcount];
						end
					end
				end
		
				z = (out == 0);
			end
endmodule

module test_shift();
	reg [7:0] data; 
	reg [2:0] bitcount;
	reg dir, ro_shBar;
	wire [7:0] out;
	wire c, z;
	BarrelShifter bs(data, bitcount,  dir, ro_shBar, out, c, z );
	
	initial begin 
	data = 8'b10101111; bitcount = 1'b0; dir = 1'b1; ro_shBar = 1'b1;
	#10 	bitcount = 3'd1;
	#10 bitcount = 3'd2;
	#100 ro_shBar = 1'b0; bitcount = 3'd1;
	#10 bitcount = 3'd2;
	#100 bitcount = 3'd1; dir = 1'b0; ro_shBar = 1'b1;
	#10 bitcount = 3'd2;
	#100 bitcount = 3'd1; ro_shBar = 1'b0;
	#10 bitcount = 3'd2;
	#10;
	end

endmodule