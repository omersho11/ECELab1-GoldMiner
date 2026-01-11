
module LevelController (	
	input logic clk,
	input logic resetN,
	input logic debugAlwaysWin,
	input logic [10:0] pixelX,
	input logic [10:0] pixelY,
	input logic enable,
	input logic oneSecPulse,
	input logic startOfFrame,
	 
	input logic [3:0] playerLuckStat,
	input logic [19:0] scoreMultiplier,
	input logic debugSkipLevel,
	input logic startingNewGame,
	input logic [3:0] currentLevel,
	input logic [10:0] hookPosX,
	input logic [10:0] hookPosY,
	input logic hookDRLatch,
	input logic hookReturned,


	output logic levelDR,
	output logic [7:0] RGBout,
	output logic stagePassed,
	output logic stageEnded,
	output logic lastLevelEnded,
	output logic [19:0] scoreIncrease,
	output logic [19:0] moneyIncrease,
	output logic [3:0] levelIncrease,
	output logic hookCollided,
	output logic [10:0] timeInSeconds
);

import GlobalsPKG::*;


logic [10:0] timer = MIN_LEVEL_TIME;
logic enable_d;
logic stageEnded_d;

assign timeInSeconds = timer; // easier to read imo
assign moneyIncrease = scoreIncrease;

// level creation params
logic generateNewLevel;
logic [19:0] levelValue;
logic finishedGenerating;
logic currentLevelGenerated;

logic anyObjectsRemaining;

