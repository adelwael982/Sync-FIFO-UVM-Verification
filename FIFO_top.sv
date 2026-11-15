import uvm_pkg::*;
`include "uvm_macros.svh"
import FIFO_test_pkg::*;

module FIFO_top();

    // Clock generation
    bit clk;
    initial begin
        clk=0;
        forever begin
            #5;
           clk=~clk; 
        end
    end

    // Instantiations
    FIFO_if f_if(clk);
    FIFO   DUT(f_if);

    bind FIFO FIFO_sva ASS (f_if);


    initial begin
        uvm_config_db#(virtual FIFO_if)::set(null, "uvm_test_top", "FIFO_IF", f_if);
        run_test("FIFO_test");
    end

endmodule
