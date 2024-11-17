module mux_sync_mux(
	input clk_i,
	input rstn_i,
	input [15:1] input_i,
	input [3:0] input_sel_s,
	input sw_in_i,
	input [1:0] trigger_selection_i,
	input [1:0] capture_selection_i,
	output reg mux2_output_o,
	output reg fir_capture_o
);

	reg dff1_output;
	reg dff2_output;
	reg dff3_output;
	
	reg pos_edge;
	reg neg_edge;
	reg pos_neg_edge;
	
	reg fir_trigger;
	reg mux1_output;
	
	always@(*) begin
		case(input_sel_s)
			4'd1: mux1_output = input_i[1];
			4'd2: mux1_output = input_i[2];
			4'd3: mux1_output = input_i[3];
			4'd4: mux1_output = input_i[4];
			4'd5: mux1_output = input_i[5];
			4'd6: mux1_output = input_i[6];
			4'd7: mux1_output = input_i[7];
			4'd8: mux1_output = input_i[8];
			4'd9: mux1_output = input_i[9];
			4'd10: mux1_output = input_i[10];
			4'd11: mux1_output = input_i[11];
			4'd12: mux1_output = input_i[12];
			4'd13: mux1_output = input_i[13];
			4'd14: mux1_output = input_i[14];
			4'd15: mux1_output = input_i[15];
			default: mux1_output = 0;
			endcase
	end	
	
	assign pos_edge = (dff3_output == 1 && dff2_output == 0); //RISING EDGE
	assign neg_edge = (dff3_output == 0 && dff2_output == 1); //FALLING EDGE
	assign pos_neg_edge = dff3_output ^ dff2_output; //RISING & FALLING EDGE
	
	always@(*) begin
		case(trigger_selection_i) 
			2'b00: fir_trigger = pos_edge;
			2'b01: fir_trigger = neg_edge;
			2'b10: fir_trigger = pos_neg_edge;
			2'b11: fir_trigger = 0;
			default: fir_trigger = pos_edge;
		endcase
	end
	
	always@(*) begin
		case(capture_selection_i)
			2'b00: fir_capture_o = pos_edge;
			2'b01: fir_capture_o = neg_edge;
			2'b10: fir_capture_o = pos_neg_edge;
			2'b11: fir_capture_o = 0;
			default: fir_capture_o = pos_edge;
		endcase
	end
	
	// always@(negedge rstn_i) begin
		// if(!rstn_i)
			// trigger_selection_i <= 0;
	// end
	
	always@(*) begin
		if(input_sel_s == 0)
			mux2_output_o = sw_in_i;
		else 	
			mux2_output_o = fir_trigger;
	end
	
	always@(posedge clk_i) begin
		dff1_output <= mux1_output;
	end

	always@(posedge clk_i) begin
		dff2_output <= dff1_output;
	end
	
	always@(posedge clk_i) begin
		dff3_output <= dff2_output;
	end
	
endmodule