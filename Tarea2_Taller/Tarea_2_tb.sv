module Tarea_2_tb();

    // Inputs
    reg rst;
    reg clk;
    reg M;
    
    // Outputs
    wire [7:0] estado_reg;

    // Instantiate the module under test
    Tarea_2 dut (
        .rst(rst),
        .clk(clk),
        .M(M),
        .estado_reg(estado_reg)
    );

    // Clock generation
    always #10 clk = ~clk;

    // Initialize inputs
    initial begin
        rst = 1;
        clk = 0;
        M = 0;
        
        // Wait for reset to deassert
        #10 rst = 0;
        
        // Case 1: No maintenance button press
        #60; // Wait for 200 cycles
        // Check estado_reg for 0xFF
        $display("Case 1: Estado del registro: %h", estado_reg);
        
        // Case 2: Maintenance button pressed before 200 cycles
        M = 1; // Press maintenance button
        #10; // Wait for one clock cycle
        M = 0; // Release maintenance button
        // Wait for state transition to ESTADO_INICIO
        repeat(3) @(posedge clk);
        // Check estado_reg for maintenance count
        $display("Case 2: Estado del registro: %h", estado_reg);
        
        // Case 3: Maintenance button pressed after 200 cycles
        // Reset
        rst = 1;
        #10 rst = 0;
        // Wait for 200 cycles
        #60;
        M = 1; // Press maintenance button
        #10; // Wait for one clock cycle
        M = 0; // Release maintenance button
        // Wait for state transition to ESTADO_ERROR
        repeat(3) @(posedge clk);
        // Check estado_reg for 0xFF
        $display("Case 3: Estado del registro: %h", estado_reg);

    end

endmodule
