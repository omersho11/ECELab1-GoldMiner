module LevelMaker (
	input logic clk,
	input logic resetN,
	input logic [3:0] levelIndex,
	input logic [19:0] playerLuckStat,
	input logic generateNewLevel,
	
//	output LEVEL_ELEMENTS levelData [299:0], // flattened
	output GRABBABLE_OBJECT_METADATA elementsData [MAX_OBJECTS - 1:0],
	output logic [19:0] levelValue,
	output logic finishedGeneratingPulse
);

import GlobalsPKG::*;

logic finishedGenerating;
logic finishedGenerating_d;
assign finishedGeneratingPulse = (finishedGenerating && (!finishedGenerating_d));

logic [299:0] mask;

logic [15:0] randomVal;
logic [15:0] randomValLatch;
logic latchRandom = 0;

logic [10:0] maxLevelElementCount;

logic [10:0] currentIndex, randCol, randRow;
assign randCol = randomVal[9:0] % 20;
assign randRow = randomVal[12:10] + 7; // randomVal % 8 + 7
assign currentIndex = (randRow << 4) + (randRow << 2) + randCol; // 20 * randRow + randCol

logic [5:0] amountOfPlacedElements;
logic [19:0] overallLevelValue;

logic [7:0] rockSpawnWeight, val1SpawnWeight, val2SpawnWeight, val3SpawnWeight, fillerSpawnWeight;
logic [9:0] truncatedRand;
assign truncatedRand = randomVal[9:0];

Random random (
	.clk(clk),
	.resetN(resetN),
	.reseed(0),
	.storeValue(latchRandom),
	
	.random(randomVal),
	.randomLatch(randomValLatch)
);
//


always_comb begin
	// As level increases, rock threshold grows. As luck increases, it shrinks.
	//fillerSpawnWeight = ((60 > levelIndex * 5) ? 50 - levelIndex * 5 : 10);
	rockSpawnWeight = 100 + (levelIndex * 10) - (playerLuckStat * 5);
	val1SpawnWeight = rockSpawnWeight + 60 + (playerLuckStat * 2);
	val2SpawnWeight = val1SpawnWeight + 60 + (playerLuckStat * 5);
	val3SpawnWeight = val2SpawnWeight + 15 + (playerLuckStat * 8);
end


always_ff @(posedge clk or negedge resetN) begin
	if (!resetN) begin
		finishedGenerating <= 0;
		finishedGenerating_d <= 0;
		
	end else begin
		finishedGenerating_d <= finishedGenerating;
		
		if (generateNewLevel) begin
			mask <= 300'b0;
			overallLevelValue <= 0;
			amountOfPlacedElements <= 0;
			finishedGenerating <= 0;
			finishedGenerating_d <= 0;
			maxLevelElementCount <= 5 + randomVal[2:0] + levelIndex;
			
		end else if (amountOfPlacedElements >= maxLevelElementCount) begin 
			// Iterate through the entire constant range
			for (int i = 0; i < MAX_OBJECTS; i = i + 1) begin
				 // Use an 'if' to create the conditional logic for each slot
				 if (i >= maxLevelElementCount) begin
					  elementsData[i] <= '{elementType: FILLER, row: 0, col: 0};
				 end
			end
			finishedGenerating <= 1;
		end else if (mask[currentIndex] == 0) begin
			
			
			if (truncatedRand < rockSpawnWeight)
				elementsData[amountOfPlacedElements] <= '{elementType: ROCK_1, row: randRow, col: randCol};
			else if (truncatedRand < val1SpawnWeight)
				elementsData[amountOfPlacedElements] <= '{elementType: VALUABLE_1, row: randRow, col: randCol};
			else if (truncatedRand < val2SpawnWeight)
				elementsData[amountOfPlacedElements] <= '{elementType: VALUABLE_2, row: randRow, col: randCol};
			else if (truncatedRand < val3SpawnWeight)
				elementsData[amountOfPlacedElements] <= '{elementType: VALUABLE_3, row: randRow, col: randCol};
			
			if (truncatedRand <= val3SpawnWeight) begin
				amountOfPlacedElements <= amountOfPlacedElements + 1;
				mask[currentIndex] <= 1;
			end
		end
	end
end

endmodule
