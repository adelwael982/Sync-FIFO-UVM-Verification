interface FIFO_if(clk);
    // Parameters
    parameter FIFO_WIDTH = 16;
    parameter FIFO_DEPTH = 8;
    localparam max_fifo_addr = $clog2(FIFO_DEPTH);

    // Clock
    input clk;

    // Interface signals
    logic                     rst_n;
    logic [FIFO_WIDTH-1:0]    data_in;
    logic                     wr_en;
    logic                     rd_en;
    logic [FIFO_WIDTH-1:0]    data_out;
    logic                     full;
    logic                     almostfull;
    logic                     empty;
    logic                     almostempty;
    logic                     overflow;
    logic                     underflow;
    logic                     wr_ack;
    logic [max_fifo_addr:0]   count;
    logic [max_fifo_addr-1:0] rd_ptr;
    logic [max_fifo_addr-1:0] wr_ptr;

    // Modport used by the DUT and the SVA module
    modport DUT (
        input  clk, rst_n, data_in, wr_en, rd_en,
        output data_out, full, almostfull, empty, almostempty, overflow, underflow, wr_ack, count, rd_ptr, wr_ptr);

endinterface
