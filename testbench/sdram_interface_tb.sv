`timescale 1ns/10ps

module sdram_interface_tb;

/* i */ reg          d_wr_rst;
/* i */ reg          d_wr_clk;
/* i */ reg          d_wr_en;
/* i */ reg  [255:0] d_wr_data;
/* o */ wire         d_wr_full;
/* i */ reg          d_wr_trig;
/* i */ reg    [2:0] d_wr_trig_sample;

/* i */ reg          a_wr_rst;
/* i */ reg          a_wr_clk;
/* i */ reg          a_wr_en;
/* i */ reg   [15:0] a_wr_data;
/* o */ wire         a_wr_full;

/* i */ reg          fill_launch;
/* i */ reg          fill_terminate;
/* o */ wire         fill_running;
/* o */ wire         fill_wrapped;
/* o */ wire  [26:0] fill_last_addr;
/* i */ reg   [26:0] fill_addr_start;
/* i */ reg   [26:0] fill_addr_end;

/* i */ reg   [32:0] trig_entries;
/* o */ wire   [2:0] trig_sample;
/* o */ wire  [26:0] trig_addr;
/* o */ wire         triggered;

/* i */ reg          sdram_rst;
/* i */ reg          sdram_clk;
/* o */ wire  [26:0] sdram_address;
/* o */ wire   [7:0] sdram_burstcount;
/* i */ reg          sdram_waitrequest;
/* o */ wire         sdram_read;
/* i */ reg  [255:0] sdram_readdata;
/* i */ reg          sdram_readdatavalid;
/* o */ wire         sdram_write;
/* o */ wire [255:0] sdram_writedata;
/* o */ wire  [31:0] sdram_byteenable;

sdram_interface sdram_iface_tb(
	.d_wr_rst            (d_wr_rst),
	.d_wr_clk            (d_wr_clk),
	.d_wr_en             (d_wr_en),
	.d_wr_data           (d_wr_data),
	.d_wr_full           (d_wr_full),
	.d_wr_trig           (d_wr_trig),
	.d_wr_trig_sample    (d_wr_trig_sample),

	.a_wr_rst            (a_wr_rst),
	.a_wr_clk            (a_wr_clk),
	.a_wr_en             (a_wr_en),
	.a_wr_data           (a_wr_data),
	.a_wr_full           (a_wr_full),

	.fill_launch         (fill_launch),
	.fill_terminate      (fill_terminate),
	.fill_running        (fill_running),
	.fill_wrapped        (fill_wrapped),
	.fill_last_addr      (fill_last_addr),
	.fill_addr_start     (fill_addr_start),
	.fill_addr_end       (fill_addr_end),

	.trig_entries        (trig_entries),
	.trig_sample         (trig_sample),
	.trig_addr           (trig_addr),
	.triggered           (triggered),

	.sdram_rst           (sdram_rst),
	.sdram_clk           (sdram_clk),
	.sdram_address       (sdram_address),
	.sdram_burstcount    (sdram_burstcount),
	.sdram_waitrequest   (sdram_waitrequest),
	.sdram_read          (sdram_read),
	.sdram_readdata      (sdram_readdata),
	.sdram_readdatavalid (sdram_readdatavalid),
	.sdram_write         (sdram_write),
	.sdram_writedata     (sdram_writedata),
	.sdram_byteenable    (sdram_byteenable)
);

initial begin
	sdram_rst = 1;
	d_wr_rst = 1;
	a_wr_rst = 1;

	sdram_clk = 0;
	d_wr_clk = 0;
	a_wr_clk = 0;
end

initial forever #5 sdram_clk = !sdram_clk;
initial forever #8 d_wr_clk = !d_wr_clk;
initial forever #100 a_wr_clk = !a_wr_clk;

initial begin
	fill_launch = 0;
	fill_terminate = 0;
	fill_addr_start = 32'h20000000 >> 5;
	fill_addr_end = 32'h3fffffff >> 5;

	trig_entries = 32'hffffffff;
	d_wr_trig = 0;
	d_wr_trig_sample = 0;
	d_wr_en = 0;
	a_wr_en = 0;

	sdram_waitrequest = 1;

	#50

	sdram_rst = 0;
	d_wr_rst = 0;
	a_wr_rst = 0;

	#10

	fill_launch = 1;
end

always @(posedge d_wr_clk) begin
	std::randomize(d_wr_data);
	std::randomize(d_wr_en);
end

always @(posedge a_wr_clk) begin
	std::randomize(a_wr_data);
	std::randomize(a_wr_en);
end

always @(posedge sdram_clk) begin
	std::randomize(sdram_waitrequest);
end

endmodule
