package FIFO_monitor_pkg;
    import uvm_pkg::*;
    import FIFO_config_pkg::*;
    import FIFO_seq_item_pkg::*;
    `include "uvm_macros.svh"

    class FIFO_monitor extends uvm_monitor;
        `uvm_component_utils(FIFO_monitor)

        virtual FIFO_if FIFO_vif;
        FIFO_config     cfg;
        uvm_analysis_port #(FIFO_seq_item) mon_ap;

        function new(string name = "FIFO_monitor", uvm_component parent = null);
            super.new(name, parent);
        endfunction

        function void build_phase(uvm_phase phase);
            super.build_phase(phase);
            if (!uvm_config_db#(FIFO_config)::get(this, "", "CFG", cfg))
                `uvm_fatal("build_phase", "MONITOR: Unable to get FIFO_config")
            FIFO_vif = cfg.FIFO_vif;
            mon_ap   = new("mon_ap", this);
        endfunction


        task run_phase(uvm_phase phase);
            FIFO_seq_item item;
            super.run_phase(phase);
            forever begin
                @(posedge FIFO_vif.clk);
                #1;
                item = FIFO_seq_item::type_id::create("item");
                item.data_in     = FIFO_vif.data_in;
                item.wr_en       = FIFO_vif.wr_en;
                item.rd_en       = FIFO_vif.rd_en;
                item.rst_n       = FIFO_vif.rst_n;
                item.data_out    = FIFO_vif.data_out;
                item.full        = FIFO_vif.full;
                item.empty       = FIFO_vif.empty;
                item.almostfull  = FIFO_vif.almostfull;
                item.almostempty = FIFO_vif.almostempty;
                item.overflow    = FIFO_vif.overflow;
                item.underflow   = FIFO_vif.underflow;
                item.wr_ack      = FIFO_vif.wr_ack;
                mon_ap.write(item);
            end
        endtask
    endclass
endpackage
