// Define global variables
reg [2:0]current_state;
reg [2:0]next_state;
reg [31:0]IR;	


module allSystem(
	
	input clk,
	input reset,
	
	// Observing the values of the generated signals
	output reg PCSrc1, 
	output reg PCSrc0,	   
	output reg RegWrite, 
	output reg ALUSrc0, 
	output reg [2:0] ALUOp,
	output reg R_mem, 
	output reg W_mem,
	output reg WB,
	output reg push,
	output reg pop,
	
	
	///Instruction Decode Part 
	output reg [31:0] Rs1, // (Bus A )Output data from register 1
    output reg [31:0] Rs2, // (Bus B) Output data from register 2
    output reg [31:0] Rd, // (Bus W) Output data from register 3
	
	
	///ALU Part
	output reg [31:0] outputOfALU, // Just to verify that the ALU works properly 
	
	///immediate14 Part
	output reg [31:0]extended_immediate16, 
	///immediate26 Part
	output reg [31:0]extended_immediate26,	
	
	///just for depugging the code for store
	output reg [31:0]outputOfTheStore, 		
);	   

	/// Instruction Fetch
	reg [31:0] memory [0:31];
	reg [31:0] PC; 	 
	
	///Instruction Decode
	reg [31:0] writeData; 
 
    reg [31:0]Y;
	reg [4:0] Registers[0:31];
	
	
	reg [5:0]AddressOfRd;	 // Address for Rd
	reg [5:0]AddressOfRs1;  // Address for RS1
	reg [5:0]AddressOfRs2;  // Address for RS2	

		
	///Control Unit Signals Generated
	reg [5:0]OpCode;  
	
	///ALU Part	
	 reg [31:0] operandA;    // Operand A
     reg [31:0] operandB;    // Operand B  
	 reg zero;
     reg greater_than;
     reg less_than;
		 

	//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	///Data Memory 	   
	reg [31:0] address,data_in;
    reg [31:0] data_out;
	
	///Data Memory
