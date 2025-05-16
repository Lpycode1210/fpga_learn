// FSK_Modulator_tb.v
// Testbench for the FSK Modulator module
// Supports generating random data or using a fixed sequence
// Suitable for undergraduate teaching using Modelsim

module FSK_modulator_tb;

    // Testbench signals - use reg for signals driven in initial/always blocks
    reg clk;
    reg rst;
    reg data_in;

    // Testbench signal - use wire for outputs from the UUT (Unit Under Test)
    wire fsk_out;

    // Parameters
    parameter CLK_PERIOD = 10; // Clock period in ns (10ns -> 100MHz)

    // Define the duration of each data bit in terms of clock cycles.
    // This determines the data rate (baud rate).
    // Should be >> than the carrier periods (100, 200 clk cycles) to see frequency clearly.
    parameter BIT_DURATION_CLK_CYCLES = 300;

    // Calculate the data bit duration in nanoseconds
    localparam BIT_DURATION_NS = CLK_PERIOD * BIT_DURATION_CLK_CYCLES;

    // Define the number of data bits to generate in the sequence
    // This determines the total length of the random or fixed sequence.
    parameter NUM_BITS_TO_GENERATE = 10;

    // Parameter to switch between random data (1) and fixed data (0)
    // Set to 1 for random data sequence.
    // Set to 0 to use the FIXED_DATA_SEQUENCE defined below.
    parameter USE_RANDOM_DATA = 0; // <-- Change this parameter to 0 for fixed data

    // Define the fixed data sequence as an array of bits
    // This sequence is used when USE_RANDOM_DATA is 0.
    // The size of this array MUST match NUM_BITS_TO_GENERATE.
    // You can define your 10-bit sequence here (or more if NUM_BITS_TO_GENERATE changes).
    parameter [0:0] FIXED_DATA_SEQUENCE [0:NUM_BITS_TO_GENERATE-1] = '{
        // Example 10-bit sequence: 0, 1, 0, 1, 1, 0, 1, 0, 0, 1
        1'b0, 1'b1, 1'b0, 1'b1, 1'b1, 1'b0, 1'b1, 1'b0, 1'b0, 1'b1
        // You can change these bits to any sequence you want.
        // Make sure you have exactly NUM_BITS_TO_GENERATE entries.
    };


    // Variables declared at module level (needed for loops, random seed etc.)
    integer i; // Loop counter
    reg [31:0] seed; // Random number generation seed (optional)


    // Instantiate the module we are testing (Unit Under Test - UUT)
    FSK_modulator #(
        .COUNT_LIMIT_0(99), // Lower frequency
        .COUNT_LIMIT_1(49)  // Higher frequency
    ) uut (
        .clk(clk),
        .rst(rst),
        .data_in(data_in),
        .fsk_out(fsk_out)
    );

    // Clock Generation: Create a free-running clock signal
    always begin
        # (CLK_PERIOD / 2); // Wait for half the clock period
        clk = ~clk;         // Toggle the clock signal
    end

    // Test Sequence: Apply reset and generate stimulus (random or fixed data)
    // This block executes only once at the beginning of the simulation.
    initial begin
        // Variables i and seed are declared above.

        // Initialize the random seed (optional, makes results repeatable)
        // seed = 123; // Use a fixed number for repeatable sequence
        // $srandom(seed); // Or use $time() for a different sequence each run
        // For a teaching example, you can just use $random directly without seeding.

        // 1. Initialize signals at time 0
        clk = 0;
        rst = 1;
        data_in = 0; // Initial value before sequence starts

        // 2. Apply reset sequence
        # (CLK_PERIOD * 2); // Hold reset for 2 clock cycles
        rst = 0;            // Deassert reset

        // 3. Wait for the module to settle after reset
        # (CLK_PERIOD * 10); // Wait for 10 clock cycles


        // 4. Generate and apply data bits periodically (random or fixed)

        if (USE_RANDOM_DATA) begin
            // --- Generate Random Data Sequence ---
            $display("--- Generating Random Data Sequence (%0d bits) ---", NUM_BITS_TO_GENERATE);
            repeat (NUM_BITS_TO_GENERATE) begin
                // Generate a random value (0 or 1) using $random.
                // $random returns a 32-bit signed integer. % 2 gives 0 or 1.
                data_in = $random % 2;

                // Wait for the duration of one data bit
                # (BIT_DURATION_NS);
            end
            $display("--- Random Data Generation Finished ---");

        end else begin
            // --- Generate Fixed Data Sequence ---
            $display("--- Using Fixed Data Sequence (%0d bits) ---", NUM_BITS_TO_GENERATE);
            // --- Optional check: Ensure FIXED_DATA_SEQUENCE size matches NUM_BITS_TO_GENERATE ---
            // This check requires SystemVerilog or a lenient Verilog compiler.
            // if ($size(FIXED_DATA_SEQUENCE) != NUM_BITS_TO_GENERATE) begin
            //    $display("ERROR: FIXED_DATA_SEQUENCE size (%0d) does not match NUM_BITS_TO_GENERATE (%0d)!",
            //             $size(FIXED_DATA_SEQUENCE), NUM_BITS_TO_GENERATE);
            //    $stop; // Stop simulation on error
            // end else begin
                for (i = 0; i < NUM_BITS_TO_GENERATE; i = i + 1) begin
                    data_in = FIXED_DATA_SEQUENCE[i]; // Get bit from fixed sequence
                     # (BIT_DURATION_NS);              // Wait for the duration of the current bit
                end
                $display("--- Fixed Data Sequence Generation Finished ---");
            // end // End of optional check
        end


        // 5. Stop the simulation after the data sequence has passed.
        // Using $stop as requested.
        $stop;

    end

    // Setup waveform dumping for viewing in Modelsim
    initial begin
        // Specify the name of the waveform dump file
        $dumpfile("Fsk_modulator.vcd"); // You can keep this name, or change it
        // Specify which signals to dump (dump all signals in the testbench and its hierarchy)
        $dumpvars(0, FSK_modulator_tb); // Use the correct testbench module name
    end

endmodule