assign startingNewLevel = (enable && !enable_d);
assign levelIncrease = {3'b000, (enable && stageEnded && !stageEnded_d)};
									
// data for GrabbableObjects			
GRABBABLE_OBJECT_METADATA activeLevelData [MAX_OBJECTS - 1:0];
logic [MAX_OBJECTS-1:0] drBus, drBusLatch;
logic [MAX_OBJECTS-1:0] [10:0] valueBus;
logic [MAX_OBJECTS-1:0] destroyedBus;
logic [(MAX_OBJECTS*8)-1:0] RGBBus;
logic [MAX_OBJECTS-1:0] insideBus,valuePulseBus;
logic [4:0] busX [MAX_OBJECTS];
logic [4:0] busY [MAX_OBJECTS];
logic [3:0] busTex [MAX_OBJECTS];

// data about "current" GrabbableObject
logic [3:0] activeTex;
logic [4:0] activeX, activeY;
logic anyInside;
assign drGrabbableObject = anyInside && (romColor != 8'hFF);


// the sum of the values of all objects that are being grabbed this frame
logic [10:0] totalValuePerCycle;

// data for ROM	
logic [7:0] romColor;


// instantiation of GrabbableObjects
genvar i;
generate
    for(i=0; i < MAX_OBJECTS; i=i+1) begin : GrabbableObject_GEN    
        NewGrabbableObject obj_inst (
            .clk(clk), .resetN(resetN), .manualReset(startingNewLevel),
            .idleX(activeLevelData[i].col * 32),
            .idleY((activeLevelData[i].row * 32)),
            .objectType(activeLevelData[i].elementType),
            .pixelX(pixelX), .pixelY(pixelY),
            .hookX(hookPosX), .hookY(hookPosY),
            .isHooked((drBusLatch[i] && hookDRLatch)|| debugSkipLevel),
            .hookReturned(hookReturned || debugSkipLevel),
				
				//outputs
            .value(valueBus[i]),
            .destroyed(destroyedBus[i]),
            // Address outputs to the shared ROM
            .texToRead(busTex[i]),
            .addrX(busX[i]), .addrY(busY[i]),
            .isInside(insideBus[i]),
				.valuePulse(valuePulseBus[i])
        );
    end
endgenerate




// Single ROM Instance
SpriteRom sharedROM (
    .clk(clk),
    .objectType(activeTex),
    .offsetX(activeX),
    .offsetY(activeY),
    .rgb(romColor)
);

// LEVELMAKER INSTANTIATION
LevelMaker levelMaker (
	.clk(clk),
	.resetN(resetN),
	.levelIndex(currentLevel),
	.playerLuckStat(playerLuckStat),
	.generateNewLevel(generateNewLevel),
	
	.elementsData(activeLevelData),
	.levelValue(levelValue),
	.finishedGeneratingPulse(finishedGenerating)
);






// --- LOGIC ---

// caches the data of the "active" GrabbableObject (active == colliding with the hook)
always_comb begin
    activeTex = 0; activeX = 0; activeY = 0; anyInside = 0;
    for(int j=0; j<MAX_OBJECTS; j++) begin
        if(insideBus[j]) begin
            activeTex = activeLevelData[j].elementType;
            activeX = busX[j];
            activeY = busY[j];
            anyInside = 1;
        end
    end
end


// calculates the total value of grabbed objects
always_comb begin
    totalValuePerCycle = 0;
    for (int k = 0; k < MAX_OBJECTS; k++) begin
        if (valuePulseBus[k]) begin // Check the new pulse signal
            totalValuePerCycle = totalValuePerCycle + valueBus[k];
        end
    end
end


// determines if the level needs to draw to screen at current pixel
always_comb begin
	// Default values (Background/Transparent)
	levelDR = 0;
	RGBout  = 8'hFF;
	
	if(enable && currentLevelGenerated) begin
		if (anyInside) begin
			if (romColor != 8'hFF) begin
				levelDR = 1;
				RGBout  = romColor;
			end
		end
	end
end
//


always_ff @(posedge clk or negedge resetN) begin
	if (!resetN) begin
		generateNewLevel <= 0;
		currentLevelGenerated <= 0;
	end else begin
		generateNewLevel <= 0;
		
		if (startingNewLevel) begin
			generateNewLevel <= 1;
			currentLevelGenerated <= 0;
			
		end else if (finishedGenerating) begin
			currentLevelGenerated <= 1;
		end
	end
end

always_ff @(posedge clk or negedge resetN) begin
    if (!resetN) begin
        hookCollided <= 1'b0;
		  drBusLatch <= 0;
		  anyObjectsRemaining <= 0;
    end else begin
        if (startOfFrame) begin
				anyObjectsRemaining <= 0;
            hookCollided <= 1'b0;
				drBusLatch <= 0;
        end else if (hookDRLatch && (|insideBus)) begin
            hookCollided <= 1'b1;
				drBusLatch <= insideBus;
        end
		  else begin 
				anyObjectsRemaining <= anyObjectsRemaining || (|insideBus);
		  end
		  
    end
end


// used to:
// - detect rising edge of stageEnded
// - detect rising edge of enabled
// - calculate scoreIncrease
// - makes sure level was actually created (and not using junk startup data)
always_ff @(posedge clk or negedge resetN) begin
	if (!resetN) begin
		stageEnded_d <= 0;
		enable_d <= 0;
		scoreIncrease <= 0;
	end else begin
		stageEnded_d <= stageEnded;
		enable_d <= enable;
		scoreIncrease <= scoreMultiplier*totalValuePerCycle;  // scoreMultiplier * totalValuePerCycle
	end
end


// main logic
always_ff @(posedge clk or negedge resetN) begin
	if (!resetN) begin
		stageEnded   <= 0;
		stagePassed  <= 0;
		timer        <= MIN_LEVEL_TIME + currentLevel * EXTRA_TIME_PER_LEVEL;
		lastLevelEnded <= 0;
	end else begin
		stageEnded <= 0; // default pulse behavior

		// IMPORTANT: don't evaluate win/time on the same tick you're starting a new level
		if (startingNewLevel) begin
			stagePassed <= 0;
			timer <= MIN_LEVEL_TIME + currentLevel * EXTRA_TIME_PER_LEVEL;
		end
		else if (enable && currentLevelGenerated) begin
			stagePassed <= debugAlwaysWin;

			if ((&destroyedBus) == 1'b1) begin
				stageEnded  <= 1;
				stagePassed <= 1;
			end

			if (oneSecPulse) begin
				timer <= timer - 1;
				if (timer == 1) begin
					stageEnded <= 1;
				end
			end
		end
	end
end





endmodule

