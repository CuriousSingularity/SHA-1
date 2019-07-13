
// possible toplevel framework - SHA1 accelerator 

package state_machine_definitions;

	enum logic [1:0] {__RESET = 2'b00, __IDLE = 2'b01, __PROC = 2'b10, __DONE = 2'b11} state;
	
endpackage

module sha_1(
	input logic clk, reset_n, start,
	input  logic [31:0] in_data [15:0],
	output logic [31:0] out_data [4:0],
	output logic done
	);
	
	import state_machine_definitions::*;
	
	localparam LOOP_ITERATIONS = 80;
	
	localparam ITERATIONS = LOOP_ITERATIONS - 1;
	localparam BITWIDTH   = $clog2(ITERATIONS);

	/* ### start detection ... ################################################
	
						  _______________
			__________|					  |___________
			
						 ^
						 |
						
					  START
	
	*/
	
	logic [3:0] sync_reg = 4'b0000;
	always_ff@(posedge clk)
		begin : start_detection
			if(reset_n == 1'b0)
				sync_reg <= 4'b0000;
			else
				sync_reg <= {sync_reg[2:0],start};
		end : start_detection
			
	logic sync_start; assign sync_start = (sync_reg == 4'b0011) ? 1'b1 : 1'b0;
	
	// ### 'state machine' ... ################################################
	
	logic [1:0] ctrl = 2'd0;
	
	logic latch_complete = 0;
	logic [31:0] in_register[15:0];
	logic [31:0] out_register[4:0];
	
	logic q_done;
	
	sha_1_core inst_0 (
		.clk(clk),
		.enable(latch_complete),
		.data(in_register),
		.q_result(out_register),
		.q_done(q_done)
	);
	
	integer i;
	
	always_ff@(posedge clk) 
		begin : state_machine
			if(reset_n == 1'b0)
				begin
					ctrl          <= 2'd0;
					state			  <= __RESET;
				end
			else
				case(state)
					__RESET: begin
					
						ctrl          <= 2'd0;
						state 		  <= __IDLE;
					end 
					
					__IDLE:  begin
					
						ctrl          <= 2'd1;
						
						if(sync_start)
							begin
								
								// latch the input data
								for (i = 0; i <= 15; i+=1)
									begin 
										in_register[i] <= in_data[i];
									end
									
								latch_complete <= 1'b1;

								state <= __PROC;
								
							end
					end
					
					__PROC:  begin
						
						ctrl          <= 2'd2;
						
						if (q_done)
							begin
								state         <= __DONE;
							end
						else
							begin
								state         <= __PROC;
							end
							
					end
					
					__DONE:  begin
					
						
						ctrl          <= 2'd3;
						
						for(int i = 0; i < 5; i++)
							begin
								out_data[i] <= out_register[i];
							end
						
						done				<= q_done;
						state 		  	<= __IDLE;
					end
					
					default: begin
						ctrl          <= 0;
						state 		  <= __RESET;
					end
					
				endcase
				
		end : state_machine

endmodule 