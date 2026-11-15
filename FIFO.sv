////////////////////////////////////////////////////////////////////////////////
// Author: Kareem Waseem
// Course: Digital Verification using SV & UVM
//
// Description: FIFO Design 
// 
////////////////////////////////////////////////////////////////////////////////
module FIFO(FIFO_if.DUT f_if);



reg [f_if.FIFO_WIDTH-1:0] mem [f_if.FIFO_DEPTH-1:0];

always @(posedge f_if.clk or negedge f_if.rst_n) begin
	if (!f_if.rst_n) begin
		f_if.wr_ptr <= 0;
		/* BUG 1: wr_ack and overflow were not cleared on reset, the old reset branch only had the wr_ptr line above
		   OLD CODE: f_if.wr_ptr <= 0;   (nothing else)
		   NEW CODE (added): the two lines below */
		f_if.wr_ack <= 0;
		f_if.overflow <= 0;
	end
	else if (f_if.wr_en && f_if.count < f_if.FIFO_DEPTH) begin
		mem[f_if.wr_ptr] <= f_if.data_in;
		f_if.wr_ack <= 1;
		/* BUG 4: a successful write never cleared overflow, so after an overflow cycle a successful write
		   on the next cycle kept overflow at 1
		   OLD CODE: (no overflow assignment in this branch)
		   NEW CODE (added): the line below */
		f_if.overflow <= 0;
		f_if.wr_ptr <= f_if.wr_ptr + 1;
	end
	else begin 
		f_if.wr_ack <= 0; 
		if (f_if.full & f_if.wr_en)
			f_if.overflow <= 1;
		else
			f_if.overflow <= 0;
	end
end

always @(posedge f_if.clk or negedge f_if.rst_n) begin
	if (!f_if.rst_n) begin
		f_if.rd_ptr <= 0;
		/* BUG 2: underflow was not cleared on reset
		   OLD CODE: f_if.rd_ptr <= 0;   (nothing else)
		   NEW CODE (added): the line below */
		f_if.underflow <= 0;
	end
	/* OLD CODE:
	   else if (f_if.rd_en && f_if.count != 0) begin
		   f_if.data_out <= mem[f_if.rd_ptr];
		   f_if.rd_ptr <= f_if.rd_ptr + 1;
	   end
	   NEW CODE: same read logic, moved inside an else begin ... end so that underflow can be registered next to it */
	else begin
		if (f_if.rd_en && f_if.count != 0) begin
			f_if.data_out <= mem[f_if.rd_ptr];
			f_if.rd_ptr <= f_if.rd_ptr + 1;
		end

		/* BUG 3: underflow was combinational (see the commented assign below), but it is a registered flag
		   like wr_ack and overflow: a read on empty at cycle n must show up at cycle n+1
		   NEW CODE (added): set on empty && rd_en, cleared otherwise, cleared on reset (BUG 2) */
		if (f_if.empty && f_if.rd_en)
			f_if.underflow <= 1;
		else
			f_if.underflow <= 0;
	end
end

always @(posedge f_if.clk or negedge f_if.rst_n) begin
	if (!f_if.rst_n) begin
		f_if.count <= 0;
	end
	else begin
		if	( ({f_if.wr_en, f_if.rd_en} == 2'b10) && !f_if.full) 
			f_if.count <= f_if.count + 1;
		else if ( ({f_if.wr_en, f_if.rd_en} == 2'b01) && !f_if.empty)
			f_if.count <= f_if.count - 1;
			/* BUG 5:priotising whether it should read or write by checking the flags(added below) */
		else if ( ({f_if.wr_en, f_if.rd_en} == 2'b11) && f_if.empty)
		f_if.count <= f_if.count + 1;
		else if ( ({f_if.wr_en, f_if.rd_en} == 2'b11) && f_if.full)
		f_if.count <= f_if.count - 1;
	end
end

assign f_if.full = (f_if.count == f_if.FIFO_DEPTH)? 1 : 0;
assign f_if.empty = (f_if.count == 0)? 1 : 0;
//assign f_if.underflow = (f_if.empty && f_if.rd_en)? 1 : 0;
/* BUG 3 OLD CODE (the line above): combinational underflow, removed. NEW CODE: underflow is registered in the read always block above */
//assign f_if.almostfull = (f_if.count == f_if.FIFO_DEPTH-2)? 1 : 0; 
/* BUG 6: OLD CODE (line above)error in this line the fifo depth should be fifo-1 not -2 this makes it assert almost full too early (added)  */
/*NEW CODE (the line below )*/
assign f_if.almostfull = (f_if.count == f_if.FIFO_DEPTH-1)? 1 : 0; 
assign f_if.almostempty = (f_if.count == 1)? 1 : 0;


endmodule
