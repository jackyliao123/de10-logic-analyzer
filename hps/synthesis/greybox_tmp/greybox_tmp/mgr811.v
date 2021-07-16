//dcfifo CBX_SINGLE_OUTPUT_FILE="ON" INTENDED_DEVICE_FAMILY=""Cyclone V"" LPM_NUMWORDS=128 LPM_SHOWAHEAD="OFF" LPM_TYPE="dcfifo_mixed_widths" LPM_WIDTH=256 LPM_WIDTHU=7 OVERFLOW_CHECKING="ON" RDSYNC_DELAYPIPE=4 READ_ACLR_SYNCH="OFF" UNDERFLOW_CHECKING="ON" USE_EAB="ON" WRITE_ACLR_SYNCH="OFF" WRSYNC_DELAYPIPE=4 aclr data q rdclk rdempty rdreq wrclk wrfull wrreq
//VERSION_BEGIN 18.0 cbx_mgl 2018:04:18:07:37:08:SJ cbx_stratixii 2018:04:18:06:50:44:SJ cbx_util_mgl 2018:04:18:06:50:44:SJ  VERSION_END
// synthesis VERILOG_INPUT_VERSION VERILOG_2001
// altera message_off 10463



// Copyright (C) 2018  Intel Corporation. All rights reserved.
//  Your use of Intel Corporation's design tools, logic functions 
//  and other software and tools, and its AMPP partner logic 
//  functions, and any output files from any of the foregoing 
//  (including device programming or simulation files), and any 
//  associated documentation or information are expressly subject 
//  to the terms and conditions of the Intel Program License 
//  Subscription Agreement, the Intel Quartus Prime License Agreement,
//  the Intel FPGA IP License Agreement, or other applicable license
//  agreement, including, without limitation, that your use is for
//  the sole purpose of programming logic devices manufactured by
//  Intel and sold by Intel or its authorized distributors.  Please
//  refer to the applicable agreement for further details.



//synthesis_resources = dcfifo 1 
//synopsys translate_off
`timescale 1 ps / 1 ps
//synopsys translate_on
module  mgr811
	( 
	aclr,
	data,
	q,
	rdclk,
	rdempty,
	rdreq,
	wrclk,
	wrfull,
	wrreq) /* synthesis synthesis_clearbox=1 */;
	input   aclr;
	input   [255:0]  data;
	output   [255:0]  q;
	input   rdclk;
	output   rdempty;
	input   rdreq;
	input   wrclk;
	output   wrfull;
	input   wrreq;

	wire  [255:0]   wire_mgl_prim1_q;
	wire  wire_mgl_prim1_rdempty;
	wire  wire_mgl_prim1_wrfull;

	dcfifo   mgl_prim1
	( 
	.aclr(aclr),
	.data(data),
	.q(wire_mgl_prim1_q),
	.rdclk(rdclk),
	.rdempty(wire_mgl_prim1_rdempty),
	.rdreq(rdreq),
	.wrclk(wrclk),
	.wrfull(wire_mgl_prim1_wrfull),
	.wrreq(wrreq));
	defparam
		mgl_prim1.intended_device_family = ""Cyclone V"",
		mgl_prim1.lpm_numwords = 128,
		mgl_prim1.lpm_showahead = "OFF",
		mgl_prim1.lpm_type = "dcfifo_mixed_widths",
		mgl_prim1.lpm_width = 256,
		mgl_prim1.lpm_widthu = 7,
		mgl_prim1.overflow_checking = "ON",
		mgl_prim1.rdsync_delaypipe = 4,
		mgl_prim1.read_aclr_synch = "OFF",
		mgl_prim1.underflow_checking = "ON",
		mgl_prim1.use_eab = "ON",
		mgl_prim1.write_aclr_synch = "OFF",
		mgl_prim1.wrsync_delaypipe = 4;
	assign
		q = wire_mgl_prim1_q,
		rdempty = wire_mgl_prim1_rdempty,
		wrfull = wire_mgl_prim1_wrfull;
endmodule //mgr811
//VALID FILE