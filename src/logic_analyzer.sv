
//=======================================================
//  This code is generated by Terasic System Builder
//=======================================================

module logic_analyzer(

	//////////// ADC //////////
	output		          		ADC_CONVST,
	output		          		ADC_SCK,
	output		          		ADC_SDI,
	input 		          		ADC_SDO,

	//////////// ARDUINO //////////
	inout 		    [15:0]		ARDUINO_IO,
	inout 		          		ARDUINO_RESET_N,

	//////////// CLOCK //////////
	input 		          		FPGA_CLK1_50,
	input 		          		FPGA_CLK2_50,
	input 		          		FPGA_CLK3_50,

	//////////// HDMI //////////
	inout 		          		HDMI_I2C_SCL,
	inout 		          		HDMI_I2C_SDA,
	inout 		          		HDMI_I2S,
	inout 		          		HDMI_LRCLK,
	inout 		          		HDMI_MCLK,
	inout 		          		HDMI_SCLK,
	output		          		HDMI_TX_CLK,
	output		          		HDMI_TX_DE,
	output		    [23:0]		HDMI_TX_D,
	output		          		HDMI_TX_HS,
	input 		          		HDMI_TX_INT,
	output		          		HDMI_TX_VS,

	//////////// HPS //////////
	output		    [14:0]		HPS_DDR3_ADDR,
	output		     [2:0]		HPS_DDR3_BA,
	output		          		HPS_DDR3_CAS_N,
	output		          		HPS_DDR3_CKE,
	output		          		HPS_DDR3_CK_N,
	output		          		HPS_DDR3_CK_P,
	output		          		HPS_DDR3_CS_N,
	output		     [3:0]		HPS_DDR3_DM,
	inout 		    [31:0]		HPS_DDR3_DQ,
	inout 		     [3:0]		HPS_DDR3_DQS_N,
	inout 		     [3:0]		HPS_DDR3_DQS_P,
	output		          		HPS_DDR3_ODT,
	output		          		HPS_DDR3_RAS_N,
	output		          		HPS_DDR3_RESET_N,
	input 		          		HPS_DDR3_RZQ,
	output		          		HPS_DDR3_WE_N,

	//////////// KEY //////////
	input 		     [1:0]		KEY,

	//////////// LED //////////
	output		     [7:0]		LED,

	//////////// SW //////////
	input 		     [3:0]		SW,

	//////////// GPIO_0, GPIO connect to GPIO Default //////////
	inout 		    [35:0]		GPIO_0,

	//////////// GPIO_1, GPIO connect to GPIO Default //////////
	inout 		    [35:0]		GPIO_1
);

assign rst = ~KEY[0];

wire sample_clk;
wire data_clk;

wire [7:0] [31:0] wr_states;

wire         mapped_wr_valid;
wire [255:0] mapped_wr_data;

wire         cprs_wr_valid;
wire [255:0] cprs_wr_data;

wire         mem_wr_valid;
wire [255:0] mem_wr_data;

wire sdram_clk;
wire hps_clk;

assign hps_clk = FPGA_CLK1_50;

wire  [26:0] sdram_address;
wire   [7:0] sdram_burstcount;
wire         sdram_waitrequest;
wire         sdram_read;
wire [255:0] sdram_readdata;
wire         sdram_readdatavalid;
wire         sdram_write;
wire [255:0] sdram_writedata;
wire  [31:0] sdram_byteenable;

wire   [5:0] h2f_lw_address;
wire         h2f_lw_burstcount;
wire         h2f_lw_waitrequest;
wire         h2f_lw_read;
wire  [31:0] h2f_lw_readdata;
wire         h2f_lw_readdatavalid;
wire         h2f_lw_write;
wire  [31:0] h2f_lw_writedata;
wire   [3:0] h2f_lw_byteenable;

