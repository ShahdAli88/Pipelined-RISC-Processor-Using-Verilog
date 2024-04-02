module instructionExcute(
    input [31:0] IR,
    input [3:0] top,  // Assuming top is 4 bits
    
    output reg [15:0] immediate16,
    output reg [31:0] PC,
    output reg [31:0] extended_immediate16,
    output reg current_state,
    output reg [31:0] Rd
);     
    // Registers
    reg [31:0] Rs1;
    reg [31:0] Rs2;
    reg [31:0] AdderRd;
    reg [31:0] AdderRs1;
    reg [31:0] AdderRs2;
    reg [31:0] AdderResult;
    reg [31:0] outputOfUpAdder;
    reg [31:0] stack [0:15]; // Assuming STACK_DEPTH is defined
    reg empty, full;
    reg push, pop; // Added these signals

    
    // Extenders
    reg [31:0] immediate26;
    reg [31:0] extended_immediate26;
    
    // Mux output
    reg [31:0] y;
    
    // Extract fields from IR
    assign immediate16 = IR[17:2];
    assign extended_immediate16 = {16'b0000000000000000, immediate16};
    assign immediate26 = IR[25:0];
    assign extended_immediate26 = {6'b000000, immediate26};
    
    // Assign addresses for registers
    assign AdderRd = IR[25:22];
    assign AdderRs1 = IR[21:18];
    assign AdderRs2 = IR[17:14];
    
    // Choose a value for the mux
    mux2x1 m(Rs2, immediate16, ALUSrc0, y);
    
    // Check the current instruction
    always @* begin
        case (IR[31:26])
            6'b001100: begin // Jump (J)
                current_state = 4;
                outputOfUpAdder = PC + extended_immediate26;  
                PC = outputOfUpAdder;
            end
            6'b001101: begin // Call
                current_state = 4;
                empty = (top == 0);
                full = (top == 15);
                
                // Push operation
                if (push && !pop && !full) begin
                    stack[top] = PC;
              //      top = top + 1;
                end
                
                PC = PC + extended_immediate26;
            end
            6'b001110: begin // Return
                current_state = 4;
                PC = stack[top];
            end
            6'b001111: begin // Push Rd
                current_state = 4;
                empty = (top == 0);
                full = (top == 15);
                
                // Push Rd
                if (push && !pop && !full) begin
                    stack[top] = Rd;
                 //   top = top + 1;
                end
            end
            6'b010000: begin // Pop Rd
                current_state = 4;
                Rd = stack[top]; // Store the top of the stack in Rd
            //    top = top - 1;
            end
            default: begin
                // Handle other instructions if needed
            end
        endcase
    end
endmodule
