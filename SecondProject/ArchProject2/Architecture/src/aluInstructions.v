module aluInstructions(
    input [5:0] OpCode,
	input [31:0] Rd,
	input [31:0] Y,
    input [31:0] extended_immediate16,   
    input [1:0] ALUOp,
    output reg current_state,
    output reg [31:0] PC
);

    reg [31:0] operandA;
    reg [31:0] operandB;
    reg [31:0] outputOfALU;
    reg zero;
    reg greater_than;
    reg less_than;
    reg [31:0] outputOfBTA;
    // Assign operands
    assign operandA = Rd;
    assign operandB = Y;

    // Perform ALU operation based on ALUOp
    always @* begin
        case (ALUOp)
            2'b00: outputOfALU = operandA + operandB;   // Addition
            2'b01: outputOfALU = operandA - operandB;   // Subtraction
            2'b10: outputOfALU = operandA & operandB;   // Bitwise AND
            default: outputOfALU = 32'b0;               // Default case: result is 0
        endcase
    end

    // Set flags
    always @* begin
        zero = (outputOfALU == 32'b0);                  // Set zero flag if the result is zero
        greater_than = (outputOfALU > 32'h0);           // Set greater than flag
        less_than = (outputOfALU < 32'h0);              // Set less than flag
    end

    // Check instructions
    always @* begin
        outputOfBTA = 32'b0;                            // Initialize outputOfBTA

        // Check BGT instruction
        if (OpCode == 6'b001000) begin
            if (greater_than) begin
                current_state = 4; 
                outputOfBTA <= PC + extended_immediate16;
                PC <= outputOfBTA;
            end else begin
                PC <= PC + 1;
                current_state = 4; 
            end
        end

        // Check BLT instruction
        if (OpCode == 6'b001001) begin
            if (less_than) begin 
                current_state = 4; 
                outputOfBTA <= PC + extended_immediate16;
                PC <= outputOfBTA;
            end else begin
                PC <= PC + 1;
                current_state = 4;
            end
        end

        // Check BEQ instruction
        if (OpCode == 6'b001010) begin
            if (zero) begin
                current_state = 4; 
                outputOfBTA <= PC + extended_immediate16;
                PC <= outputOfBTA;
            end else begin
                PC <= PC + 1;
                current_state = 4;
            end
        end

        // Check BNE instruction
        if (OpCode == 6'b001011) begin
            if (!zero) begin
                current_state = 4; 
                outputOfBTA <= PC + extended_immediate16;
                PC <= outputOfBTA;
            end else begin
                PC <= PC + 1;
                current_state = 4; 
            end
        end
    end
endmodule


module aluInstructions_tb();

    // Inputs
    reg [5:0] OpCode;
    reg [31:0] Rd;
    reg [31:0] Y;
    reg [15:0] extended_immediate16;
    reg [1:0] ALUOp;

    // Outputs
    reg current_state;
    reg [31:0] PC;

    // Instantiate the ALU instructions module
    aluInstructions dut (
        .OpCode(OpCode),
        .Rd(Rd),
        .Y(Y),
        .extended_immediate16(extended_immediate16),
        .ALUOp(ALUOp),
        .current_state(current_state),
        .PC(PC)
    );

    // Initialize inputs
    initial begin

        // Test Case 1: BGT with greater_than flag set
        OpCode = 6'b001000;
        Rd = 32'h0000000A;    // Example value for Rd
        Y = 32'h00000005;     // Example value for Y
        extended_immediate16 = 16'h0002;  // Example immediate value
        ALUOp = 2'b00;         // Addition operation
        #10;

        // Test Case 2: BLT with less_than flag set
        OpCode = 6'b001001;
        Rd = 32'hFFFFFFFF;    // Example value for Rd (negative)
        Y = 32'h0000000A;     // Example value for Y
        extended_immediate16 = 16'h0002;  // Example immediate value
        ALUOp = 2'b01;          // Subtraction operation
        #10;

        // Test Case 3: BEQ with zero flag set
        OpCode = 6'b001010;
        Rd = 32'h00000000;    // Rd is set to zero
        Y = 32'h00000000;     // Y is set to zero
        extended_immediate16 = 16'h0003;  // Example immediate value
        ALUOp = 2'b00;         // Addition operation
        #10;

        // Test Case 4: BNE with non-zero result
        OpCode = 6'b001011;
        Rd = 32'h00000001;     // Example value for Rd
        Y = 32'h00000002;     // Example value for Y
        extended_immediate16 = 16'h0003;  // Example immediate value
        ALUOp = 2'b00;          // Addition operation
        #10;
		
		       // Test Case 1: BGT with greater_than flag set
		OpCode = 6'b001000;
		Rd = 32'h0000000A;    // Example value for Rd
		Y = 32'h00000005;     // Example value for Y
		extended_immediate16 = 16'h0002;  // Example immediate value
		ALUOp = 2'b00;         // Addition operation
		#10;
		
		// Test Case 2: BLT with less_than flag set
		OpCode = 6'b001001;
		Rd = 32'hFFFFFFFF;    // Example value for Rd (negative)
		Y = 32'h0000000A;     // Example value for Y
		extended_immediate16 = 16'h0002;  // Example immediate value
		ALUOp = 2'b01;          // Subtraction operation
		#10;
		
		// Test Case 3: BEQ with zero flag set
		OpCode = 6'b001010;
		Rd = 32'h00000000;    // Rd is set to zero
		Y = 32'h00000000;     // Y is set to zero
		extended_immediate16 = 16'h0003;  // Example immediate value
		ALUOp = 2'b00;         // Addition operation
		#10;
		
		// Test Case 4: BNE with non-zero result
		OpCode = 6'b001011;
		Rd = 32'h00000001;     // Example value for Rd
		Y = 32'h00000002;     // Example value for Y
		extended_immediate16 = 16'h0003;  // Example immediate value
		ALUOp = 2'b00;          // Addition operation
		#10;
		
		// Test Case 5: Other ALU operations (Addition, Subtraction, Bitwise AND, etc.)
		OpCode = 6'bXXXXXX;     // Your opcode here
		Rd = 32'hXXXXXXXX;      // Your value for Rd here
		Y = 32'hXXXXXXXX;       // Your value for Y here
		extended_immediate16 = 16'hXXXX;  // Your immediate value here
		ALUOp = 2'bXX;          // Your ALU operation here
		#10;
		

        // Finish simulation
        $finish;
    end

    // Display PC value during simulation
    always @* begin
        $display("PC = %h", PC);
    end
endmodule
