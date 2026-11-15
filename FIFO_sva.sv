module FIFO_sva(FIFO_if.DUT f_if);   
   
    //Output flag assertions
    f_full: assert property (@(posedge f_if.clk) disable iff (!f_if.rst_n)
        (f_if.count == f_if.FIFO_DEPTH) |-> f_if.full);

    f_empty: assert property (@(posedge f_if.clk) disable iff (!f_if.rst_n)
        (f_if.count == 0) |-> f_if.empty);

    f_almostfull: assert property (@(posedge f_if.clk) disable iff (!f_if.rst_n)
        (f_if.count == f_if.FIFO_DEPTH-1) |-> f_if.almostfull);

    f_almostempty: assert property (@(posedge f_if.clk) disable iff (!f_if.rst_n)
        (f_if.count == 1) |-> f_if.almostempty);

    f_overflow: assert property (@(posedge f_if.clk) disable iff (!f_if.rst_n)
        (f_if.wr_en && f_if.full) |=> f_if.overflow);

    f_underflow: assert property (@(posedge f_if.clk) disable iff (!f_if.rst_n)
        (f_if.rd_en && f_if.empty) |=> f_if.underflow);

    f_wr_ack: assert property (@(posedge f_if.clk) disable iff (!f_if.rst_n)
        (f_if.wr_en && !f_if.full) |=> f_if.wr_ack);

    //Internal counter assertions
    f_wr_ptr_wrap: assert property (@(posedge f_if.clk) disable iff (!f_if.rst_n)
        (f_if.wr_ptr == f_if.FIFO_DEPTH-1 && f_if.wr_en && !f_if.full) |=> (f_if.wr_ptr == 0));

    f_rd_ptr_wrap: assert property (@(posedge f_if.clk) disable iff (!f_if.rst_n)
        (f_if.rd_ptr == f_if.FIFO_DEPTH-1 && f_if.rd_en && !f_if.empty) |=> (f_if.rd_ptr == 0));

    f_ptr_threshold: assert property (@(posedge f_if.clk) disable iff (f_if.rst_n !== 1'b1)
        (f_if.wr_ptr <= f_if.FIFO_DEPTH-1 && f_if.rd_ptr <= f_if.FIFO_DEPTH-1 && f_if.count <= f_if.FIFO_DEPTH))
        else 
        $error("Pointer Error:rst_n%0b wr_ptr=%0d rd_ptr=%0d count=%0d wr_ack=%0b overflow=%0b underflow=%0b full=%0b empty=%0b",
                        f_if.rst_n,f_if.wr_ptr, f_if.rd_ptr, f_if.count, f_if.wr_ack, f_if.overflow,
                        f_if.underflow, f_if.full, f_if.empty);

    // k. Full priority
    property p_full_priority;
        int prev_count;
        @(posedge f_if.clk) disable iff (!f_if.rst_n)
        (f_if.wr_en && f_if.rd_en && f_if.full, prev_count = f_if.count) |=> (f_if.count == prev_count - 1);
    endproperty
    k_full_priority: assert property (p_full_priority);
    
    // l. Empty priority
    property p_empty_priority;
        int prev_count;
        @(posedge f_if.clk) disable iff (!f_if.rst_n)
        (f_if.wr_en && f_if.rd_en && f_if.empty, prev_count = f_if.count) |=> (f_if.count == prev_count + 1);
    endproperty
    l_empty_priority: assert property (p_empty_priority);

    //Reset Assertion
    always_comb begin
        if (!f_if.rst_n) begin
            a_async_reset: assert #0 (f_if.wr_ptr == 0 && f_if.rd_ptr == 0 && f_if.count == 0 &&
                                      f_if.wr_ack == 0 && f_if.overflow == 0 && f_if.underflow == 0 &&
                                      f_if.full == 0 && f_if.almostfull == 0 &&
                                      f_if.empty == 1 && f_if.almostempty == 0)
            else $error("Async reset failed: wr_ptr=%0d rd_ptr=%0d count=%0d wr_ack=%0b overflow=%0b underflow=%0b full=%0b empty=%0b",
                        f_if.wr_ptr, f_if.rd_ptr, f_if.count, f_if.wr_ack, f_if.overflow,
                        f_if.underflow, f_if.full, f_if.empty);
        end
    end

    //EXTRA FOR UVM ASSERTION
    f_wr_ack_full: assert property (@(posedge f_if.clk) disable iff(!f_if.rst_n)
        (f_if.full|=>!f_if.wr_ack));

    //Cover directives 
    c_full: cover property (@(posedge f_if.clk) disable iff (!f_if.rst_n)
        (f_if.count == f_if.FIFO_DEPTH) |-> f_if.full);

    c_empty: cover property (@(posedge f_if.clk) disable iff (!f_if.rst_n)
        (f_if.count == 0) |-> f_if.empty);

    c_almostfull: cover property (@(posedge f_if.clk) disable iff (!f_if.rst_n)
        (f_if.count == f_if.FIFO_DEPTH-1) |-> f_if.almostfull);

    c_almostempty: cover property (@(posedge f_if.clk) disable iff (!f_if.rst_n)
        (f_if.count == 1) |-> f_if.almostempty);

    c_overflow: cover property (@(posedge f_if.clk) disable iff (!f_if.rst_n)
        (f_if.wr_en && f_if.full) |=> f_if.overflow);

    c_underflow: cover property (@(posedge f_if.clk) disable iff (!f_if.rst_n)
        (f_if.rd_en && f_if.empty) |=> f_if.underflow);

    c_wr_ack: cover property (@(posedge f_if.clk) disable iff (!f_if.rst_n)
        (f_if.wr_en && !f_if.full) |=> f_if.wr_ack);

    c_wr_ptr_wrap: cover property (@(posedge f_if.clk) disable iff (!f_if.rst_n)
        (f_if.wr_ptr == f_if.FIFO_DEPTH-1 && f_if.wr_en && !f_if.full) |=> (f_if.wr_ptr == 0));

    c_rd_ptr_wrap: cover property (@(posedge f_if.clk) disable iff (!f_if.rst_n)
        (f_if.rd_ptr == f_if.FIFO_DEPTH-1 && f_if.rd_en && !f_if.empty) |=> (f_if.rd_ptr == 0));

    c_ptr_threshold: cover property (@(posedge f_if.clk) disable iff (!f_if.rst_n)
        (f_if.wr_ptr <= f_if.FIFO_DEPTH-1 && f_if.rd_ptr <= f_if.FIFO_DEPTH-1 && f_if.count <= f_if.FIFO_DEPTH));

    c_full_priority: cover property (p_full_priority);
    c_empty_priority: cover property (p_empty_priority);

    c_async_reset: cover property (@(negedge f_if.rst_n) 1);

    c_wr_ack_full: cover property (@(posedge f_if.clk) disable iff(!f_if.rst_n)
        (f_if.full |=> !f_if.wr_ack));

endmodule
