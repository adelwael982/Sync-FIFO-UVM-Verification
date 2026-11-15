package FIFO_test_pkg;
    import uvm_pkg::*;
    import FIFO_config_pkg::*;
    import FIFO_env_pkg::*;
    import FIFO_sequences_pkg::*;
    `include "uvm_macros.svh"

    class FIFO_test extends uvm_test;
        `uvm_component_utils(FIFO_test)

        FIFO_env    env;
        FIFO_config cfg;

        FIFO_reset_seq      reset_seq;
        FIFO_write_only_seq write_only_seq;
        FIFO_read_only_seq  read_only_seq;
        FIFO_read_write_seq  read_write_seq;
        FIFO_main_seq       main_seq;

        function new(string name = "FIFO_test", uvm_component parent = null);
            super.new(name, parent);
        endfunction

        function void build_phase(uvm_phase phase);
            super.build_phase(phase);

            cfg = FIFO_config::type_id::create("cfg");
            if (!uvm_config_db#(virtual FIFO_if)::get(this, "", "FIFO_IF", cfg.FIFO_vif))
                `uvm_fatal("build_phase", "TEST: Unable to get the virtual interface FIFO_IF")
            uvm_config_db#(FIFO_config)::set(this, "*", "CFG", cfg);

            env            = FIFO_env::type_id::create("env", this);
            reset_seq      = FIFO_reset_seq::type_id::create("reset_seq");
            write_only_seq = FIFO_write_only_seq::type_id::create("write_only_seq");
            read_only_seq  = FIFO_read_only_seq::type_id::create("read_only_seq");
            read_write_seq  = FIFO_read_write_seq::type_id::create("read_write_seq");
            main_seq       = FIFO_main_seq::type_id::create("main_seq");
        endfunction

        task run_phase(uvm_phase phase);
            super.run_phase(phase);
            phase.raise_objection(this);
            `uvm_info("TEST", "Reset sequence",      UVM_MEDIUM)
            reset_seq.start(env.agt.sqr);

            `uvm_info("TEST", "Write-only sequence", UVM_MEDIUM)
            write_only_seq.start(env.agt.sqr);

            `uvm_info("TEST", "Read-only sequence",  UVM_MEDIUM)
            read_only_seq.start(env.agt.sqr);

            `uvm_info("TEST", "Read-Write sequence",  UVM_MEDIUM)
            read_write_seq.start(env.agt.sqr);

            `uvm_info("TEST", "Main random sequence", UVM_MEDIUM)
            main_seq.start(env.agt.sqr);

            // let the last item reach the DUT and be sampled by the monitor
            repeat (2) @(posedge cfg.FIFO_vif.clk);

            phase.drop_objection(this);
        endtask
    endclass
endpackage
