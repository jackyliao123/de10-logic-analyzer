module capture_frontend (
	input rst,
	input clk,
	input [31:0] channels,
	output clk_div8,
	output reg [31:0] [7:0] wr_states
);

//genvar i;
//generate
//	for(i = 0; i < 32; ++i) begin: sr_gen_loop
//		shift_reg sr(
//			.rst(rst),
//			.clk(clk),
//			.channel(channels[i]),
//			.clk_div8(clk_div8),
//			.out(wr_states[i])
//		);
//	end
//endgenerate

reg [31:0] [7:0] states;

always @(posedge clk, posedge rst) begin
	if(rst) begin
		states <= 0;
	end else begin
		integer i;
		for(i = 0; i < 32; ++i) begin
			states[i] <= {states[i][6:0], channels[i]};
		end
	end
end

reg [3:0] clk_gen;

assign clk_div8 = clk_gen[3];

always @(negedge clk, posedge rst) begin
	if(rst) begin
		clk_gen <= 0;
	end else begin
		clk_gen <= {clk_gen[2:0], !clk_gen[3]};
	end
end

always @(posedge clk_div8, posedge rst) begin
	if(rst) begin
		wr_states <= 0;
	end else begin
		wr_states <= states;
	end
end

endmodule
