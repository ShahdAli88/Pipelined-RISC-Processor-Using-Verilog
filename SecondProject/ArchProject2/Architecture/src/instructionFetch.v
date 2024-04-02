module instructionFetch(
    input wire [31:0] PC,
    output reg PCSrc1,
    output reg PCSrc0,
    output reg RegWrite,
    output reg ALUSrc0,
    output reg [1:0] ALUOp,
    output reg R_mem,
    output reg W_mem,
    output reg WB,
    output reg push,
    output reg pop
);

reg [31:0] memory[0:15];
reg [31:0] IR;	
reg [5:0] OpCode;

always @(PC) begin
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

endmodule
	
	
	
	
	