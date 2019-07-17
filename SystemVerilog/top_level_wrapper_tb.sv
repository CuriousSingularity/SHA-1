

`timescale 1ns/1ps

`define HALF_CLOCK_PERIOD   			10
`define FULL_CLOCK_PERIOD   			20
`define RESET_PERIOD 	   			100
`define DELAY 	    		   			200
`define START_PULSE_START_TIME		150
`define START_PULSE_END_TIME			(4*`HALF_CLOCK_PERIOD)
`define SIM_DURATION 					50000


module top_level_wrapper_tb();

	logic tb_q_done;
	
	logic [31:0] tb_q_test[21:0];
//	
//	assign tb_q_test[0] = 1;
//	assign tb_q_test[1] = 32'h61626380;
//	assign tb_q_test[2] = 0;
//	assign tb_q_test[3] = 0;
//	assign tb_q_test[4] = 0;
//	assign tb_q_test[5] = 0;
//	assign tb_q_test[6] = 0;
//	assign tb_q_test[7] = 0;
//	assign tb_q_test[8] = 0;
//	assign tb_q_test[9] = 0;
//	assign tb_q_test[10] = 0;
//	assign tb_q_test[11] = 0;
//	assign tb_q_test[12] = 0;
//	assign tb_q_test[13] = 0;
//	assign tb_q_test[14] = 0;
//	assign tb_q_test[15] = 0;
//	assign tb_q_test[16] = 32'h18;
//	assign tb_q_test[17] = 0;
//	assign tb_q_test[18] = 0;
//	assign tb_q_test[19] = 0;
//	assign tb_q_test[20] = 0;
//	assign tb_q_test[21] = 0;
//	
	
	// ### clock generation process ...
   logic tb_local_clock = 0;
 	initial 
		begin: clock_generation_process
			tb_local_clock = 0;
				forever begin
					#`HALF_CLOCK_PERIOD tb_local_clock = ~tb_local_clock;
				end
		end	

	logic tb_write = 1, tb_read = 0; logic tb_local_reset_n = 0;
	logic [31:0] tb_address = 0;
	logic [31:0] tb_readdata = 0;
	logic [31:0] tb_writedata = 0;
	
	integer i = 0, index = 0; 

	initial 
		begin: reset_generation_process
			$display ("Simulation starts ...");
			// reset assertion ... 
			#`RESET_PERIOD tb_local_reset_n = 1'b1;
						
			tb_q_test[0]  <= 1;
			tb_q_test[1]  <= 32'h61626380;
			tb_q_test[2]  <= 0;
			tb_q_test[3]  <= 0;
			tb_q_test[4]  <= 0;
			tb_q_test[5]  <= 0;
			tb_q_test[6]  <= 0;
			tb_q_test[7]  <= 0;
			tb_q_test[8]  <= 0;
			tb_q_test[9]  <= 0;
			tb_q_test[10] <= 0;
			tb_q_test[11] <= 0;
			tb_q_test[12] <= 0;
			tb_q_test[13] <= 0;
			tb_q_test[14] <= 0;
			tb_q_test[15] <= 0;
			tb_q_test[16] <= 32'h18;
			tb_q_test[17] <= 0;
			tb_q_test[18] <= 0;
			tb_q_test[19] <= 0;
			tb_q_test[20] <= 0;
			tb_q_test[21] <= 0;

			#`FULL_CLOCK_PERIOD ;
			
			for (index = 1; index <= 16; index++)
				begin
					tb_address = index;
					tb_writedata = tb_q_test[index];
					#`FULL_CLOCK_PERIOD ;
				end
			
			tb_address = 0;
			tb_writedata = tb_q_test[0];
			tb_write = 1;
			#(`FULL_CLOCK_PERIOD * 120);
			
			tb_write = 0;
			tb_read = 1;
			for (index = 17; index <= 21; index++)
				begin
					tb_address = index;
					#`FULL_CLOCK_PERIOD ;
					tb_q_test[index] = tb_readdata;
				end
			
			#`SIM_DURATION
			$display ("Simulation done ...");
			$display ("Memory Layout");
				
			for (int index = 0; index <= 21; index++)
				$display("%h %h", index, tb_q_test[index]);
				
			$stop();
		end
		
	top_level_wrapper inst_0_top_level_wrapper(
									.clk(tb_local_clock),
									.reset_n(tb_local_reset_n),
									.write(tb_write),
									.read(tb_read),
									.writedata(tb_writedata),
									.address(tb_address),
									.readdata(tb_readdata));
	
endmodule 