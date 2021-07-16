module capture_channel_mapper(
	input rst,
	input clk,
	input [2:0] channels, // Total channels = 2^channels
	input [31:0] [7:0] wr_states,
	input       trig_valid,
	input [2:0] trig_pos,

	output reg         out_valid,
	output reg [255:0] out_data,

	output reg         triggered,
	output reg   [7:0] trig_sample
);

reg [4:0] valid_ctr;

always @(posedge clk, posedge rst) begin
	if(rst) begin
		out_valid <= 0;
		out_data <= 0;
		trig_sample <= 0;
		valid_ctr <= 0;
		triggered <= 0;
	end else begin
		case(channels)
			0: out_data <= {out_data[247:0], wr_states[0:0]};
			1: out_data <= {out_data[239:0], wr_states[1:0]};
			2: out_data <= {out_data[223:0], wr_states[3:0]};
			3: out_data <= {out_data[191:0], wr_states[7:0]};
			4: out_data <= {out_data[127:0], wr_states[15:0]};
			5: out_data <= wr_states[31:0];
			default: out_data <= 0;
		endcase

		valid_ctr = valid_ctr + 5'h1;

		case(channels)
			0: out_valid = (valid_ctr & 5'b11111) == 0;
			1: out_valid = (valid_ctr & 5'b01111) == 0;
			2: out_valid = (valid_ctr & 5'b00111) == 0;
			3: out_valid = (valid_ctr & 5'b00011) == 0;
			4: out_valid = (valid_ctr & 5'b00001) == 0;
			5: out_valid = 1;
			default: out_valid = 0;
		endcase

		if(out_valid) begin
			triggered = 0;
		end

		if(trig_valid && !triggered) begin
			triggered = 1;
			trig_sample = {valid_ctr, trig_pos};
		end
	end
end

endmodule

