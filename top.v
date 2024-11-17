module top(
	input clk_i,
	input rstn_i,
	input acc_en_i,
	input wr_en_i,
	input [2:0] addr_i,
	input [15:0] wdata_i,
	input [15:1] input_i,
	output [15:0] rdata_o,
	output output_o
);
	
	wire [9:0] count;
	wire [9:0] captured_value;
	wire tm_running;
	wire [1:0] mode;
	wire [9:0] duty_cycle;
	wire [1:0] freq_sel;
	wire [3:0] input_sel;
	wire [1:0] trigger_sel;
	wire out_function;
	wire [1:0] capture_selection;
	wire [9:0] target_value;
	wire clear;
	wire sw_trigger;
	wire sync_module_out;
	wire capture_signal;
	
	register_block register_block_module(
		.clk_i					(clk_i),
		.rstn_i					(rstn_i),
		.acc_en_i				(acc_en_i),
		.wr_en_i				(wr_en_i),
		.addr_i					(addr_i),
		.wdata_i				(wdata_i),
		.counter_i				(count),
		.captured_value_i		(captured_value),
		.tm_running_i			(tm_running),
		.rdata_o				(rdata_o),
		.mode_o					(mode),
		.duty_cycle_o			(duty_cycle),
		.frequency_selection_o	(freq_sel),
		.input_selection_o		(input_sel),
		.trigger_selection_o	(trigger_sel),
		.out_function_o			(out_function),
		.capture_selection_o	(capture_selection),
		.target_value_o			(target_value),
		.clear_o				(clear),
		.sw_trigger_o			(sw_trigger)
	);
	
	mux_sync_mux mux_sync_mux_module(
		.clk_i					(clk_i),
		.rstn_i					(rstn_i),
		.input_i				(input_i),
		.input_sel_s			(input_sel),
		.sw_in_i				(sw_trigger),
		.trigger_selection_i	(trigger_sel),
		.capture_selection_i	(capture_selection),
		.fir_capture_o			(capture_signal),
		.mux2_output_o			(sync_module_out)
	);
	
	general_purpose_counter general_purpose_counter_module(
		.clk_i					(clk_i),
		.rstn_i					(rstn_i),
		.mode_i					(mode),
		.duty_cycle_i			(duty_cycle),
		.frequency_selection_i	(freq_sel),
		.input_signal_i			(sync_module_out),
		.out_function_i			(out_function),
		.target_value_i			(target_value),
		.clear_i				(clear),
		.capture_signal_i		(capture_signal),
		.tm_running_o			(tm_running),
		.captured_value_o		(captured_value),
		.counter_o				(count),
		.output_o				(output_o)
	);
	
endmodule