hps u0 (
	.clk_clk                       (hps_clk),                     //              clk.clk

	.memory_mem_a                  (HPS_DDR3_ADDR),               //           memory.mem_a
	.memory_mem_ba                 (HPS_DDR3_BA),                 //                 .mem_ba
	.memory_mem_ck                 (HPS_DDR3_CK_P),               //                 .mem_ck
	.memory_mem_ck_n               (HPS_DDR3_CK_N),               //                 .mem_ck_n
	.memory_mem_cke                (HPS_DDR3_CKE),                //                 .mem_cke
	.memory_mem_cs_n               (HPS_DDR3_CS_N),               //                 .mem_cs_n
	.memory_mem_ras_n              (HPS_DDR3_RAS_N),              //                 .mem_ras_n
	.memory_mem_cas_n              (HPS_DDR3_CAS_N),              //                 .mem_cas_n
	.memory_mem_we_n               (HPS_DDR3_WE_N),               //                 .mem_we_n
	.memory_mem_reset_n            (HPS_DDR3_RESET_N),            //                 .mem_reset_n
	.memory_mem_dq                 (HPS_DDR3_DQ),                 //                 .mem_dq
	.memory_mem_dqs                (HPS_DDR3_DQS_P),              //                 .mem_dqs
	.memory_mem_dqs_n              (HPS_DDR3_DQS_N),              //                 .mem_dqs_n
	.memory_mem_odt                (HPS_DDR3_ODT),                //                 .mem_odt
	.memory_mem_dm                 (HPS_DDR3_DM),                 //                 .mem_dm
	.memory_oct_rzqin              (HPS_DDR3_RZQ),                //                 .oct_rzqin

	.f2h_sdram0_clk_clk            (sdram_clk),                   //   f2h_sdram0_clk.clk
	.f2h_sdram0_data_address       (sdram_address),               //  f2h_sdram0_data.address
	.f2h_sdram0_data_burstcount    (sdram_burstcount),            //                 .burstcount
	.f2h_sdram0_data_waitrequest   (sdram_waitrequest),           //                 .waitrequest
	.f2h_sdram0_data_read          (sdram_read),                  //                 .read
	.f2h_sdram0_data_readdata      (sdram_readdata),              //                 .readdata
	.f2h_sdram0_data_readdatavalid (sdram_readdatavalid),         //                 .readdatavalid
	.f2h_sdram0_data_write         (sdram_write),                 //                 .write
	.f2h_sdram0_data_writedata     (sdram_writedata),             //                 .writedata
	.f2h_sdram0_data_byteenable    (sdram_byteenable),            //                 .byteenable

	.h2f_lw_address                (h2f_lw_address),              //           h2f_lw.address
	.h2f_lw_burstcount             (h2f_lw_burstcount),           //                 .burstcount
	.h2f_lw_waitrequest            (h2f_lw_waitrequest),          //                 .waitrequest
	.h2f_lw_read                   (h2f_lw_read),                 //                 .read
	.h2f_lw_readdata               (h2f_lw_readdata),             //                 .readdata
	.h2f_lw_readdatavalid          (h2f_lw_readdatavalid),        //                 .readdatavalid
	.h2f_lw_write                  (h2f_lw_write),                //                 .write
	.h2f_lw_writedata              (h2f_lw_writedata),            //                 .writedata
	.h2f_lw_byteenable             (h2f_lw_byteenable),           //                 .byteenable

	.capture_clk_clk               (sample_clk),
	.capture_clk_div8_clk          (data_clk)
);

wire        reg_clk       [16];
wire        reg_write     [16];
wire [31:0] reg_readdata  [16];
wire [31:0] reg_writedata;

memory_mapped_regs #(.ADDR_SIZE(4)) mm (
	.rst(rst),

	.mm_clk           (hps_clk),
	.mm_address       (h2f_lw_address),
	.mm_burstcount    (h2f_lw_burstcount),
	.mm_waitrequest   (h2f_lw_waitrequest),
	.mm_read          (h2f_lw_read),
	.mm_readdata      (h2f_lw_readdata),
	.mm_readdatavalid (h2f_lw_readdatavalid),
	.mm_write         (h2f_lw_write),
	.mm_writedata     (h2f_lw_writedata),
	.mm_byteenable    (h2f_lw_byteenable),

	.reg_clk        (reg_clk),
	.reg_write      (reg_write),
	.reg_readdata   (reg_readdata),
	.reg_writedata  (reg_writedata)
);

