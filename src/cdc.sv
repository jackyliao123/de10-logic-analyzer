module cdc(
	input  from,
	input  to_rst,
	input  to_clk,
	output to
);

reg [1:0] to_buf;
assign to = to_buf[1];
always @(posedge to_clk, posedge to_rst) begin
	if(to_rst) begin
		to_buf <= 0;
	end else begin
		to_buf <= {to_buf[0], from};
	end
end


endmodule
