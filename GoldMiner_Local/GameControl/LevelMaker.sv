import GlobalsPKG::LEVEL_ELEMENTS;
import GlobalsPKG::MAX_OBJECTS;
import GlobalsPKG::GRABBABLE_OBJECT_METADATA;

module LevelMaker (
	input logic clk,
	input logic resetN,
	input logic [3:0] levelIndex,
	input logic [3:0] playerLuckStat,
	input logic generateNewLevel,
	
//	output LEVEL_ELEMENTS levelData [299:0], // flattened
	output GRABBABLE_OBJECT_METADATA elementsData [MAX_OBJECTS - 1:0],
	output logic [19:0] levelValue,
	output logic finishedGenerating
);

logic [299:0] mask;

logic reseedRandom;
logic [15:0] randomVal;
logic [15:0] randomValLatch;
logic latchRandom = 0;

logic [10:0] maxLevelElementCount;

logic [10:0] currentIndex, randCol, randRow;
assign randCol = randomVal % 20;
assign randRow = randomVal % 12 + 3;
assign currentIndex = randRow * 20 + randCol;

logic [5:0] amountOfPlacedElements;
logic [19:0] overallLevelValue;

logic [7:0] rockSpawnWeight, val1SpawnWeight, val2SpawnWeight, val3SpawnWeight;
logic [9:0] truncatedRand;
assign truncatedRand = randomVal[9:0];

Random random (
	.clk(clk),
	.resetN(resetN),
	.reseed(reseedRandom),
	.storeValue(latchRandom),
	
	.random(randomVal),
	.randomLatch(randomValLatch)
);
//


always_comb begin
	// As level increases, rock threshold grows. As luck increases, it shrinks.
	rockSpawnWeight = 8'd100 + (levelIndex * 10) - (playerLuckStat * 5);
	val1SpawnWeight = rockSpawnWeight + 8'd60 + (playerLuckStat * 2);
	val2SpawnWeight = val1SpawnWeight + 8'd30 + (playerLuckStat * 5);
	val3SpawnWeight = val2SpawnWeight + 8'd05 + (playerLuckStat * 8);
end


always_ff @(posedge clk or negedge resetN) begin
	if (!resetN) begin
		reseedRandom <= 0;
		finishedGenerating <= 0;
		
	end else if (generateNewLevel) begin
		mask <= 300'b0;
		overallLevelValue <= 0;
		amountOfPlacedElements <= 0;
		finishedGenerating <= 0;
		maxLevelElementCount <= 10 + randomVal % 10 + levelIndex;
		reseedRandom <= 0;
		
		if (levelIndex == 0) begin
			reseedRandom <= 1;
		end
		
	end else if (amountOfPlacedElements >= maxLevelElementCount) begin 
		finishedGenerating <= 1;
	end else begin
		reseedRandom <= 0;
		
		if (truncatedRand < rockSpawnWeight)
			elementsData[amountOfPlacedElements] <= '{elementType: GlobalsPKG::ROCK_1, index: currentIndex};
		else if (truncatedRand < val1SpawnWeight)
			elementsData[amountOfPlacedElements] <= '{elementType: GlobalsPKG::VALUABLE_1, index: currentIndex};
		else if (truncatedRand < val2SpawnWeight)
			elementsData[amountOfPlacedElements] <= '{elementType: GlobalsPKG::VALUABLE_2, index: currentIndex};
		else if (truncatedRand < val3SpawnWeight)
			elementsData[amountOfPlacedElements] <= '{elementType: GlobalsPKG::VALUABLE_3, index: currentIndex};
		
		if (truncatedRand <= val3SpawnWeight) begin
			amountOfPlacedElements <= amountOfPlacedElements + 1;
			mask[currentIndex] <= 1;
		end

	end
end

endmodule
