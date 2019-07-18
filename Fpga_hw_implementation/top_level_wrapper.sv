
module top_level_wrapper(
	input logic clk, reset_n,
	input logic write, read,
	input logic [31:0] writedata, 
	input logic [31:0] address,
	output logic [31:0] readdata
	);
	
	logic [31:0] register [21:0];
	
	integer i;
	
	logic start = 0, stop = 0;
	logic [31:0] in_register[15:0];
	logic [31:0] out_register[4:0];
	
	sha_1 inst_sha_1_0 (
		.clk(clk), 
		.reset_n(reset_n), 
		.start(start),
		.in_data(in_register),
		.out_data(out_register),
		.done(stop)
	);
	
	
	integer start_pulse_count = 0;
	
	always_ff@(posedge clk) 
		begin : data_capture
			if(reset_n == 1'b0)
				begin
					for(i = 0;i <= 21; i = i+1) begin: clear_register_set
						register[i] <= 32'd0;
					end
				end
			else
				begin
					if(write)
						begin
							case(address)
							0: register[0] <= writedata;
							1: register[1] <= writedata;
							2: register[2] <= writedata;
							3: register[3] <= writedata;
							4: register[4] <= writedata;
							5: register[5] <= writedata;
							6: register[6] <= writedata;
							7: register[7] <= writedata;
							8: register[8] <= writedata;
							9: register[9] <= writedata;
							10: register[10] <= writedata;
							11: register[11] <= writedata;
							12: register[12] <= writedata;
							13: register[13] <= writedata;
							14: register[14] <= writedata;
							15: register[15] <= writedata;
							16: register[16] <= writedata;
							default: ;
							endcase
						end
					else
						begin
							if (stop)
								begin
									register[17] <= out_register[0];
									register[18] <= out_register[1];
									register[19] <= out_register[2];
									register[20] <= out_register[3];
									register[21] <= out_register[4];
									register[0][1]  <= stop;
									start_pulse_count <= 0;
								end
						end
						
					if (start_pulse_count < 2)
						if (register[0][0])
						begin
							start 	<= 1'b1;
							in_register = register[16:1];
							start_pulse_count 		<= start_pulse_count + 1;
						end
					else
						start 	<= 1'b0;
				end
						
		end : data_capture
	
	always_comb
		begin
			if(read)
			begin
				case(address)
					0: readdata = register[0];
					1: readdata = register[1];
					2: readdata = register[2];
					3: readdata = register[3];
					4: readdata = register[4];
					5: readdata = register[5];
					6: readdata = register[6];
					7: readdata = register[7];
					8: readdata = register[8];
					9: readdata = register[9];
					10: readdata = register[10];
					11: readdata = register[11];
					12: readdata = register[12];
					13: readdata = register[13];
					14: readdata = register[14];
					15: readdata = register[15];
					16: readdata = register[16];
					17: readdata = register[17];
					18: readdata = register[18];
					19: readdata = register[19];
					20: readdata = register[20];
					21: readdata = register[21];
					default: readdata = register[0];
				endcase
			end
			else
				readdata = 0;
		end
		
endmodule 