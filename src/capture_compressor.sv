module capture_compressor(
	input rst,
	input clk,
	input         in_valid,
	input [255:0] in_data,

	output reg         out_valid,
	output reg [255:0] out_data 
);

reg [63:0] ctr_repeat;
reg [63:0] ctr_entries;
reg [255:0] prev_wr_data;
reg prev_wr_same;

always @(posedge clk, posedge rst) begin
	if(rst) begin
		ctr_repeat <= 0;
		ctr_entries <= 0;
		prev_wr_data <= 0;
		prev_wr_same <= 0;

		out_valid <= 0;
		out_data <= 0;
	end else begin
		if(in_valid) begin
			if(prev_wr_same) begin
				if(prev_wr_data == in_data) begin
					out_valid <= 0;
					out_data <= 0;
				end else begin
					out_valid <= 1;
					out_data <= {128'b0, ctr_entries, ctr_repeat};
					ctr_entries <= 0;
				end
				ctr_repeat <= ctr_repeat + 1;
			end else begin
				out_valid <= 1;
				out_data <= prev_wr_data;
				ctr_entries <= ctr_entries + 1;
				ctr_repeat <= 0;
			end
			prev_wr_data <= in_data;
			prev_wr_same <= prev_wr_data == in_data;
		end else begin
			out_valid <= 0;
			out_data <= 0;
		end
	end
end

endmodule

