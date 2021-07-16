module sdram_interface(
	input          rst_wr,
	input          wr_clk,
	input          wr_data_en,
	input  [255:0] wr_data,
	output         wr_full,

	input          fill_launch,
	input          fill_terminate,
	output         fill_running,
	input   [26:0] fill_addr_start,
	input   [26:0] fill_addr_end,

	input              rst_sdram,
	input              sdram_clk,
	output reg  [26:0] sdram_address,
	output       [7:0] sdram_burstcount,
	input              sdram_waitrequest,
	output             sdram_read,
	input      [255:0] sdram_readdata,
	input              sdram_readdatavalid,
	output reg         sdram_write,
	output     [255:0] sdram_writedata,
	output      [31:0] sdram_byteenable
);

assign sdram_byteenable = 32'hffffffff;

wire         rd_ack;
wire [255:0] rd_data;
wire         rd_empty;

sdram_fifo fifo(
	.data(wr_data),
	.wrclk(wr_clk),
	.wrreq(wr_data_en),
	.wrfull(wr_full),

	.rdclk(sdram_clk),
	.rdreq(rd_ack),
	.q(sdram_writedata),
	.rdempty(rd_empty),

	.aclr(rst_wr)
);

localparam
		WAIT = 0,
		XFER = 1;

reg state;
reg [1:0] fill_launch_buf;
reg [1:0] fill_terminate_buf;

assign sdram_burstcount = 1;
assign rd_ack = state == XFER && !sdram_waitrequest && !rd_empty;
assign fill_running_sdram = state == XFER;
reg [1:0] fill_running_buf;

always @(posedge wr_clk, posedge rst_wr) begin
	if(rst_wr) begin
		fill_running_buf = 0;
	end else begin
		fill_running_buf = {fill_running_buf[0], fill_running_sdram};
	end
end

assign fill_running = fill_running_buf[1];

always @(posedge sdram_clk, posedge rst_sdram) begin
	if(rst_sdram) begin
		state = WAIT;
		sdram_address <= 0;
		sdram_write <= 0;
		fill_launch_buf <= 0;
		fill_terminate_buf <= 0;
	end else begin
		fill_launch_buf <= {fill_launch_buf[0], fill_launch};
		fill_terminate_buf <= {fill_terminate_buf[0], fill_terminate};
		if(state == WAIT) begin
			if(fill_launch_buf[1]) begin
				state = XFER;
				sdram_write <= 1;
				sdram_address <= fill_addr_start;
			end else begin
				sdram_write <= 0;
			end
		end else if(state == XFER) begin
			if(rd_empty) begin
				if(fill_terminate_buf[1]) begin
					state = WAIT;
				end
				sdram_write <= 0;
			end else if(!sdram_waitrequest) begin
				if(sdram_address == fill_addr_end) begin
					sdram_write <= 0;
					state = WAIT;
				end else begin
					sdram_write <= 1;
					sdram_address <= sdram_address + 1;
				end
			end
		end
	end
end

endmodule