//  0: Register CTRL (RW)
//     31  - run
//     26  - compression
// [26:24] - trig mode
//             0 - always
//             1 - never
//             2 - rising edge
//             3 - falling edge
//             4 - both edges
//             5 - high
//             6 - low
// [23:19] - trig channel
// [18:16] - num channels
//      1  - reset sdram_iface
//      0  - reset frontend
reg [31:0] reg_CTRL;
assign reg_readdata[0] = reg_CTRL;
assign reg_clk[0] = hps_clk;
always @(posedge hps_clk) begin
	if(reg_write[0]) begin
		reg_CTRL <= reg_writedata;
	end
end

//  1: Register STATUS (R)
// [24:16] - overflow counter
//     10  - finished
//      9  - samples wrapped in memory
//      8  - triggered
// [ 7: 0] - trigger subsample
reg [31:0] reg_STATUS;
assign reg_readdata[1] = reg_STATUS;
assign reg_clk[0] = hps_clk;

//  2: Register TRIG_COND_MATCH (RW)
// [31: 0] - match
reg [31:0] reg_TRIG_COND_MATCH;
assign reg_readdata[2] = reg_TRIG_COND_MATCH;
always @(posedge data_clk) begin
	if(reg_write[2]) begin
		reg_TRIG_COND_MATCH <= reg_writedata;
	end
end

//  3: Register TRIG_COND_MASK (RW)
// [31: 0] - mask
reg [31:0] reg_TRIG_COND_MASK;
assign reg_readdata[3] = reg_TRIG_COND_MASK;
always @(posedge data_clk) begin
	if(reg_write[3]) begin
		reg_TRIG_COND_MASK <= reg_writedata;
	end
end

//  4: Register NUM_SAMPLES (R)
// [63: 0] - number of samples collected
reg [63:0] reg_NUM_SAMPLES;
assign reg_clk[4:5] = '{data_clk, data_clk};
assign reg_readdata[4:5] = '{reg_NUM_SAMPLES[31:0], reg_NUM_SAMPLES[63:32]};

//  6: Register LIMIT_TRIG_SAMPLES (RW)
// [63: 0] - maximum number of samples after trigger
reg [63:0] reg_LIMIT_TRIG_SAMPLES;
assign reg_clk[6:7] = '{data_clk, data_clk};
assign reg_readdata[6:7] = '{reg_LIMIT_TRIG_SAMPLES[31:0], reg_LIMIT_TRIG_SAMPLES[63:32]};
always @(posedge data_clk) begin
	if(reg_write[7]) begin
		reg_LIMIT_TRIG_SAMPLES[63:32] <= reg_writedata;
	end
	if(reg_write[6]) begin
		reg_LIMIT_TRIG_SAMPLES[31:0] <= reg_writedata;
	end
end

//  8: Register NUM_ENTRIES (R)
// [31: 0] - number of entries written
reg [31:0] reg_NUM_ENTRIES;
assign reg_clk[8] = data_clk;
assign reg_readdata[8] = reg_NUM_ENTRIES;

// 9: Register LIMIT_TRIG_ENTRIES (RW)
// [31: 0] - maximum number of entries after trigger
reg [31:0] reg_LIMIT_TRIG_ENTRIES;
assign reg_clk[9] = data_clk;
assign reg_readdata[9] = reg_LIMIT_TRIG_ENTRIES;
always @(posedge data_clk) begin
	if(reg_write[9]) begin
		reg_LIMIT_TRIG_ENTRIES <= reg_writedata;
	end
end

// 10: Register TRIG_ENTRY (R)
// [31: 0] - the entry where trigger happened
reg [31:0] reg_TRIG_ENTRY;
assign reg_clk[10] = data_clk;
assign reg_readdata[10] = reg_TRIG_ENTRY;

// 11: Register CLK_CNT_SAMPLE (R)
// [31: 0] - clk rate in kHz
reg [31:0] reg_CLK_CNT_SAMPLE;
assign reg_clk[11] = FPGA_CLK1_50;
clock_monitor clk_mon_sample(
	.rst(rst),
	.clk(sample_clk),
	.ref_clk(FPGA_CLK1_50),
	.count(reg_readdata[11])
);

