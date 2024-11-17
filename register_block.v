module register_block(
	input clk_i,
	input rstn_i,
	input acc_en_i,
	input wr_en_i,
	input [2:0] addr_i,
	input [15:0] wdata_i,
	input [9:0] counter_i,
	input [9:0] captured_value_i,
	input tm_running_i,
	output reg [15:0] rdata_o,
	output [1:0] mode_o,
	output [9:0] duty_cycle_o,
	output [1:0] frequency_selection_o,
	output [3:0] input_selection_o,
	output [1:0] trigger_selection_o,
	output out_function_o,
	output [1:0] capture_selection_o,
	output [9:0] target_value_o,
	output clear_o,
	output sw_trigger_o
);
	
	reg [15:0] CTRL0;
	reg [15:0] PWM_MODE;
	reg [15:0] CNT_TIMER_MODE0;
	reg [15:0] CNT_TIMER_MODE1;
	reg [15:0] ACT_CNT_VALUE;
	reg [15:0] COMMAND;
	reg [15:0] CAPTURE_STATUS;
	
	always@(posedge clk_i, negedge rstn_i) begin
		if(!rstn_i) begin
			CTRL0 <= 0;
			PWM_MODE <= 0;
			CNT_TIMER_MODE0 <= 0;
			CNT_TIMER_MODE1 <= 0;
			ACT_CNT_VALUE <= 0;
			COMMAND <= 0;
			CAPTURE_STATUS <= 0;
		end
		else begin
			if(acc_en_i && wr_en_i) begin
				case(addr_i) 
					3'b000: CTRL0 <= wdata_i;
					3'b001: PWM_MODE <= wdata_i ;
					3'b010: CNT_TIMER_MODE0 <= wdata_i;
					3'b011: CNT_TIMER_MODE1 <= wdata_i;
					3'b101: COMMAND <= wdata_i;
				endcase
			end
		end
	end
		
	always@(*) begin
		if(!rstn_i) 
			rdata_o = 0;
		else begin
			if(acc_en_i && !wr_en_i) begin
				case(addr_i) 
					3'b000: rdata_o = {14'b00_0000_0000_0000, mode_o};
					3'b001: rdata_o = {2'b00, frequency_selection_o, 2'b00, duty_cycle_o};	
					3'b010: rdata_o = {2'b00, capture_selection_o, 3'b000, out_function_o, 2'b00, trigger_selection_o, input_selection_o};
					3'b011: rdata_o = {6'b00_0000, target_value_o};
					3'b100: rdata_o = {6'b00_0000, counter_i};
					3'b110: rdata_o = {3'b000, tm_running_i, 2'b00, captured_value_i};
					default: rdata_o= 0;
				endcase
			end else
				rdata_o = 0;
			end
		end
	
	assign mode_o 					= CTRL0[1:0];
	assign duty_cycle_o 			= PWM_MODE[9:0];
	assign frequency_selection_o 	= PWM_MODE[13:12];
	assign input_selection_o		= CNT_TIMER_MODE0[3:0];
	assign trigger_selection_o 		= CNT_TIMER_MODE0[5:4];
	assign out_function_o 			= CNT_TIMER_MODE0[8];
	assign capture_selection_o		= CNT_TIMER_MODE0[13:12];
	assign target_value_o			= CNT_TIMER_MODE1[9:0];
	assign sw_trigger_o 			= COMMAND[4];
	assign clear_o					= COMMAND[0];
		
	// assign sw_trigger_o = (acc_en_i && wr_en_i && addr_i == 3'b101 && wdata_i[4]); //COMMAND register
	// assign clear_o = (acc_en_i && wr_en_i && addr_i == 3'b101 && wdata_i[0]); //COMMAND register
	
endmodule
