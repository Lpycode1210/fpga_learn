// arith_chain_pipelined_4cyc.v
// Pipelined version with 4 cycles latency
// CORRECTED: Moved wire declarations and assign statements outside always block

module arith_chain_pipelined #(
    parameter DATA_WIDTH_IN = 8,
    parameter DATA_WIDTH_OUT = 10, // Same width as non-pipelined
    parameter K1 = 5,
    parameter K2 = 3,
    parameter K3 = 10
) (
    input wire clk,
    input wire reset,
    input wire [DATA_WIDTH_IN-1:0] data_in,
    input wire valid_in,

    output wire [DATA_WIDTH_OUT-1:0] data_out,
    output wire valid_out
);

// --- Register Declarations (Outputs of Stages) ---
// These registers hold the state of the pipeline stages, updated by the clock
reg [DATA_WIDTH_IN-1:0] stage1_reg_data; reg stage1_reg_valid; // Input Registration Stage (Stage 1)
reg [DATA_WIDTH_OUT-1:0] stage2_reg_data; reg stage2_reg_valid; // After +K1 Calculation (Stage 2)
reg [DATA_WIDTH_OUT-1:0] stage3_reg_data; reg stage3_reg_valid; // After -K2 Calculation (Stage 3)
reg [DATA_WIDTH_OUT-1:0] stage4_reg_data; reg stage4_reg_valid; // After +K3 Calculation (Stage 4 / Final Output)


// --- Combinatorial Logic Wires ---
// These wires represent the combinatorial calculations performed *between* the register stages.
// Their values are continuously calculated based on their inputs (the previous stage's register outputs).
wire [DATA_WIDTH_OUT-1:0] stage2_calc_data; // Result of +K1 logic (input to stage2_reg)
wire stage2_calc_valid;                     // Valid signal propagating

wire [DATA_WIDTH_OUT-1:0] stage3_calc_data; // Result of -K2 logic (input to stage3_reg)
wire stage3_calc_valid;                     // Valid signal propagating

wire [DATA_WIDTH_OUT-1:0] stage4_calc_data; // Result of +K3 logic (input to stage4_reg / final output)
wire stage4_calc_valid;                     // Valid signal propagating


// --- Constants ---
wire [DATA_WIDTH_OUT-1:0] const_K1 = K1;
wire [DATA_WIDTH_OUT-1:0] const_K2 = K2;
wire [DATA_WIDTH_OUT-1:0] const_K3 = K3;


// --- Combinatorial Logic (outside always block using assign) ---
// These assign statements define the logic for each pipeline stage's calculation.
// They run continuously whenever their inputs change.
// Calculation for Stage 2 (+K1): Uses output of Stage 1 Register
assign stage2_calc_data = {{(DATA_WIDTH_OUT - DATA_WIDTH_IN){1'b0}}, stage1_reg_data} + const_K1;
assign stage2_calc_valid = stage1_reg_valid; // Valid signal propagates

// Calculation for Stage 3 (-K2): Uses output of Stage 2 Register
assign stage3_calc_data = stage2_reg_data - const_K2;
assign stage3_calc_valid = stage2_reg_valid; // Valid signal propagates

// Calculation for Stage 4 (+K3): Uses output of Stage 3 Register
assign stage4_calc_data = stage3_reg_data + const_K3;
assign stage4_calc_valid = stage3_reg_valid; // Valid signal propagates


// --- Sequential Logic (inside always block) ---
// This block describes the registers which are updated at the positive clock edge.
always @(posedge clk or posedge reset) begin
    if (reset) begin
        // Reset all pipeline registers
        stage1_reg_data <= 0; stage1_reg_valid <= 0;
        stage2_reg_data <= 0; stage2_reg_valid <= 0;
        stage3_reg_data <= 0; stage3_reg_valid <= 0;
        stage4_reg_data <= 0; stage4_reg_valid <= 0;
    end else begin
        // Stage 1: Input Registration
        // Inputs to the pipeline come from data_in and valid_in
        stage1_reg_data <= data_in;
        stage1_reg_valid <= valid_in;

        // Stage 2: Register output of Stage 2 Calculation
        // Inputs to Stage 2 Register come from Stage 2 Combinatorial Logic (stage2_calc_data/valid)
        stage2_reg_data <= stage2_calc_data;
        stage2_reg_valid <= stage2_calc_valid;

        // Stage 3: Register output of Stage 3 Calculation
        // Inputs to Stage 3 Register come from Stage 3 Combinatorial Logic (stage3_calc_data/valid)
        stage3_reg_data <= stage3_calc_data;
        stage3_reg_valid <= stage3_calc_valid;

        // Stage 4: Register output of Stage 4 Calculation (Final Output)
        // Inputs to Stage 4 Register come from Stage 4 Combinatorial Logic (stage4_calc_data/valid)
        stage4_reg_data <= stage4_calc_data; // This is the final output register
        stage4_reg_valid <= stage4_calc_valid; // This is the final output valid
    end // else (reset)
end // always


// --- Output Assignments ---
// The module outputs are the outputs of the final pipeline stage's register
assign data_out = stage4_reg_data;
assign valid_out = stage4_reg_valid;

endmodule
