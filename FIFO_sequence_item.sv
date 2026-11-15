package FIFO_seq_item_pkg;
    import uvm_pkg::*;
    import FIFO_shared_pkg::*;
    `include "uvm_macros.svh"

    class FIFO_seq_item extends uvm_sequence_item;
        `uvm_object_utils(FIFO_seq_item)

        // Inputs
        rand logic [FIFO_WIDTH-1:0] data_in;
        rand logic                  wr_en;
        rand logic                  rd_en;
        rand logic                  rst_n;

        // Outputs 
        logic [FIFO_WIDTH-1:0] data_out;
        logic                  full;
        logic                  almostfull;
        logic                  empty;
        logic                  almostempty;
        logic                  overflow;
        logic                  underflow;
        logic                  wr_ack;

        int RD_EN_ON_DIST;
        int WR_EN_ON_DIST;

        function new(string name = "FIFO_seq_item", int wr_en_on_dist = 70, int rd_en_on_dist = 30);
            super.new(name);
            WR_EN_ON_DIST = wr_en_on_dist;
            RD_EN_ON_DIST = rd_en_on_dist;
        endfunction

        // 1. Assert reset less often
        constraint c_rst_n {
            rst_n dist { 0 := 2, 1 := 98 };
        }

        // 2. wr_en high WR_EN_ON_DIST %
        constraint c_wr_en {
            wr_en dist { 1 := WR_EN_ON_DIST, 0 := (100 - WR_EN_ON_DIST) };
        }

        // 3. rd_en high RD_EN_ON_DIST %
        constraint c_rd_en {
            rd_en dist { 1 := RD_EN_ON_DIST, 0 := (100 - RD_EN_ON_DIST) };
        }

        function string convert2string();
            return $sformatf("%s rst_n=%0b wr_en=%0b rd_en=%0b data_in=%0h | data_out=%0h full=%0b almostfull=%0b empty=%0b almostempty=%0b overflow=%0b underflow=%0b wr_ack=%0b",super.convert2string(),
                             rst_n, wr_en, rd_en, data_in, data_out, full, almostfull, empty, almostempty, overflow, underflow, wr_ack);
        endfunction

        function string convert2string_stimulus();
            return $sformatf("rst_n=%0b wr_en=%0b rd_en=%0b data_in=%0h ",
                             rst_n, wr_en, rd_en, data_in);
        endfunction

    endclass
endpackage
