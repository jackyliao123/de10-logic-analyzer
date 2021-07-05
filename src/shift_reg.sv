module shift_reg(
	input rst,
	input clk,
	input channel,
	input clk_div8,
	output reg [7:0] out
);

reg [7:0] shift;
always_ff @(posedge clk, posedge rst) begin
	if(rst) begin
		shift <= 0;
	end else begin
		shift <= {shift[6:0], channel};
	end
end

always_ff @(posedge clk_div8, posedge rst) begin
	if(rst) begin
		out <= 0;
	end else begin
		out <= shift;
	end
end

endmodule
