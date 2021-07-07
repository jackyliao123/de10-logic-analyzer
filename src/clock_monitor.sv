module clock_monitor(
	input rst,
	input clk,
	input ref_clk,
	output reg [31:0] count
);

// Default params. ref_clk = 50MHz, count in kHz
parameter MAX_REF_COUNT = 200000 - 1;
parameter DIV_CHAIN_LEN = 2;

reg [DIV_CHAIN_LEN:0] div_chain;

always @(*) begin
	div_chain[0] <= clk;
end

genvar i;
generate
	for(i = 1; i <= DIV_CHAIN_LEN; ++i) begin: div_chain_gen
		always @(posedge div_chain[i - 1]) begin
			div_chain[i] <= !div_chain[i];
		end
	end
endgenerate

// clk
reg [31:0] ctr;
reg [31:0] ctr_hold;
reg [2:0] buf_req;

// ref_clk
reg [31:0] ref_ctr;
reg [31:0] ctr_prev;
reg [2:0] buf_ack;
reg req;

always @(posedge div_chain[DIV_CHAIN_LEN]) begin
	ctr <= ctr + 1;
	buf_req <= {buf_req[1:0], req};
	if(!buf_req[1]) begin
		ctr_hold <= ctr;
	end
end

always @(posedge ref_clk, posedge rst) begin
	if(rst) begin
		ref_ctr <= 0;
		ctr_prev <= 0;
		buf_ack <= 0;
		req <= 0;
	end else begin
		buf_ack <= {buf_ack[1:0], buf_req[2]};
		if(buf_ack[2]) begin
			req <= 0;
		end
		if(buf_ack[1] && !buf_ack[2]) begin
			count = ctr_hold - ctr_prev;
			ctr_prev <= ctr_hold;
		end
		if(ref_ctr == MAX_REF_COUNT) begin
			ref_ctr <= 0;
			if(req) begin
				count = 0;
				req <= 0;
			end else begin
				req <= 1;
			end
		end else begin
			ref_ctr <= ref_ctr + 1;
		end
	end
end

endmodule
