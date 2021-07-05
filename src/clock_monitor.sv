module clock_monitor(
	input clk,
	input ref_clk,
	output [31:0] count
);

// Default params. ref_clk = 50MHz, count in kHz
parameter MAX_REF_COUNT = 32'h12500;
parameter DIV_CHAIN_LEN = 4;

always @(posedge clk)

end

endmodule
