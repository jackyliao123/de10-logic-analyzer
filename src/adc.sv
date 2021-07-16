module adc(
	input             rst,
	input             clk,
	input [2:0]       cfg_count, // number of configurations - 1
	input [7:0] [4:0] cfg_listing,
	output [15:0]     sample, // cfg + sample
	output            sample_valid,
	output            ADC_CONVST,
	output            ADC_SCK,
	output            ADC_SDI,
	input             ADC_SDO
);

reg [2:0] prev_cfg_idx;
reg [2:0] cfg_idx;

assign sample[15:12] = prev_cfg_idx;

always @(posedge clk, posedge rst) begin
	if(rst) begin
		cfg_idx <= 0;
		prev_cfg_idx <= 0;
	end else begin
		if(sample_valid) begin
			prev_cfg_idx <= cfg_idx;
			if(cfg_idx == cfg_count) begin
				cfg_idx <= 0;
			end
		end
	end
end

ltc2308 inst(
	.rst(rst),
	.clk(clk),
	.cfg(cfg_listing[cfg_idx]),
	.sample(sample[11:0]),
	.sample_valid(sample_valid),
	.ADC_CONVST(ADC_CONVST),
	.ADC_SCK(ADC_SCK),
	.ADC_SDI(ADC_SDI),
	.ADC_SDO(ADC_SDO)
);


endmodule
