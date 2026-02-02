`timescale 1ps / 1ps
`include "RISCV_pipeline.v"
module testbench;
    reg clock_proc;
    //reg clock_mem;
    reg rst;
    wire halt;
    wire [31:0] wb_pc;
    wire [31:0] wb_inst;


    Processor dut (
        .clk(clock_proc),
        .rst(rst),
        .halt(halt),
        .trace_writeback_pc(wb_pc),
        .trace_writeback_inst(wb_inst)
    );

    // Clock generation for clock_proc (period 10ns)
    always begin
        #5 clock_proc = ~clock_proc;
    end

    // Clock generation for clock_mem (phase-shifted by 90°, i.e., 2.5ns delay)
   

    // Reset sequence
    initial begin
        clock_proc = 0;
        rst = 1;
        #10;
        rst = 0;
    end

    // Simulation control: Dump waveforms and finish after a timeout
    initial begin
        //$dumpfile("processor_dump.vcd");
        $dumpvars(0, testbench);  // Dump all variables
        #500;  // Adjust this to run longer (e.g., #5000 for more cycles)
        $display("Simulation timeout reached. Check waveforms or memory dump.");
        $finish;
    end

    // Optional: Monitor halt (though it may not trigger due to ecall bug)
    always @(posedge halt) begin
        $display("Halt asserted at time %t", $time);
        $finish;
    end
endmodule