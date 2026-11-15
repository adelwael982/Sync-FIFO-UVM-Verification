package FIFO_coverage_pkg;
    import uvm_pkg::*;
    import FIFO_seq_item_pkg::*;
    `include "uvm_macros.svh"

    class FIFO_coverage extends uvm_component;
        `uvm_component_utils(FIFO_coverage)

        uvm_analysis_export#(FIFO_seq_item) cov_export;
        uvm_tlm_analysis_fifo#(FIFO_seq_item) cov_fifo;
        FIFO_seq_item cov_txn;

        covergroup W_R_S;
            // Read and write enable
            WR:   coverpoint cov_txn.wr_en;
            RD:   coverpoint cov_txn.rd_en;

            // Output signals
            FU:   coverpoint cov_txn.full;
            EM:   coverpoint cov_txn.empty;
            AEM:  coverpoint cov_txn.almostempty;
            OF:   coverpoint cov_txn.overflow;
            UF:   coverpoint cov_txn.underflow;
            WR_A: coverpoint cov_txn.wr_ack;
            AFU:  coverpoint cov_txn.almostfull;

            // Cross coverage: wr_en x rd_en x each output signal
            W_R_FU   : cross WR, RD, FU {
                // full = 1 after a cycle with rd_en = 1 cannot happen: 
                ignore_bins full_with_rd = binsof(FU) intersect {1} && binsof(RD) intersect {1};
            }
            W_R_AFU  : cross WR, RD, AFU;
            W_R_EM   : cross WR, RD, EM;
            W_R_AEM  : cross WR, RD, AEM;
            W_R_OF   : cross WR, RD, OF {
                // overflow is set only by a write attempted on a full FIFO, so overflow = 1
                // with wr_en = 0 in the same cycle cannot happen
                ignore_bins of_without_wr = binsof(OF) intersect {1} && binsof(WR) intersect {0};
            }
            W_R_UF   : cross WR, RD, UF {
                illegal_bins rd_low_uf_high = binsof(RD) intersect {0} && binsof(UF) intersect {1};
            }
            W_R_WR_A : cross WR, RD, WR_A {
                // wr_ack is set only by an accepted write, so wr_ack = 1 with wr_en = 0
                ignore_bins ack_without_wr = binsof(WR_A) intersect {1} && binsof(WR) intersect {0};
            }
        endgroup

        function new(string name = "FIFO_coverage", uvm_component parent = null);
            super.new(name, parent);
            W_R_S   = new();
        endfunction

        function void build_phase(uvm_phase phase);
            super.build_phase(phase);
            cov_export = new("cov_export", this);
            cov_fifo   = new("cov_fifo",this);
        endfunction

        function void connect_phase(uvm_phase phase);
            super.connect_phase(phase);
            cov_export.connect(cov_fifo.analysis_export);
        endfunction

        task run_phase(uvm_phase phase);
            super.run_phase(phase);
            forever begin
                cov_fifo.get(cov_txn);
                W_R_S.sample();
            end
        endtask 
    endclass
endpackage
