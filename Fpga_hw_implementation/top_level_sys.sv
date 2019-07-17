module top_level_sys(
	(* chip_pin = "AF14" *) input logic clk,
	(* chip_pin =  "AJ4" *) input logic reset_n, 
	(* chip_pin = "AF24, AE24, AF25, AG25, AD24, AC23, AB23, AA24" *) output logic [7:0] leds,
	// DE10-Standard - Switches
	(* chip_pin =  "AA30, AC29, AD30, AC28, V25, W25, AC30, AB28, Y27, AB30" *) input logic [9:0] switches,
	// DE10-Standard - Some GPIOs
	(* chip_pin =  "AK2, W15" *) output logic [1:0] gpio
	);		
	
	logic nios_pwm_output;
	logic [7:0] nios_led_output;
	
	// instantiate the Nios right here ..., use the upper signals to interface the onboard LEDs 
	
		base_sys u0 (
		.clk_clk                         (clk),                         //        clk.clk
		.pio_input_export                (gpio[0]),                //  pio_input.export
		.pio_leds_export                 (nios_led_output),                 //   pio_leds.export
		.reset_reset_n                   (reset_n),                   //      reset.reset_n
		.time_out_export                 (gpio[1]),                 //   time_out.export
		//.pwm_output_writeresponsevalid_n (nios_pwm_output)  // pwm_output.writeresponsevalid_n
	);	
	
	//assign leds = switches[0] ? nios_led_output : {8{nios_pwm_output}};
	
endmodule 