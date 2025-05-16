// fsk_modulator.v
// FSK Modulator - Generates square waves at two frequencies based on input data
// Suitable for undergraduate teaching using Modelsim

module FSK_modulator #(
    // Define parameters for frequency generation
    // The output frequency is determined by the system clock frequency (clk_freq)
    // and the COUNT_LIMIT parameter:
    // fsk_freq = clk_freq / (2 * (COUNT_LIMIT + 1))
    // A smaller COUNT_LIMIT + 1 value results in a HIGHER Frequency.
    // We choose two distinct values to make the frequency shift visually clear.

    parameter COUNT_LIMIT_0 = 99, // Count limit for data_in = 0 (Lower Frequency)
                                  // Period = 2 * (99+1) = 200 clk cycles
                                  // f0 = clk_freq / 200

    parameter COUNT_LIMIT_1 = 49  // Count limit for data_in = 1 (Higher Frequency)
                                  // Period = 2 * (49+1) = 100 clk cycles
                                  // f1 = clk_freq / 100. Note: f1 = 2 * f0
) (
    input wire clk,       // System clock
    input wire rst,       // Asynchronous reset (active high)
    input wire data_in,   // 1-bit digital data input (0 or 1)
    output reg fsk_out    // FSK modulated square wave output
);

    // --- MODIFICATION HERE ---
    // Calculate maximum limit (needed only for the commented out $clogb2 or manual check)
    // localparam MAX_COUNT_LIMIT = (COUNT_LIMIT_0 > COUNT_LIMIT_1) ? COUNT_LIMIT_0 : COUNT_LIMIT_1;
    // Determine the number of bits needed for the counter.
    // Replacing $clogb2 calculation with a fixed width to avoid potential compiler issues.
    // A width of 10 bits is sufficient for COUNT_LIMITs up to 1023.
    localparam COUNTER_WIDTH = 10;
    // --- END OF MODIFICATION ---


    // Register to hold the current count value
    reg [COUNTER_WIDTH-1:0] counter;

    // Wire to hold the count limit based on the current data_in value
    wire [COUNTER_WIDTH-1:0] current_count_limit;

    // Combinational logic: Select the count limit based on data_in
    // If data_in is 1, use COUNT_LIMIT_1 (higher freq); otherwise use COUNT_LIMIT_0 (lower freq).
    assign current_count_limit = data_in ? COUNT_LIMIT_1 : COUNT_LIMIT_0;

    // Sequential logic: Clocked process for counter and output toggling
    // This block runs on the positive edge of the clock or the positive edge of reset.
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            // Reset state: clear counter and set output to a known state (low)
            counter <= 0;
            fsk_out <= 1'b0;
        end else begin
            // Normal operation (when not in reset)
            // Check if the counter has reached the currently selected limit
            // Ensure current_count_limit fits within the counter width.
            if (counter == current_count_limit) begin
                // If limit reached:
                counter <= 0;         // Reset counter to 0
                fsk_out <= ~fsk_out;  // Toggle the output signal (0 to 1, or 1 to 0)
            end else begin
                // If limit not reached:
                counter <= counter + 1; // Increment the counter
            end
        end
    end

endmodule
