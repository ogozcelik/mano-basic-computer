`timescale 1ns / 1ps

module BasicComputer(IR,TR,DR,AC,PC,AR,clk,timeCount);

input clk;
output reg [15:0] IR;
output reg [15:0] TR;
output reg [15:0] DR;
output reg [15:0] AC;
output reg [11:0] PC;
output reg [11:0] AR;
//reg [7:0] OUTR; //I comment these two
//reg [7:0] INPR; //since they are not included in the project
reg [15:0] MEM [255:0]; //256 words, each 16bit
reg I;
reg E;
reg S; //start-stop ff
output reg [3:0] timeCount; //defined as output to observe it
 
//initialize memory with random words
initial
begin
timeCount <= 0;
IR <= 0;
TR <= 0;
DR <= 0;
AC <= 0;
PC <= 0;
AR <=0;
I<=0;
E<=0;
S <= 1; //set start flip-flop
$readmemh("D:/Programs/quartus/codes_verilog/BasicComputer/mem_data.txt", MEM);
end

always @(posedge clk)
begin 
	//fetch cycle start
	if (timeCount == 0) begin	
		AR <= PC;
		timeCount <= timeCount + 1; end
	
	else if (timeCount == 1) begin
		IR <= MEM[AR[7:0]]; 
		PC <= PC + 1;		
		timeCount <= timeCount + 1; end
	
	else if (timeCount == 2) begin
		AR <= IR[11:0];
		I <= IR[15];
		timeCount <= timeCount +1; end
	//fetch cycle end
	
	else begin
		if (IR[14:12] == 3'b111) begin
			//if(I == 1) // (I/O)
				// we dont need to write this part
				// as referred in hw.
			
			if(I == 0) begin// Register-reference (end is at 105)
				
				if(AR[11] == 1) begin//CLA
					AC <= 0;
					timeCount <= 0; end
					
				else if(AR[10] == 1) begin//CLE
					E <= 0;
					timeCount <= 0; end
					
				else if(AR[9] == 1) begin //CMA
					AC <= ~AC;
					timeCount <= 0; end
					
				else if(AR[8] == 1) begin//CME
					E <= ~E;
					timeCount <= 0; end
					
				else if(AR[7] == 1) begin//CIR
					AC <= (AC >> 1); 
					AC[15] <= E;
					E <= AC[0];
					timeCount <= 0; end
					
				else if(AR[6] == 1) begin//CIL
					AC <= (AC << 1);
					AC[0] <= E;
					E <= AC[15];
					timeCount <= 0; end
					
				else if(AR[5] == 1) begin //INC
					AC <= AC + 1;
					timeCount <= 0; end
					
				else if(AR[4] == 1) begin //SPA
					if ( AC [15] == 0)
						PC <= PC +1;
					timeCount <= 0;
					end
				else if(AR[3] == 1) begin//SNA
					if ( AC [15] == 1)
						PC <= PC +1;
					timeCount <= 0;
					end
				else if(AR[2] == 1) begin //SZA
					if ( AC == 0)
						PC <= PC +1;
					timeCount <= 0;
					end
				else if(AR[1] == 1) begin //SZE
					if ( E == 0)
						PC <= PC +1;
					timeCount <= 0;
					end
				else begin// HLT
					S <= 0;
					timeCount <= 0; end
			end
		end		
		else begin // Memory reference instructions (end is at 223)
			if(I == 1) begin// indirect
				if (timeCount == 3) begin
					AR <= MEM[AR[7:0]]; 
					timeCount <= timeCount + 1; end
				else begin
					if(IR[14:12] == 3'b000) begin //AND
						if(timeCount == 4) begin
							DR <= MEM[AR[7:0]]; 
							timeCount <= timeCount + 1; end
						else begin
							AC <= (AC & DR);
							timeCount <= 0; end
					end
					else if(IR[14:12] == 3'b001) begin //ADD 
						if(timeCount == 4) begin
							DR <= MEM[AR[7:0]]; 
							timeCount <= timeCount + 1; end
						else begin
							{E,AC} <= AC + DR;
							timeCount <= 0; end
					end
					else if(IR[14:12] == 3'b010) begin //LDA
						if(timeCount == 4) begin
							DR <= MEM[AR[7:0]]; 
							timeCount <= timeCount + 1; end
						else begin
							AC <= DR;
							timeCount <= 0; end
					end		
					else if(IR[14:12] == 3'b011) begin//STA
						MEM[AR[7:0]] <= AC ; 
						timeCount <= 0;
					end
					else if(IR[14:12] == 3'b100) begin //BUN
						PC <= AR;
						timeCount <= 0;
					end
					else if(IR[14:12] == 3'b101) begin //BSA
						if (timeCount == 4) begin
							MEM[AR[7:0]] <= PC; 
							AR <= AR + 1; end
						else begin
							PC <= AR;
							timeCount <= 0; end
					end		
					else if(IR[14:12] == 3'b110) begin //ISZ
						if (timeCount == 4) begin
							DR <= MEM[AR[7:0]]; 
							timeCount <= timeCount +1; end
						else if(timeCount ==5) begin
							DR <= DR +1;
							timeCount <= timeCount +1; end
						else begin
							MEM[AR[7:0]] <= DR; 
								if(DR == 0)
									PC <= PC +1;
							timeCount <= timeCount +1; end
				   end
			   end
			end
			if(I == 0) begin // direct
				if (timeCount == 3)
					timeCount <= timeCount + 1; //do nothing
				else begin
					if(IR[14:12] == 3'b000) begin //AND
						if(timeCount == 4) begin
							DR <= MEM[AR[7:0]]; 
							timeCount <= timeCount + 1; end
						else begin
							AC <= (AC & DR);
							timeCount <= 0; end
					end
					else if(IR[14:12] == 3'b001) begin//ADD
						if(timeCount == 4) begin
							DR <= MEM[AR[7:0]];
							timeCount <= timeCount + 1; end
						else begin
							{E,AC} <= AC + DR;
							timeCount <= 0; end
					end		
					else if(IR[14:12] == 3'b010) begin//LDA
						if(timeCount == 4) begin
							DR <= MEM[AR[7:0]];
							timeCount <= timeCount + 1; end
						else begin
							AC <= DR;
							timeCount <= 0; end
					end		
					else if(IR[14:12] == 3'b011) begin //STA
						MEM[AR[7:0]] <= AC ; 
						timeCount <= 0;
					end
					else if(IR[14:12] == 3'b100) begin //BUN
						PC <= AR;
						timeCount <= 0;
					end
					else if(IR[14:12] == 3'b101) begin //BSA
						if (timeCount == 4) begin
							MEM[AR[7:0]] <= PC; 
							AR <= AR + 1; end
						else begin
							PC <= AR;
							timeCount <= 0; end
					end		
					else if(IR[14:12] == 3'b110) begin //ISZ
						if (timeCount == 4) begin
							DR <= MEM[AR[7:0]]; 
							timeCount <= timeCount +1; end
						else if(timeCount ==5) begin
							DR <= DR +1;
							timeCount <= timeCount +1; end
						else  begin
							MEM[AR[7:0]] <= DR;
								if(DR == 0)
									PC <= PC +1;
							timeCount <= timeCount +1; end
					end
				end
			end
		end 		
	end 
end
endmodule		
		
		
			