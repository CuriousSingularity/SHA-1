

`timescale 1ns/1ps

`define HALF_CLOCK_PERIOD   			10
`define RESET_PERIOD 	   			100
`define DELAY 	    		   			200
`define START_PULSE_START_TIME		150
`define START_PULSE_END_TIME			(4*`HALF_CLOCK_PERIOD)
`define SIM_DURATION 					5000


module state_machine_toplevel_framework_tb();

	logic tb_q_start;
	logic tb_q_done;
	logic [1:0] tb_q_state;

	
	logic [31:0] tb_q_test[22:0];
	
	assign tb_q_test[0] = 1;
	assign tb_q_test[1] = 0;
	assign tb_q_test[2] = 32'h61626380;
	assign tb_q_test[3] = 0;
	assign tb_q_test[4] = 0;
	assign tb_q_test[5] = 0;
	assign tb_q_test[6] = 0;
	assign tb_q_test[7] = 0;
	assign tb_q_test[8] = 0;
	assign tb_q_test[9] = 0;
	assign tb_q_test[10] = 0;
	assign tb_q_test[11] = 0;
	assign tb_q_test[12] = 0;
	assign tb_q_test[13] = 0;
	assign tb_q_test[14] = 0;
	assign tb_q_test[15] = 0;
	assign tb_q_test[16] = 0;
	assign tb_q_test[17] = 32'h18;
	assign tb_q_test[18] = 0;
	assign tb_q_test[19] = 0;
	assign tb_q_test[20] = 0;
	assign tb_q_test[21] = 0;
	assign tb_q_test[22] = 0;
	
	
	// ### clock generation process ...
   logic tb_local_clock = 0;
 	initial 
		begin: clock_generation_process
			tb_local_clock = 0;
				forever begin
					#`HALF_CLOCK_PERIOD tb_local_clock = ~tb_local_clock;
				end
		end	

	logic tb_start = 1; logic tb_local_reset_n = 0;
	
	integer i = 0; 

	initial 
		begin: reset_generation_process
			$display ("Simulation starts ...");
			// reset assertion ... 
			#`RESET_PERIOD tb_local_reset_n = 1'b1;
			#`START_PULSE_START_TIME tb_start = 1'b1;
			#`START_PULSE_END_TIME tb_start = 1'b0;
			
			#`SIM_DURATION
			$display ("Simulation done ...");
			$display ("Memory Layout");
			
			for (int index = 0; index <= 22; index++)
				$display("%h %h", index, tb_q_test[index]);
			
			$stop();
		end
		
		
	state_machine_toplevel_framework dut_inst_0(.clk(tb_local_clock),
															  .reset_n(tb_local_reset_n),
															  .start(tb_start),
															  .q_start(tb_q_start),
															  .q_complete(tb_q_done),
															  .q_state(tb_q_state),
															  .config_status_1(tb_q_test[0]),
															  .config_status_2(tb_q_test[1]),
															  .writedata(tb_q_test[17 : 2]),
															  .readdata(tb_q_test[22 : 18]));
	
	
	// for illustration purposes only, make sure that radix in the Modelsim-Waveform Viewer
	// to the ASCII format ... 
	
	logic [12*8:1] state_string;		// ASCII string ...
	
	always@(tb_q_state)
		case(tb_q_state)
			2'b00: state_string = "RESET_STATE";
			2'b01: state_string = "IDLE_STATE";
			2'b10: state_string = "PROC_STATE";
			2'b11: state_string = "DONE_STATE";
		endcase		
														
endmodule 