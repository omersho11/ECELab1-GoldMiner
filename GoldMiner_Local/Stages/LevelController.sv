module	LevelController	(	
			input	logic	clk,
			input	logic	resetN,
			input	logic	cycleLevel,
			input logic enable,
			output logic drLevel,
			output logic stageEnded,
			output logic lastLevelEnded
									
);


localparam MAX_LEVEL = 3; // when edited change currentLevel and levelData indexes accordingly
logic [1:0] currentLevel;
logic [1:0][15:0][19:0] levelData; // change dimensions and fill level data

always_ff@(posedge clk or negedge resetN)
begin
	if(!resetN)
	begin  
			currentLevel = 0;
			lastLevelEnded = 0;
	end 
	else begin 	
		if(cycleLevel) begin
			if(currentLevel == MAX_LEVEL)
				lastLevelEnded = 1;
			else
				currentLevel = currentLevel + 1;
		end
	end 
end



endmodule
