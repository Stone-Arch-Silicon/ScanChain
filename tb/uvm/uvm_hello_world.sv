import uvm_pkg::*;
`include "uvm_macros.svh"

class hello_test extends uvm_test;

    `uvm_component_utils(hello_test)

    function new(string name = "hello_test",
                 uvm_component parent = null);
        super.new(name, parent);
    endfunction

    task run_phase(uvm_phase phase);
        phase.raise_objection(this);

        `uvm_info("HELLO",
                  "UVM is working!",
                  UVM_LOW)

        phase.drop_objection(this);
    endtask

endclass

module tb_top;
    initial begin
        run_test("hello_test");
    end
endmodule