module reset_sync(
	input rst_in,
	input clk,
	output reg rst_out
);

reg [2:0] bufs;

always @(posedge clk, posedge rst_in) begin
	if(rst_in) begin
		bufs <= 0;
		rst_out <= 1;
	end else begin
		bufs <= {bufs[1:0], 1'b1};
		rst_out <= !(bufs[1] && bufs[2]);
	end
end

endmodule
