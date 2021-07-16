module ltc2308(
	input             rst,
	input             clk,
	input       [4:0] cfg,
	output reg [11:0] sample,
	output reg        sample_valid,
	output reg        ADC_CONVST,
	output            ADC_SCK,
	output reg        ADC_SDI,
	input             ADC_SDO
);

// clk needs to be 40MHz

reg clk_enable;
reg [5:0] ctr;
reg [1:0] state;
reg [3:0] sdi_shift;

localparam
	STATE_CONVST = 0,
	STATE_SHIFT = 1,
	STATE_ACQ = 2;

assign ADC_SCK = clk_enable & clk;

always @(negedge clk, posedge rst) begin
	if(rst) begin
		clk_enable <= 0;
		ctr <= 0;
		state <= STATE_CONVST;
		sdi_shift <= 0;
		sample <= 0;
		sample_valid <= 0;
		ADC_CONVST <= 1;
		ADC_SDI <= 0;
	end else begin
		if(state == STATE_CONVST) begin
			if(ctr == 63) begin
				state <= STATE_SHIFT;
				ADC_CONVST <= 0;
				ADC_SDI <= cfg[0];
				sdi_shift <= cfg[4:1];
				ctr <= 0;
				clk_enable <= 1;
			end else begin
				ctr <= ctr + 6'h1;
			end
		end else if(state == STATE_SHIFT) begin
			sample <= {sample[10:0], ADC_SDO};
			if(ctr == 11) begin
				state <= STATE_ACQ;
				sample_valid <= 1;
				ctr <= 0;
				clk_enable <= 0;
			end else begin
				ADC_SDI <= sdi_shift[0];
				sdi_shift <= {1'b0, sdi_shift[3:1]};
				ctr <= ctr + 6'h1;
			end
		end else if(state == STATE_ACQ) begin
			sample_valid <= 0;
			if(ctr == 3) begin
				state <= STATE_CONVST;
				ADC_CONVST <= 1;
				ctr <= 0;
			end else begin
				ctr <= ctr + 6'h1;
			end
		end
	end
end



endmodule
