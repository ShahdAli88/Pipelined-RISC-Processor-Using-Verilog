module afterAlu(
    input [31:0] Rd,
    input [4:0] Function,
    input [1:0] Type,
    input W_mem,
    input R_mem,
    input [31:0] outputOfALU,
    input [31:0] data_memory [0:255], // Assuming data_memory is 256 entries deep
    input [3:0] top, // Assuming top is 4 bits
    output reg [31:0] data_out,
    output reg [31:0] outputOfTheStore,
    output reg [31:0] PC,
    output reg current_state
);

// Registers
reg [31:0] address;
reg [31:0] data_in;
reg [31:0] outputOfStack;
reg [31:0] stack [0:15]; // Assuming STACK_DEPTH is 16
reg [3:0] new_top;
reg empty, full;
reg push, pop;

// Assignments
always @* begin
    address = outputOfALU;
    data_in = Rd;

    if (W_mem && !R_mem) begin
        // Store Instruction
        outputOfTheStore <= data_in; // Non-blocking assignment
    end else if (!W_mem && R_mem) begin
        // Load Instruction
        data_out <= data_memory[address]; // Non-blocking assignment
    end

    // Check the current instruction is Store or not
    if (Type == 2'b10 && Function == 5'b00011) begin
        current_state = 4;

        // Check if the current instruction is the last instruction in the function

        // Stack Part
        empty = (top == 0);
        full = (top == 15); // Assuming STACK_DEPTH is 16

        // Pop operation
        if (pop && !push && !empty) begin
            new_top = top - 1; // Move the top pointer down
            outputOfStack = stack[top];
            PC <= outputOfStack; // Non-blocking assignment
            PC <= PC + 1; // Non-blocking assignment
        end else begin
            PC <= PC + 1; // Non-blocking assignment
        end
    end else begin
        PC <= PC + 1; // Non-blocking assignment
    end
end

endmodule
