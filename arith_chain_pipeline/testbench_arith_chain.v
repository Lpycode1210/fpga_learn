// testbench.v
// Testbench for arith_chain_non_pipelined_4cyc and arith_chain_pipelined_4cyc
// Demonstrates equal latency for intermittent inputs and throughput difference for continuous inputs

`timescale 1ns / 1ps // Define time units

module testbench_arith_chain;

// Clock period
parameter CLK_PERIOD = 10; // 10ns clock period (100 MHz)

// Inputs to the modules
reg clk;
reg reset;
reg [7:0] test_data_in; // Input width 8
reg test_valid_in;

// Outputs from the non-pipelined module (4-cycle)
wire [9:0] np_data_out; // Output width 10
wire np_valid_out;

// Outputs from the pipelined module (4-cycle)
wire [9:0] p_data_out;  // Output width 10
wire p_valid_out;

// Instantiate the non-pipelined module (4-cycle version)
arith_chain_non_pipelined #(
    .DATA_WIDTH_IN(8),
    .DATA_WIDTH_OUT(10),
    .K1(5),
    .K2(3),
    .K3(10)
) np_dut ( // np_dut stands for Non-Pipelined Device Under Test
    .clk(clk),
    .reset(reset),
    .data_in(test_data_in),
    .valid_in(test_valid_in),
    .data_out(np_data_out),
    .valid_out(np_valid_out)
);

// Instantiate the pipelined module (4-cycle version)
arith_chain_pipelined #(
    .DATA_WIDTH_IN(8),
    .DATA_WIDTH_OUT(10),
    .K1(5),
    .K2(3),
    .K3(10)
) p_dut ( // p_dut stands for Pipelined Device Under Test
    .clk(clk),
    .reset(reset),
    .data_in(test_data_in),
    .valid_in(test_valid_in),
    .data_out(p_data_out),
    .valid_out(p_valid_out)
);

// Clock generation
initial begin
    clk = 0;
    forever #(CLK_PERIOD/2) clk = ~clk; // Generate clock signal
end

// Stimulus generation
initial begin
    // Initial reset
    reset = 1;
    test_data_in = 0;
    test_valid_in = 0;
    repeat (5) @(posedge clk); // Hold reset for 5 cycles (until T=50)

    reset = 0;
    @(posedge clk); // Release reset at T=60

    // --- Scenario 1: Intermittent Inputs (show equal latency) ---
    // Input 1 (Apply valid for one cycle)
    test_data_in = 1;
    test_valid_in = 1;
    @(posedge clk); // Input 1 applied at T=70

    test_valid_in = 0; // Deassert valid
    test_data_in = 0; // Drive data to a known state
    @(posedge clk); // T=80

    // Wait 4 cycles after valid_in went low (T=80). Next input at T=120.
    repeat (4) @(posedge clk); // T=90, T=100, T=110, T=120

    // Input 2 (Apply valid for one cycle)
    test_data_in = 2;
    test_valid_in = 1;
    @(posedge clk); // Input 2 applied at T=130

    test_valid_in = 0; // Deassert valid
    test_data_in = 0;
    @(posedge clk); // T=140

    // Wait 4 cycles after valid_in went low (T=140). Next input at T=180.
    repeat (4) @(posedge clk); // T=150, T=160, T=170, T=180

    // Input 3 (Apply valid for one cycle)
    test_data_in = 3;
    test_valid_in = 1;
    @(posedge clk); // Input 3 applied at T=190

    test_valid_in = 0; // Deassert valid
    test_data_in = 0;
    @(posedge clk); // T=200

    // Wait a bit before starting continuous inputs. Start continuous at T=220.
    repeat (2) @(posedge clk); // T=210, T=220

    // --- Scenario 2: Continuous Inputs (show throughput difference) ---
    test_valid_in = 1; // Keep valid high for continuous inputs

    test_data_in = 4; @(posedge clk); // Input 4 applied at T=230
    test_data_in = 5; @(posedge clk); // Input 5 applied at T=240
    test_data_in = 6; @(posedge clk); // Input 6 applied at T=250
    test_data_in = 7; @(posedge clk); // Input 7 applied at T=260
    test_data_in = 8; @(posedge clk); // Input 8 applied at T=270
    test_data_in = 9; @(posedge clk); // Input 9 applied at T=280
    test_data_in = 10; @(posedge clk); // Input 10 applied at T=290

    // Stop sending new data
    test_valid_in = 0;
    test_data_in = 0; // Drive to a known state
    repeat (10) @(posedge clk); // Let the pipeline flush out remaining data

    $stop; // Pause simulation
end


endmodule
