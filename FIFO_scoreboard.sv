package FIFO_scoreboard_pkg;
    import uvm_pkg::*;
    import FIFO_shared_pkg::*;
    import FIFO_seq_item_pkg::*;
    `include "uvm_macros.svh"

    class FIFO_scoreboard extends uvm_scoreboard;
        `uvm_component_utils(FIFO_scoreboard)

        uvm_analysis_export #(FIFO_seq_item) sb_export;
        uvm_tlm_analysis_fifo#(FIFO_seq_item)sb_fifo;
        FIFO_seq_item seq_item;
        // Reference model state
        logic [FIFO_WIDTH-1:0] ref_queue[$];
        int                    count_ref;
        logic [FIFO_WIDTH-1:0] data_out_ref;
        int error_count=0;
        int correct_count=0;
        // error_count / correct_count live in FIFO_shared_pkg

        function new(string name = "FIFO_scoreboard", uvm_component parent = null);
            super.new(name, parent);
        endfunction

        function void build_phase(uvm_phase phase);
            super.build_phase(phase);
            sb_export = new("sb_export", this);
            sb_fifo   = new("sb_fifo",this);
        endfunction

        function void connect_phase(uvm_phase phase);
            super.connect_phase(phase);
            sb_export.connect(sb_fifo.analysis_export);
        endfunction


        task run_phase(uvm_phase phase);
            super.run_phase(phase);
            forever begin
                sb_fifo.get(seq_item);
                // the item holds the inputs of one cycle and the outputs of that same cycle,
                // so update the reference with this item and compare against the current reference
                reference_model(seq_item);
                if (data_out_ref === seq_item.data_out) begin
                    `uvm_info("run_phase", $sformatf("Data output matches: %s", seq_item.convert2string()),UVM_HIGH);
                    correct_count++;
                end
                else begin
                    `uvm_error("run_phase", $sformatf("Data output mismatch: expected=%0h actual=%0h | %s",
                                               data_out_ref, seq_item.data_out, seq_item.convert2string()));
                    error_count++;
                end
            end
        endtask 


        function void reference_model(FIFO_seq_item item);
            int count_before;

            if (!item.rst_n) begin
                count_ref = 0;
                ref_queue.delete();
            end
            else begin
                count_before = count_ref;

                if (item.wr_en && (count_before < FIFO_DEPTH))
                    ref_queue.push_back(item.data_in);

                if (item.rd_en && (count_before > 0))
                    data_out_ref = ref_queue.pop_front();

                count_ref = count_before
                          + ((item.wr_en && (count_before < FIFO_DEPTH)) ? 1 : 0)
                          - ((item.rd_en && (count_before > 0))          ? 1 : 0);
            end
        endfunction

        function void report_phase(uvm_phase phase);
            super.report_phase(phase);
            `uvm_info("report_phase", $sformatf("Test Finished  Correct_Count=%0d  Error_Count=%0d",
                                      correct_count, error_count), UVM_LOW)
        endfunction
    endclass
endpackage
