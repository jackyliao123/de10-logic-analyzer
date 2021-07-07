
module hps (
	capture_clk_clk,
	capture_clk_div8_clk,
	clk_clk,
	f2h_sdram0_clk_clk,
	f2h_sdram0_data_address,
	f2h_sdram0_data_burstcount,
	f2h_sdram0_data_waitrequest,
	f2h_sdram0_data_readdata,
	f2h_sdram0_data_readdatavalid,
	f2h_sdram0_data_read,
	f2h_sdram0_data_writedata,
	f2h_sdram0_data_byteenable,
	f2h_sdram0_data_write,
	h2f_lw_waitrequest,
	h2f_lw_readdata,
	h2f_lw_readdatavalid,
	h2f_lw_burstcount,
	h2f_lw_writedata,
	h2f_lw_address,
	h2f_lw_write,
	h2f_lw_read,
	h2f_lw_byteenable,
	h2f_lw_debugaccess,
	memory_mem_a,
	memory_mem_ba,
	memory_mem_ck,
	memory_mem_ck_n,
	memory_mem_cke,
	memory_mem_cs_n,
	memory_mem_ras_n,
	memory_mem_cas_n,
	memory_mem_we_n,
	memory_mem_reset_n,
	memory_mem_dq,
	memory_mem_dqs,
	memory_mem_dqs_n,
	memory_mem_odt,
	memory_mem_dm,
	memory_oct_rzqin);	

	output		capture_clk_clk;
	output		capture_clk_div8_clk;
	input		clk_clk;
	output		f2h_sdram0_clk_clk;
	input	[26:0]	f2h_sdram0_data_address;
	input	[7:0]	f2h_sdram0_data_burstcount;
	output		f2h_sdram0_data_waitrequest;
	output	[255:0]	f2h_sdram0_data_readdata;
	output		f2h_sdram0_data_readdatavalid;
	input		f2h_sdram0_data_read;
	input	[255:0]	f2h_sdram0_data_writedata;
	input	[31:0]	f2h_sdram0_data_byteenable;
	input		f2h_sdram0_data_write;
	input		h2f_lw_waitrequest;
	input	[31:0]	h2f_lw_readdata;
	input		h2f_lw_readdatavalid;
	output	[0:0]	h2f_lw_burstcount;
	output	[31:0]	h2f_lw_writedata;
	output	[5:0]	h2f_lw_address;
	output		h2f_lw_write;
	output		h2f_lw_read;
	output	[3:0]	h2f_lw_byteenable;
	output		h2f_lw_debugaccess;
	output	[14:0]	memory_mem_a;
	output	[2:0]	memory_mem_ba;
	output		memory_mem_ck;
	output		memory_mem_ck_n;
	output		memory_mem_cke;
	output		memory_mem_cs_n;
	output		memory_mem_ras_n;
	output		memory_mem_cas_n;
	output		memory_mem_we_n;
	output		memory_mem_reset_n;
	inout	[31:0]	memory_mem_dq;
	inout	[3:0]	memory_mem_dqs;
	inout	[3:0]	memory_mem_dqs_n;
	output		memory_mem_odt;
	output	[3:0]	memory_mem_dm;
	input		memory_oct_rzqin;
endmodule
