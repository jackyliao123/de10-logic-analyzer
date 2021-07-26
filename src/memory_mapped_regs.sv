module memory_mapped_regs(
	rst,

	mm_clk,
	mm_address,
	mm_burstcount,
	mm_waitrequest,
	mm_read,
	mm_readdata,
	mm_readdatavalid,
	mm_write,
	mm_writedata,
	mm_byteenable,

	reg_clk,
	reg_write,
	reg_readdata,
	reg_writedata
);

parameter ADDR_SIZE;
parameter ADDR_COUNT = 2 ** ADDR_SIZE;

input                  rst;
input                  mm_clk;
input  [ADDR_SIZE-1:0] mm_address;
input            [0:0] mm_burstcount;
output reg             mm_waitrequest;
input                  mm_read;
output reg      [31:0] mm_readdata;
output reg             mm_readdatavalid;
input                  mm_write;
input           [31:0] mm_writedata;
input            [3:0] mm_byteenable;

input         reg_clk      [ADDR_COUNT];
output        reg_write    [ADDR_COUNT];
input  [31:0] reg_readdata [ADDR_COUNT];
output [31:0] reg_writedata;

localparam
		IDLE = 0,
		WRITE_WAIT = 1,
		READ_WAIT = 2,
		DONE = 3;

reg  [1:0] state;
reg [15:0] timeout_ctr;

reg [31:0] buf_readdata [ADDR_COUNT];
reg  [2:0] buf_req      [ADDR_COUNT];
reg  [2:0] buf_ack;

reg buf_mm_readdatavalid;
reg buf_mm_readdata;

reg req;

always @(posedge mm_clk, posedge rst) begin
	if(rst) begin
		state <= IDLE;
		timeout_ctr <= 0;
		buf_ack <= 0;
		req <= 0;
	end else begin
		buf_ack <= {buf_ack[1:0], buf_req[mm_address][2]};
		mm_readdatavalid <= buf_mm_readdatavalid;
		if(buf_ack[2]) begin
			req <= 0;
		end
		if(state == IDLE) begin
			mm_waitrequest <= 1;
			buf_mm_readdatavalid <= 0;
			timeout_ctr <= 0;
			if(mm_write) begin
				if(mm_byteenable == 4'b1111) begin
					state <= WRITE_WAIT;
					req <= 1;
					reg_writedata <= mm_writedata;
				end else begin
					mm_waitrequest <= 0;
				end
			end else if(mm_read) begin
				state <= READ_WAIT;
				req <= 1;
			end
		end else if(state == WRITE_WAIT) begin
			if(timeout_ctr == 16'h3ff) begin
				state <= DONE;
				mm_waitrequest <= 0;
				req <= 0;
			end else if(!buf_ack[1] && buf_ack[2]) begin
				state <= DONE;
				mm_waitrequest <= 0;
			end else begin
				timeout_ctr <= timeout_ctr + 16'h1;
			end
		end else if(state == READ_WAIT) begin
			if(timeout_ctr == 16'h3ff) begin
				state <= DONE;
				mm_readdata <= buf_readdata[mm_address];
				buf_mm_readdatavalid <= 1;
				mm_waitrequest <= 0;
				req <= 0;
			end else if(buf_ack[1] && !buf_ack[2]) begin
				mm_readdata <= buf_readdata[mm_address];
			end else if(!buf_ack[1] && buf_ack[2]) begin
				state <= DONE;
				buf_mm_readdatavalid <= 1;
				mm_waitrequest <= 0;
			end else begin
				timeout_ctr <= timeout_ctr + 16'h1;
			end
		end else if(state == DONE) begin
			state <= IDLE;
			mm_waitrequest <= 1;
			buf_mm_readdatavalid <= 0;
		end
	end
end

genvar i;
generate
	for(i = 0; i < ADDR_COUNT; ++i) begin: gen_reg
		assign reg_write[i] = buf_req[i][1] && !buf_req[i][2] && state == WRITE_WAIT;
		always @(posedge reg_clk[i], posedge rst) begin
			if(rst) begin
				buf_req[i] <= 0;
			end else begin
				buf_req[i] <= {buf_req[i][1:0], (i == mm_address) && req};
				if(!buf_req[i][1]) begin
					buf_readdata[i] <= reg_readdata[i];
				end
			end
		end
	end
endgenerate


endmodule
