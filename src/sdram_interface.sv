module sdram_interface(
	// d_wr_clk domain
	input          d_wr_rst,
	input          d_wr_clk,
	input          d_wr_en,
	input  [255:0] d_wr_data,
	output         d_wr_full,
	input          d_wr_trig,
	input    [7:0] d_wr_trig_sample,

	// a_wr_clk domain
	input          a_wr_rst,
	input          a_wr_clk,
	input          a_wr_en,
	input   [15:0] a_wr_data,
	output         a_wr_full,

	// sdram_clk domain
	input              fill_launch,
	input              fill_terminate,
	output             fill_running,
	output reg         fill_wrapped,
	output      [26:0] fill_last_addr,
	input       [26:0] fill_addr_start,
	input       [26:0] fill_addr_end,

	input       [31:0] trig_entries,
	output reg   [7:0] trig_sample,
	output reg  [26:0] trig_addr,
	output reg         triggered,

	input              sdram_rst,
	input              sdram_clk,
	output reg  [26:0] sdram_address,
	output       [7:0] sdram_burstcount,
	input              sdram_waitrequest,
	output             sdram_read,
	input      [255:0] sdram_readdata,
	input              sdram_readdatavalid,
	output reg         sdram_write,
	output reg [255:0] sdram_writedata,
	output      [31:0] sdram_byteenable
);

assign sdram_byteenable = 32'hffffffff;
assign sdram_read = 0;

reg          d_rd_ack;
wire         d_rd_empty;
wire [255:0] d_rd_data;
wire   [7:0] d_rd_trig_sample;
wire         d_rd_triggered;
               
reg          a_rd_ack;
wire         a_rd_empty;
wire  [15:0] a_rd_data;

sdram_d_fifo d_fifo(
	.aclr   (d_wr_rst),
	.wrclk  (d_wr_clk),
	.wrreq  (d_wr_en),
	.data   ({d_wr_trig, d_wr_trig_sample, d_wr_data}),
	.wrfull (d_wr_full),

	.rdclk   (sdram_clk),
	.rdreq   (d_rd_ack),
	.q       ({d_rd_triggered, d_rd_trig_sample, d_rd_data}),
	.rdempty (d_rd_empty)
);

sdram_a_fifo a_fifo(
	.aclr  (a_wr_rst),
	.wrclk (a_wr_clk),
	.wrreq (a_wr_en),
	.data  (a_wr_data),
	.wrfull(a_wr_full),

	.rdclk   (sdram_clk),
	.rdreq   (a_rd_ack),
	.q       (a_rd_data),
	.rdempty (a_rd_empty)
);

localparam
		WAIT = 0,
		XFER = 1,
		FINI1 = 2,
		FINI2 = 3;

reg   [1:0] state;
reg         prev_d_valid;
reg [255:0] prev_d_data;
reg  [31:0] prev_repeat_cnt;
reg  [31:0] prev_hdr_addr;
reg         prev_compressed;
reg  [31:0] entries_remain;
reg  [31:0] next_addr;

assign sdram_burstcount = 1;
assign fill_running = state != WAIT;
assign fill_last_addr = prev_hdr_addr;

// hdr type:
//     32 - prev: previous hdr address
//     32 - type: record type
//            0 - digital
//            1 - analog
//     32 - reserved
//     32 - repeat: number of times previous entry repeats
//    128 - extra data (or adc reading)

