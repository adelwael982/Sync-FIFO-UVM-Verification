package FIFO_driver_pkg;
    import uvm_pkg::*;
    import FIFO_config_pkg::*;
    import FIFO_seq_item_pkg::*;
    `include "uvm_macros.svh"

    class FIFO_driver extends uvm_driver #(FIFO_seq_item);
        `uvm_component_utils(FIFO_driver)

        virtual FIFO_if FIFO_vif;
        FIFO_config     cfg;

        function new(string name = "FIFO_driver", uvm_component parent = null);
            super.new(name, parent);
        endfunction

        function void build_phase(uvm_phase phase);
            super.build_phase(phase);
            if (!uvm_config_db#(FIFO_config)::get(this, "", "CFG", cfg))
                `uvm_fatal("build_phase", "DRIVER: Unable to get FIFO_config")
            FIFO_vif = cfg.FIFO_vif;
        endfunction

        task run_phase(uvm_phase phase);
            super.run_phase(phase);
            forever begin
                seq_item_port.get_next_item(req);
                @(negedge FIFO_vif.clk);          // one item per clock cycle
                FIFO_vif.rst_n   = req.rst_n;
                FIFO_vif.wr_en   = req.wr_en;
                FIFO_vif.rd_en   = req.rd_en;
                FIFO_vif.data_in = req.data_in;
                seq_item_port.item_done();
            end
        endtask
    endclass
endpackage
