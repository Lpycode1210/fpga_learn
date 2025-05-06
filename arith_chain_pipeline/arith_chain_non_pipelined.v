// arith_chain_non_pipelined_4cyc.v
// Correct Non-Pipelined version with 4 cycles latency
// (1 cycle input registration + 3 cycles for the three arithmetic operations)
// Accepts new input (via valid_in) ONLY when in the Idle state (state 0).
// Input data is DROPPED if valid_in is high when the module is not in the Idle state (state 0).

module arith_chain_non_pipelined #( // Module name reflects 4-cycle latency
    parameter DATA_WIDTH_IN = 8,
    parameter DATA_WIDTH_OUT = 10, // To accommodate potential increase
    parameter K1 = 5,
    parameter K2 = 3,
    parameter K3 = 10
) (
    input wire clk,
    input wire reset,
    input wire [DATA_WIDTH_IN-1:0] data_in,
    input wire valid_in,          // Indicates when data_in is valid and processing should start

    output wire [DATA_WIDTH_OUT-1:0] data_out,
    output wire valid_out         // Indicates when data_out is valid
);

// Internal registers
// State machine:
// 0: Idle, waiting for input. Accepts input if valid_in is high.
// 1: Register Input & Start Calc 1 (+K1)
// 2: Register Calc 1 & Start Calc 2 (-K2)
// 3: Register Calc 2 & Start Calc 3 (+K3) / Output
reg [1:0] state; // Needs 2 bits for states 0 to 3

reg [DATA_WIDTH_IN-1:0] input_reg; // Register to hold data_in when valid_in is high (captured in state 0)
reg [DATA_WIDTH_OUT-1:0] temp1_reg; // Result after +K1, registered at end of State 1
reg [DATA_WIDTH_OUT-1:0] temp2_reg; // Result after -K2, registered at end of State 2
reg [DATA_WIDTH_OUT-1:0] data_out_reg; // Final output result, registered at end of State 3
reg valid_out_reg; // Output valid signal

// Constants
wire [DATA_WIDTH_OUT-1:0] const_K1 = K1;
wire [DATA_WIDTH_OUT-1:0] const_K2 = K2;
wire [DATA_WIDTH_OUT-1:0] const_K3 = K3;

// Output assignments
assign data_out = data_out_reg;
assign valid_out = valid_out_reg;

// Main state machine/sequencer
always @(posedge clk or posedge reset) begin
    if (reset) begin
        state <= 0;
        input_reg <= 0;
        temp1_reg <= 0;
        temp2_reg <= 0;
        data_out_reg <= 0;
        valid_out_reg <= 0;
    end else begin
        // Default: output valid goes low unless set high in state 3
        valid_out_reg <= 0;

        case (state)
            0: begin // Idle state, waiting for valid input. Handles new tasks here.
                if (valid_in) begin
                    input_reg <= data_in; // Register input data when valid
                    state <= 1; // Move to processing stage 1 in the next cycle
                end else begin
                    state <= 0; // Stay in idle
                end
            end
            1: begin // Processing Stage 1: +K1. Module is busy. Inputs arriving here are dropped.
                temp1_reg <= {{(DATA_WIDTH_OUT - DATA_WIDTH_IN){1'b0}}, input_reg} + const_K1; // Perform +K1 calculation and register
                state <= 2; // Move to processing stage 2 in the next cycle
            end
            2: begin // Processing Stage 2: -K2. Module is busy. Inputs arriving here are dropped.
                temp2_reg <= temp1_reg - const_K2; // Perform -K2 calculation and register
                state <= 3; // Move to processing stage 3 in the next cycle
            end
            3: begin // Processing Stage 3: +K3 and Output. Module is busy. Inputs arriving here are dropped.
                data_out_reg <= temp2_reg + const_K3; // Perform +K3 calculation and register the final result
                valid_out_reg <= 1; // Output is valid this cycle
                state <= 0; // Go back to idle in the next cycle, ready for a new task
            end
            default: begin // Should not happen
                state <= 0;
            end
        endcase
    end
end

endmodule