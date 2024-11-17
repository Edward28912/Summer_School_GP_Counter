module general_purpose_counter(
	input clk_i,
	input rstn_i,
	
	//PWM MODE
	input [1:0] mode_i,
	input [9:0] duty_cycle_i,
	input [1:0] frequency_selection_i,
	
	//COUNTER MODE 
	input input_signal_i,
	input out_function_i,
	input [9:0] target_value_i,
	input clear_i,
	output [9:0] counter_o,

	//CAPTURE
	input capture_signal_i,
	output reg tm_running_o,
	output reg [9:0] captured_value_o,

	output reg output_o
);
	
	reg [8:0] pre_counter; // USED FOR PWM
	reg [8:0] pre_counter_target; //USED FOR PWM
	
	reg [9:0] counter;
	
	always@(*) begin
		case(frequency_selection_i)
			2'b00: pre_counter_target = 399; //100Hz
			2'b01: pre_counter_target = 199; //200Hz
			2'b10: pre_counter_target = 124; //320Hz
			2'b11: pre_counter_target = 99; //400Hz
			default: pre_counter_target = 399;
		endcase
	end	
	
	always@(posedge clk_i, negedge rstn_i) begin
		if(!rstn_i) begin
			output_o <= 0;
			counter <= 0;
			pre_counter <= 0;
		end
		else if((mode_i == 2'b10 && counter == target_value_i) || (mode_i == 2'b11 && counter == target_value_i) || clear_i)
			counter <= 0;
		else begin
			case(mode_i)
				2'b00: output_o <= 0; // DISABLED MODE
				
				2'b01: begin // PWM MODE
					if(pre_counter == pre_counter_target) begin
						pre_counter <= 0;
						counter <= counter + 1'b1;
					end 
					else 
						pre_counter <= pre_counter + 1'b1;
				end
				
				2'b10: begin //COUNTER MODE
					if(input_signal_i == 1) begin
						counter <= counter + 1'b1;
						tm_running_o = 1;
					end else
						tm_running_o <= 0;
				end
				
				2'b11: begin //TIMER MODE
					if(input_signal_i == 1) 
						counter <= 1;
					else if(counter > 0) begin
						counter <= counter + 1'b1;
						tm_running_o <= 1;
					end
					else begin
						tm_running_o <= 0;
					end
				end
				
				default: output_o <= 0;
			endcase
		end
	end
	
	always@(*) begin
		if(mode_i == 2'b10 || mode_i == 2'b11)
			assign captured_value_o = (capture_signal_i) ? counter : 0;
	end
	
	always@(posedge clk_i) begin
		if(mode_i == 2'b10 || mode_i == 2'b11) begin
			case(out_function_i)
				1'b0: begin
					output_o <= (counter == target_value_i);					
				end
				1'b1: begin
					if(counter == target_value_i) 
						output_o <= ~output_o;
				end
			endcase
		end
	end
	
	always@(posedge clk_i) begin
	   if(mode_i == 2'b01) begin
            if(duty_cycle_i == 0)
				output_o = 0;
			else if(duty_cycle_i == 1023)
				output_o = 1;
			else if(counter < duty_cycle_i)
				output_o = 1;
			else
				output_o = 0;
	end
end
	
	assign counter_o = counter;
	
endmodule
