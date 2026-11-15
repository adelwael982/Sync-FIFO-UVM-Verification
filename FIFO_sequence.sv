package FIFO_sequences_pkg;
    import uvm_pkg::*;
    import FIFO_seq_item_pkg::*;
    `include "uvm_macros.svh"

    // reset
    class FIFO_reset_seq extends uvm_sequence #(FIFO_seq_item);
        `uvm_object_utils(FIFO_reset_seq)
        FIFO_seq_item item;

        function new(string name = "FIFO_reset_seq");
            super.new(name);
        endfunction

        task body();
            repeat (2) begin
                item = FIFO_seq_item::type_id::create("item");
                start_item(item);
                assert(item.randomize() with { rst_n == 0; wr_en == 0; rd_en == 0; })
                else
                    $error("run_phase", "SEQUENCE: randomization failed");
                finish_item(item);
            end
        endtask
    endclass

    // write only
    class FIFO_write_only_seq extends uvm_sequence #(FIFO_seq_item);
        `uvm_object_utils(FIFO_write_only_seq)
        FIFO_seq_item item;

        function new(string name = "FIFO_write_only_seq");
            super.new(name);
        endfunction

        task body();
            repeat (50) begin   // more than FIFO_DEPTH -> reaches full and overflow
                item = FIFO_seq_item::type_id::create("item");
                start_item(item);
                assert(item.randomize() with { rst_n == 1; wr_en == 1; rd_en == 0; })
                else
                    $error("run_phase", "SEQUENCE: randomization failed");
                finish_item(item);
            end
        endtask
    endclass

    // read only
    class FIFO_read_only_seq extends uvm_sequence #(FIFO_seq_item);
        `uvm_object_utils(FIFO_read_only_seq)
        FIFO_seq_item item;

        function new(string name = "FIFO_read_only_seq");
            super.new(name);
        endfunction

        task body();
            repeat (50) begin   // more than FIFO_DEPTH -> reaches empty and underflow
                item = FIFO_seq_item::type_id::create("item");
                start_item(item);
                assert(item.randomize() with { rst_n == 1; wr_en == 0; rd_en == 1; })
                else
                    $error("run_phase", "SEQUENCE: randomization failed");
                finish_item(item);
            end
        endtask
    endclass

    // write and read
    class FIFO_read_write_seq extends uvm_sequence #(FIFO_seq_item);
        `uvm_object_utils(FIFO_read_write_seq)
        FIFO_seq_item item;

        function new(string name = "FIFO_read_write_seq");
            super.new(name);
        endfunction

        task body();
            repeat (100) begin
                item = FIFO_seq_item::type_id::create("item");
                start_item(item);
                assert(item.randomize() with { rst_n == 1; wr_en == 1; rd_en == 1; })
                else
                    $error("run_phase", "SEQUENCE: randomization failed");
                finish_item(item);
            end
        endtask
    endclass


    // random (Main stimulus)
    class FIFO_main_seq extends uvm_sequence #(FIFO_seq_item);
        `uvm_object_utils(FIFO_main_seq)
        FIFO_seq_item item;

        function new(string name = "FIFO_main_seq");
            super.new(name);
        endfunction

        task body();
            repeat (10000) begin
                item = FIFO_seq_item::type_id::create("item");
                start_item(item);
                assert(item.randomize())
                else
                    $error("run_phase", "SEQUENCE: randomization failed");
                finish_item(item);
            end
        endtask
    endclass
endpackage