always @(*) begin
	d_rd_ack = 0;
	a_rd_ack = 0;
	if(state == XFER) begin
		if(!sdram_waitrequest || !sdram_write) begin
			if(!a_rd_empty) begin
				a_rd_ack = 1;
			end else if(!d_rd_empty) begin
				if(!prev_d_valid || d_rd_data != prev_d_data || prev_repeat_cnt == 32'hFFFFFFFF || d_rd_triggered) begin
					if(!prev_compressed) begin
						d_rd_ack = 1;
					end
				end else begin
					d_rd_ack = 1;
				end
			end
		end
	end
end

always @(posedge sdram_clk, posedge sdram_rst) begin
	if(sdram_rst) begin
		state           <= WAIT;
		prev_d_valid    <= 0;
		prev_d_data     <= 0;
		prev_repeat_cnt <= 0;
		prev_hdr_addr   <= 0;
		prev_compressed <= 0;

		triggered       <= 0;
		trig_sample     <= 0;
		trig_addr       <= 0;

		entries_remain  <= 0;
		fill_wrapped    <= 0;

		next_addr       <= 0;
		sdram_address   <= 0;
		sdram_write     <= 0;
		sdram_writedata <= 0;
	end else begin
		if(state == WAIT) begin
			if(fill_launch) begin
				state           <= XFER;
				prev_d_valid    <= 0;
				prev_d_data     <= 0;
				prev_repeat_cnt <= 0;
				prev_hdr_addr   <= 0;
				prev_compressed <= 0;

				triggered       <= 0;
				trig_sample     <= 0;
				trig_addr       <= 0;

				entries_remain  <= 0;
				fill_wrapped    <= 0;

				next_addr       <= fill_addr_start;
				sdram_address   <= 0;
				sdram_write     <= 0;
				sdram_writedata <= 0;
			end
		end else if(state == XFER) begin
			if(!sdram_waitrequest || !sdram_write) begin
				if(!a_rd_empty) begin
					// Analog data, always terminate previous run
					sdram_write = 1;
					sdram_writedata <= {prev_hdr_addr, 32'h1, 32'h0, prev_repeat_cnt, 112'h0, a_rd_data};
					sdram_address <= next_addr;
					prev_hdr_addr <= next_addr;
					if(prev_compressed) begin
						prev_compressed <= 0;
						prev_repeat_cnt <= 0;
						prev_d_valid <= 0;
					end
				end else if(!d_rd_empty) begin
					if(!prev_d_valid || d_rd_data != prev_d_data || prev_repeat_cnt == 32'hFFFFFFFF || d_rd_triggered) begin
						sdram_write = 1;
						if(!prev_compressed) begin
							// Previous run does not exist
							sdram_writedata <= d_rd_data;
							sdram_address <= next_addr;
							prev_d_data <= d_rd_data;
							prev_d_valid <= 1;
							if(d_rd_triggered) begin
								// If trigger, set trigger regsisters
								triggered <= 1;
								trig_addr <= sdram_address;
								trig_sample <= d_rd_trig_sample;
								entries_remain <= trig_entries;
							end
						end else begin
							// Previous run exists, terminate
							sdram_writedata <= {prev_hdr_addr, 32'h0, 32'h0, prev_repeat_cnt, 128'h0};
							sdram_address <= next_addr;
							prev_hdr_addr <= next_addr;
							prev_compressed <= 0;
							prev_repeat_cnt <= 0;
							prev_d_valid <= 0;
						end
					end else begin
						// Extend compression run length
						sdram_write = 0;
						prev_repeat_cnt <= prev_repeat_cnt + 1;
						prev_compressed <= 1;
					end
				end else begin
					sdram_write = 0;
					// Manual termination
					if(fill_terminate) begin
						state <= FINI1;
					end
				end

				if(sdram_write) begin
					// Terminate after configured entries after trigger
					if(triggered) begin
						if((entries_remain & 32'hFFFFFFFC) == 0) begin
							state <= FINI1;
						end else begin
							entries_remain <= entries_remain - 1;
						end
					end

					// Address control
					if(next_addr == fill_addr_end) begin
						next_addr <= fill_addr_start;
						fill_wrapped <= 1;
					end else begin
						next_addr <= next_addr + 1;
					end
				end
			end
		end else if(state == FINI1) begin
			if(!sdram_write || !sdram_waitrequest) begin
				sdram_write = 1;
				sdram_writedata <= {prev_hdr_addr, 32'h0, 32'h0, prev_repeat_cnt, 128'h0};
				sdram_address <= next_addr;
				prev_hdr_addr <= next_addr;
				state <= FINI2;
			end
		end else if(state == FINI2) begin
			sdram_write = 0;
			state <= WAIT;
		end
	end
end

endmodule