// 12: Register CLK_CNT_DATA (R)
// [31: 0] - clk rate in kHz
reg [31:0] reg_CLK_CNT_DATA;
assign reg_clk[12] = FPGA_CLK1_50;
clock_monitor clk_mon_data(
	.rst(rst),
	.clk(data_clk),
	.ref_clk(FPGA_CLK1_50),
	.count(reg_readdata[12])
);

wire rst_frontend;
reset_sync reset_frontend(
	.rst_in(rst | reg_CTRL[0] /* reset frontend */),
	.clk(sample_clk),
	.rst_out(rst_frontend)
);

wire rst_data_pipeline;
reset_sync reset_pipeline(
	.rst_in(rst | reg_CTRL[0] /* reset frontend */),
	.clk(data_clk),
	.rst_out(rst_data_pipeline)
);

wire rst_compressor;
reset_sync reset_compressor(
	.rst_in(rst | reg_CTRL[0] /* reset frontend */ | !reg_CTRL[26] /* compression */),
	.clk(data_clk),
	.rst_out(rst_compressor)
);

wire rst_sdram;
reset_sync reset_sdram(
	.rst_in(rst | reg_CTRL[1] /* reset sdram_iface */),
	.clk(sdram_clk),
	.rst_out(rst_sdram)
);

reg [1:0] run_buf;
wire run;
assign run = run_buf[1];

always @(posedge data_clk, posedge rst_data_pipeline) begin
	if(rst_data_pipeline) begin
		run_buf <= 0;
	end else begin
		run_buf <= {run_buf[0], reg_CTRL[31] /* run */};
	end
end


capture_frontend frontend (
	.rst(rst_frontend),
	.clk(sample_clk),
	.channels(GPIO_0[31:0]),
	.clk_div8(data_clk),
	.wr_states(wr_states)
);

//lvds_frontend frontend (
//	//.rx_enable(data_clk),
//	.rx_in(GPIO_0[31:0]),
//	.rx_inclock(GPIO_1[0]),
//	.rx_out(wr_states),
//	.rx_outclock(data_clk)
//);


//wire o_valid;
//assign data_clk = !o_valid;
//
//frontend fr (
//	.clk(sample_clk),
//	.reset(rst),
//	.inin(GPIO_0[1:0]),
//	.o_valid(o_valid),
//	.outout({wr_states[1], wr_states[0]})
//);

capture_channel_mapper channel_mapper (
	.rst(rst_data_pipeline),
	.clk(data_clk),
	.channels(reg_CTRL[18:16] /* num channels */),
	.wr_states(wr_states),
	.out_valid(mapped_wr_valid),
	.out_data(mapped_wr_data)
);

capture_compressor compressor (
	.rst(rst_compressor),
	.clk(data_clk),
	.in_valid(mapped_wr_valid && run),
	.in_data(mapped_wr_data),
	.out_valid(cprs_wr_valid),
	.out_data(cprs_wr_data)
);

assign mem_wr_valid = (reg_CTRL[26] /* compression */ ? cprs_wr_valid : mapped_wr_valid) && run;
assign mem_wr_data = reg_CTRL[26] /* compression */ ? cprs_wr_data : mapped_wr_data;

always @(posedge data_clk, posedge rst_data_pipeline) begin
	if(rst_data_pipeline) begin
		reg_NUM_SAMPLES <= 0;
		reg_NUM_ENTRIES <= 0;
	end else begin
		if(run) begin
			reg_NUM_SAMPLES <= reg_NUM_SAMPLES + 1;
			if(!write_full && mem_wr_valid) begin
				reg_NUM_ENTRIES <= reg_NUM_ENTRIES + 1;
			end
		end else begin
			reg_NUM_SAMPLES <= 0;
			reg_NUM_ENTRIES <= 0;
		end
	end
end

sdram_interface sdram_iface(
	.rst_wr(rst_data_pipeline),
	.wr_clk(data_clk),
	.wr_data_en(!write_full && mem_wr_valid),
	.wr_data(mem_wr_data),
	.wr_full(write_full),
	.fill_launch(run),
	.fill_terminate(!run),
	.fill_running(LED[5]),
	.fill_addr_start(32'h20000000 >> 5),
	.fill_addr_end(32'h3fffffff >> 5),

	.rst_sdram           (rst_sdram),
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

endmodule
