//alt_oct_power CBX_SINGLE_OUTPUT_FILE="ON" INTENDED_DEVICE_FAMILY=""Cyclone V"" LPM_TYPE="ALT_OCT_POWER" width_ptc=16 width_stc=16 parallelterminationcontrol rzqin seriesterminationcontrol
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



//synthesis_resources = alt_oct_power 1 
//synopsys translate_off
`timescale 1 ps / 1 ps
//synopsys translate_on
module  mgmuh
	( 
	parallelterminationcontrol,
	rzqin,
	seriesterminationcontrol) /* synthesis synthesis_clearbox=1 */;
	output   [15:0]  parallelterminationcontrol;
	input   [0:0]  rzqin;
	output   [15:0]  seriesterminationcontrol;

	wire  [15:0]   wire_mgl_prim1_parallelterminationcontrol;
	wire  [15:0]   wire_mgl_prim1_seriesterminationcontrol;

	alt_oct_power   mgl_prim1
	( 
	.parallelterminationcontrol(wire_mgl_prim1_parallelterminationcontrol),
	.rzqin(rzqin),
	.seriesterminationcontrol(wire_mgl_prim1_seriesterminationcontrol));
	defparam
		mgl_prim1.intended_device_family = ""Cyclone V"",
		mgl_prim1.lpm_type = "ALT_OCT_POWER",
		mgl_prim1.width_ptc = 16,
		mgl_prim1.width_stc = 16;
	assign
		parallelterminationcontrol = wire_mgl_prim1_parallelterminationcontrol,
		seriesterminationcontrol = wire_mgl_prim1_seriesterminationcontrol;
endmodule //mgmuh
//VALID FILE