//	reg [31:0] data_memory [31:0];	
	 reg [31:0] data_memory [31:0];
	//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~	
	
	///Write back stage
    reg [31:0]outOfDownMux;
	
	//Extenders 14 and 24
	reg [15:0] immediate16;  //16 
	reg [25:0] immediate26;		  // 26
	
	//Up adder
	reg [31:0] outputOfUpAdder;	
	
	///Stack Part
	reg [31:0] outputOfStack;
	reg empty,full;				
	parameter STACK_DEPTH = 16;   // This is the maximum # of inner functions for this stack
    reg [31:0] stack [STACK_DEPTH-1:0];
    reg [2:0] top;	 //Stack Pointer	
	
	//Branch Target Address
	reg [31:0] outputOfBTA;
	
	///outputOfMuxAfterBTA
	reg [31:0]outputOfMuxAfterBTA;	  
	
	///outputOfMuxAfterStack
	reg [31:0]outputOfMuxAfterStack;

	initial begin 
		
		
        $display("Test Case 1: Load-Store");
        // Set memory values
        memory[0] = 32'h10040034; // LW Rd = 9
        memory[1] = 32'h18040004; // SW Rd
        // Initialize registers
        Registers[9] = 32'h00001234; // Set a value in register 9
        // Apply clock cycles to execute instructions

        // Verify the memory content and register value after execution
        $display("Memory content at address 4: %h", data_memory[4]);
        $display("Register 9 after load: %h", Registers[9]);


        // Test case 2: Arithmetic Operations
        $display("Test Case 2: Arithmetic Operations");
        // Set memory values
        memory[0] = 32'h08840000; // ADD Rd = Rd + 8 (Rd = 17)
        memory[1] = 32'h10841000; // SUB Rd = Rd - 7 (Rd = 10)
        // Initialize registers
        Registers[15] = 32'h00000008; // Set initial value in register 17
        // Apply clock cycles to execute instructions

        // Verify the values in register 17 after arithmetic operations
        $display("Register 17 after ADD operation: %h", Registers[15]);
        $display("Register 17 after SUB operation: %h", Registers[15]);
     	
	

	
	end	
	
	initial top = 3'b000;
	
	
	integer i;
	always @(posedge clk)  
		case (current_state) 	
		 	0: 
				next_state = 1;
			1: 
				next_state = 2;
			2: 
				next_state = 3;
			3: 
				next_state = 4;
			4: 
				next_state = 0;
 		endcase	   	
		 
		 
	always @(posedge clk) 
 		current_state = next_state;
	
	
	always @(posedge clk, posedge reset)
		
		if (reset)	begin  
			
			current_state = 4;
			PC <= 32'h00000000;		   			
			Rs1 <= 32'd0;
			Rs2 <= 32'd0;
			Rd <= 32'd0;
			Y <= 32'h00000000;	
			
			
			for (i = 0; i < 31; i = i + 1)
     			 Registers[i] <= 32'h00000000;
		end	   

	else  if (current_state == 0) begin	
		//instruction fetch and set signals:
			    IR = memory[PC]; // Fetch instruction from memory using PC	
			    // Extract the opcode from the instruction
			    OpCode = IR[31:26];
					
					//$display ("%b", OpCode);
					
			
					
					//pop signal
					pop = IR[0];  
					
					
					/// R-type		
					if (OpCode == 6'b000000 || OpCode == 6'b000001 || OpCode == 6'b000010) begin ///ADD	|| AND || SUB
			
							PCSrc1 = 1'b1;
							PCSrc0 = 1'b0;
						    RegWrite = 1'b1; 
							ALUSrc0 = 1'b0; 
							
							if (OpCode == 6'b000000)
								ALUOp = 2'b10;
							else if (OpCode == 6'b000001) 
								ALUOp = 2'b00;
							else
								ALUOp = 2'b01;
							
					        R_mem = 1'b0; 
					        W_mem = 1'b0;
					        WB = 1'b1;
							push = 1'b0;
					end
							
					/// I-Type	 
					else if (OpCode == 6'b000011 || OpCode == 6'b000100) begin	   ///ANDI || ADDI
							
							PCSrc1 = 1'b1;
							PCSrc0 = 1'b0;
						    RegWrite = 1'b1; 
							ALUSrc0 = 1'b1; 
							
							if (OpCode == 6'b000011)   // ANDI
								ALUOp = 2'b10;
							else   
								ALUOp = 2'b00;
				
							
					        R_mem = 1'b0; 
					        W_mem = 1'b0;
					        WB = 1'b1;
							push = 1'b0;
					end
							
					else if (OpCode == 6'b000101) begin //LW  
							
							PCSrc1 = 1'b1;
							PCSrc0 = 1'b0;
						    RegWrite = 1'b1;
							ALUSrc0 = 1'b1; 
							ALUOp = 2'b00;
					        R_mem = 1'b1; 
					        W_mem = 1'b0;
							push = 1'b0;  
							WB = 1'b0;
							push = 1'b0;
					end
						
					else if (OpCode == 6'b000111) begin //SW  
							
							PCSrc1 = 1'b1;
							PCSrc0 = 1'b0;
						    RegWrite = 1'b0; 
							ALUSrc0 = 1'b1; 
							ALUOp = 2'b00;
					        R_mem = 1'b0; 
					        W_mem = 1'b1;
							push = 1'b0;  
					end
							
					else if (OpCode == 6'b001010) begin //BEQ  
							
							PCSrc1 = 1'b0;
							PCSrc0 = 1'b0;
						    RegWrite = 1'b0; 
							ALUSrc0 = 1'b1; 
							ALUOp = 2'b01;
					        R_mem = 1'b0; 
					        W_mem = 1'b0; 
							push = 1'b0;  
					end	
					
					else if (OpCode == 6'b001000) begin //BGT
							PCSrc1 = 1'b0;
							PCSrc0 = 1'b0;
						    RegWrite = 1'b0; 
							ALUSrc0 = 1'b1; 
							ALUOp = 2'b01;	/// We make new ALU op for Greater than 
					        R_mem = 1'b0; 
					        W_mem = 1'b0; 
							push = 1'b0;
						
					end
							
					
					else if (OpCode == 6'b001001) begin //BLT
						
							PCSrc1 = 1'b0;
							PCSrc0 = 1'b0;
						    RegWrite = 1'b0;
							ALUSrc0 = 1'b1; 
							ALUOp = 2'b01;		 // We make new ALU for less than 
					        R_mem = 1'b0; 
					        W_mem = 1'b0; 
							push = 1'b0;
						
					end	
					
					else if (OpCode == 6'b001011) begin //BNE 
						
							PCSrc1 = 1'b0;
							PCSrc0 = 1'b0;
						    RegWrite = 1'b0; 
							ALUSrc0 = 1'b1; 
							ALUOp = 2'b01;
					        R_mem = 1'b0; 
					        W_mem = 1'b0; 
							push = 1'b0;
						
						
					end
			
						
						
					/// J-Type	 
					else if (OpCode == 6'b001100) begin	 // J
							
							PCSrc1 = 1'b0;
							PCSrc0 = 1'b1;
						    RegWrite = 1'b0;
				            R_mem = 1'b0; 
					        W_mem = 1'b0;
						    push = 1'b0;
						end
						
					else if(OpCode == 6'b001101) begin	 // Call
							
							PCSrc1 = 1'b0;
							PCSrc0 = 1'b1;
						    RegWrite = 1'b0;
					        R_mem = 1'b0; 
					        W_mem = 1'b0;
							push = 1'b1;
						end	
					else if (OpCode == 6'b001110) begin	 // RET	   
						
							PCSrc1 = 1'b0;
							PCSrc0 = 1'b1;
						    RegWrite = 1'b0;
					        R_mem = 1'b0; 
					        W_mem = 1'b0;
						
						
						
						end
			
						
					else if (OpCode == 6'b001111) begin/// S-Type for stack	  push
						 
							push = 1'b1;
						
					end
					
					
					
					else if (OpCode == 6'b010000) begin		//pop  
						
							pop = 1'b1;	
							RegWrite = 1'b1;
					end
				
			
			end
		
		 //Next extend data if needed 
		else if (current_state == 1) begin
     		 immediate16 = IR[17:2];
    		 extended_immediate16 = {16'b0000000000000000, immediate16};
    	 	 immediate26 = IR[25:0];
    		 extended_immediate26 = {6'b000000, immediate26};
    		
    // Assign addresses for registers
		     AddressOfRd =  IR[25:22];
    		 AddressOfRs1 =  IR[21:18];
    		 AddressOfRs2 = IR[17:14];


			
			Registers[0] = 32'h00000008;				//0001 1000 0000 0010 1000 0000 0000 0110
			Registers[1] = 32'h00000007;
			Registers[8] = 32'h00000002;							   
			
			
			//$display (PC);
		//$display ("%b", IR);
		//$display ("\n");
			
			Rd = Registers[AddressOfRd]; 
			Rs1 = Registers[AddressOfRs1];
			Rs2 = Registers[AddressOfRs2];
			
			  
			case (ALUSrc0)
				1'b1:Y = immediate16;		 
				1'b0:Y = Rs2;
			endcase
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
	                    top = top + 1;
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
	                    top = top + 1;
	                end
	            end
	            6'b010000: begin // Pop Rd
	                current_state = 4;
	                Rd = stack[top]; // Store the top of the stack in Rd
	                top = top - 1;
	            end
	            default: begin
	                // Handle other instructions if needed
	            end
	        	endcase 	
			
			
		  end
	
		else if (current_state == 2)  begin	  

			     operandA = Rd;
			     operandB = Y;
			
			    // Perform ALU operation based on ALUOp
			    
			        case (ALUOp)
			            2'b00: outputOfALU = operandA + operandB;   // Addition
			            2'b01: outputOfALU = operandA - operandB;   // Subtraction
			            2'b10: outputOfALU = operandA & operandB;   // Bitwise AND
			            default: outputOfALU = 32'b0;               // Default case: result is 0
			        endcase

			
			    // Set flags
			    
			        zero = (outputOfALU == 32'b0);                  // Set zero flag if the result is zero
			        greater_than = (outputOfALU > 32'h0);           // Set greater than flag
			        less_than = (outputOfALU < 32'h0);              // Set less than flag
			    
			
			    // Check instructions
			   
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
						
		 end	
	
		else if (current_state == 3) begin
		
		
			address	= outputOfALU; /// Address of the memory
			data_in	= Rd; // Store Instruction 
			
			if(W_mem && !R_mem) begin 
				
				 /// Store Instruction
				 data_memory[address] = data_in; 
				 outputOfTheStore = data_memory[address]; 
				 //$display ("data_memory[%d] = %d", address, outputOfTheStore);
				 
			end
				 
			else if(!W_mem && R_mem) begin	
			
				/// Load Instruction	 
			   	 data_memory[14] = 32'h00000009;
				 data_out = data_memory[address]; 
				 
			end	
			
			///Check the current instruction is Store or not
			if (OpCode == 6'b000111) begin  
				
				current_state = 4; 
				
				///check if the current instruction is the last instruction in the function
						
					///Here is the code to choose the correct value for the PC
						
						
					///Stack Part	
			   		 empty = (top == 0);
			   		 full = (top == STACK_DEPTH);
			  	
					 // Pop operation
					 if (pop && !push && !empty) begin 
						 
				          top = top - 1;  // Move the top pointer down 	
						  outputOfStack = stack[top];
						  
						 PC = outputOfStack;
					     PC = PC + 1;
				      end
	
			 		 else PC = PC + 1;	
				  
		   	end
  		  end 
	 
	 
	 else if (current_state == 4) begin
		 
		 //$display ("Data out = %d", data_out);
		 if (WB == 1) 
			 outOfDownMux = outputOfALU;
		 else
			 outOfDownMux = data_out;	

		 /// Õrite back to the destination Register
		if (RegWrite) begin
			Rd = outOfDownMux;
			Registers[AddressOfRd] = Rd;  
		end

		///Here is the code to choose the correct value for the PC 	 
		//$display(PC);
		///Stack Part	
   		 empty = (top == 0);
   		 full = (top == STACK_DEPTH);
  	
		 // Pop operation
		 if (pop && !push && !empty) begin 
			 
	          top = top - 1;  // Move the top pointer down 	
			  outputOfStack = stack[top];
			  
			 PC = outputOfStack;
		     PC = PC + 1;
	      end

		  else PC = PC + 1;
  		  end

		
 
  
endmodule  




`timescale 1ps / 1ps
module allSystem_tb;
    // Inputs
    reg clk;
    reg reset;

    // Outputs
    wire PCSrc1;
    wire PCSrc0;
    wire RegWrite;
    wire ALUSrc0;
    wire [2:0] ALUOp;
    wire R_mem;
    wire W_mem;
    wire WB;
    wire push;
    wire pop;
    wire [31:0] Rs1;
    wire [31:0] Rs2;
    wire [31:0] Rd;
    wire [31:0] outputOfALU;
    wire [31:0] extended_immediate16;
    wire [31:0] extended_immediate26;
    wire [31:0] outputOfTheStore;

    // Instantiate the unit under test (UUT)
    allSystem uut (
        .clk(clk),
        .reset(reset),
        .PCSrc1(PCSrc1),
        .PCSrc0(PCSrc0),
        .RegWrite(RegWrite),
        .ALUSrc0(ALUSrc0),
        .ALUOp(ALUOp),
        .R_mem(R_mem),
        .W_mem(W_mem),
        .WB(WB),
        .push(push),
        .pop(pop),
        .Rs1(Rs1),
        .Rs2(Rs2),
        .Rd(Rd),
        .outputOfALU(outputOfALU),
        .extended_immediate16(extended_immediate16),
        .extended_immediate26(extended_immediate26),
        .outputOfTheStore(outputOfTheStore)
    );

initial begin current_state = 0; clk = 0; reset = 1; #1ns reset = 0; end  
	
//always @ (posedge clk) $display (current_state);
	
always #5ns clk = ~clk; 


initial	
	begin	 
	#1000;
	$monitor($realtime,,"ps %h %h %h %h %h %h %h %h %h %h %h %h %h %h %h %h %h %h %h ",clk,reset,PCSrc1,PCSrc0,RegWrite,ALUSrc0,ALUOp,R_mem,W_mem,WB,push,pop,Rs1,Rs2,Rd,outputOfALU,extended_immediate16,extended_immediate26,outputOfTheStore);
	end

initial #200ns $finish;
   
endmodule
