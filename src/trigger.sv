module trigger(
	input rst,
	input clk,
	input [31:0] [7:0] wr_states,
	input [31:0] trig_mask,
	input [31:0] trig_match,
	input  [4:0] trig_channel,
	input  [2:0] trig_mode,

	output       trig_valid,
    output [2:0] trig_pos
);

reg [7:0] match_state;
reg [7:0] channel_state;

always @(*) begin
	integer i;
	integer j;
	for(i = 0; i < 8; ++i) begin
		match_state[i] = 1;
		for(j = 0; j < 32; ++j) begin
			match_state[i] &= ((wr_states[j][i] && trig_mask[j]) == trig_match[j]);
		end
		channel_state[i] = wr_states[trig_channel][i];
	end
end

reg prev_channel_state;

wire [8:0] combined_match_state = {1'b0, match_state};
wire [8:0] combined_channel_state = {prev_channel_state, channel_state};

always @(posedge clk, posedge rst) begin
	if(rst) begin
		prev_channel_state <= 0;
		trig_valid <= 0;
		trig_pos <= 0;
	end else begin
		integer i;
		trig_valid = 0;
		trig_pos = 0;
		prev_channel_state <= channel_state[7];
		for(i = 1; i <= 8; ++i) begin
			reg trig;
			case(trig_mode)
				3'h0   : trig = 1;
				3'h1   : trig = !combined_channel_state[i - 1] && combined_channel_state[i];
				3'h2   : trig = combined_channel_state[i - 1] && !combined_channel_state[i];
				3'h3   : trig = combined_channel_state[i - 1] != combined_channel_state[i];
				3'h4   : trig = combined_channel_state[i];
				3'h5   : trig = !combined_channel_state[i];
				default: trig = 0;
			endcase
			if(trig && combined_match_state[i]) begin
				trig_valid = 1;
				trig_pos = i - 1;
				break;
			end
		end
	end
end

endmodule
