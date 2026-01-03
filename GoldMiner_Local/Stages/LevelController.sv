import GlobalsPKG::LEVEL_ELEMENTS;
import GlobalsPKG::MAX_OBJECTS;
import GlobalsPKG::GRABBABLE_OBJECT_METADATA;


module LevelController (	
    input logic clk,
    input logic resetN,
    input logic cycleLevel,
    input logic [10:0] pixelX,
    input logic [10:0] pixelY,
    input logic enable,
	 input logic oneSecPulse,
	 input logic startOfFrame,
	 input logic sendHook,
	 
	 input logic [8:0] extentionSpeed,
	 input logic [8:0] rotationSpeed,
	 
	 input logic [19:0] score,
	 input logic [19:0] money,
	 input logic [3:0] playerLuckStat,
	 
    output logic levelDR,
    output logic [7:0] RGBout,
    output logic stagePassed,
	 output logic stageEnded,
    output logic lastLevelEnded,
	 output logic [19:0] scoreIncrease
);

localparam MAX_LEVEL = 1;
localparam [8:0] MAX_TIME = 20;

logic [8:0] timer = 0;
int currentLevel;
logic enable_d; // Delayed version of enable to detect the edge

// level creation params
logic generateNewLevel;
logic [19:0] levelValue;
logic finishedGenerating;
logic currentLevelGenerated;

// hook params
localparam [10:0] HOOK_ORIGIN_X = 320;
localparam [10:0] HOOK_ORIGIN_Y = 96;
localparam [4:0] LINE_THICKNESS = 1;
localparam [7:0] LINE_COLOR = 8'hFE;
logic [10:0] hookPosX, hookPosY;
wire hookDR;
logic hookDRLatch;
logic [7:0] hookRGB;
wire hookReturned;

wire collisionOccurred;
logic remainingObjects;


// timeDisplay params
localparam [10:0] TIMEDISPLAY_WIDTH_X = 80; 	//16 * 5
localparam [10:0] TIMEDISPLAY_HEIGHT_Y = 32; //32 * 1
localparam [10:0] TIMEDISPLAY_POS_LEFT = 32;
localparam [10:0] TIMEDISPLAY_POS_TOP = 32;
logic [10:0] timeDisplayOffsetX;
logic [10:0] timeDisplayOffsetY;
wire timeDisplayInsideRectangle;
wire timeDisplayDR;
logic [7:0] timeDisplayRGB;


assign startingNewLevel = (enable && !enable_d);


// location and type of objects on screen
// Using a 1D array for memory, indexed as [level * offset + object_index]

									//(* ramstyle = "M9K" *) logic [8:0] levelData [0:(OBJECTS_COUNT*3*MAX_LEVEL)-1];
									//
									//initial begin
									//    $readmemh("Stages/level_data.txt", levelData);
									//end
									//logic [8:0] activeLevelData [0:(OBJECTS_COUNT*3-1)];
									
									
GRABBABLE_OBJECT_METADATA activeLevelData [MAX_OBJECTS - 1:0];
logic [MAX_OBJECTS-1:0] drBus;
logic [MAX_OBJECTS-1:0] drBusLatch;

logic [MAX_OBJECTS-1:0] [10:0] valueBus;
logic [MAX_OBJECTS-1:0] destroyedBus;
logic [(MAX_OBJECTS*8)-1:0] RGBBus;



// --- 2. OBJECT INSTANTIATION ---
Hook #(
		.OFFSET_X(HOOK_ORIGIN_X),
		.OFFSET_Y(HOOK_ORIGIN_Y)
) hook (
    .clk(clk),
    .resetN(resetN),
    .enable(enable),
	 .startOfFrame(startOfFrame),
	 .sendHook(sendHook),
	 .forceReturn(collisionOccurred),
	 
	 .extentionSpeed(extentionSpeed),
	 .rotationSpeed(rotationSpeed),
	 
	 .x(hookPosX),
	 .y(hookPosY),
	 .hookReturnedPulse(hookReturned)

);

DrawLine lineDrawer (
	.pixelX(pixelX),
	.pixelY(pixelY),
	.x1(HOOK_ORIGIN_X),
	.y1(HOOK_ORIGIN_Y),
	.x2(hookPosX),
	.y2(hookPosY),
	.width(LINE_THICKNESS),
	.lineColor(LINE_COLOR),
	
	.lineDR(hookDR),
	.lineRGB(hookRGB),
);



genvar i;
generate 
	for(i=0; i < MAX_OBJECTS; i=i+1) begin : GrabbableObject_GEN
		logic [4:0] row, col;
		assign col = (activeLevelData[i].index % 15);
		assign row = (activeLevelData[i].index % 20);
		
	
		GrabbableObject obj_inst (
			.clk(clk),
			.resetN(resetN),
			.manualReset(startingNewLevel),
			.idleX(row * 32),
			.idleY(96 + col * 32),
			.objectType(activeLevelData[i].elementType),
			.pixelX(pixelX),
			.pixelY(pixelY),
			.hookX(hookPosX),
			.hookY(hookPosY),
			.isHooked(drBusLatch[i] && hookDRLatch),
			.hookReturned(hookReturned),
			
			.value(valueBus[i]),
			.destroyed(destroyedBus[i]),
			.dr(drBus[i]),
			.RGBout(RGBBus[i*8 +: 8])
		);
	end
endgenerate


// TIMEDISPLAY INSTANTIATION
square_object #(
	.OBJECT_WIDTH_X(TIMEDISPLAY_WIDTH_X),
	.OBJECT_HEIGHT_Y(TIMEDISPLAY_HEIGHT_Y)
) timeDisplaySquareObject (
	.clk(clk),
   .resetN(resetN),
	.pixelX(pixelX),
	.pixelY(pixelY),
	.topLeftX(TIMEDISPLAY_POS_LEFT),
	.topLeftY(TIMEDISPLAY_POS_TOP),
	
	.offsetX(timeDisplayOffsetX),
	.offsetY(timeDisplayOffsetY),
	.drawingRequest(timeDisplayInsideRectangle),
	.RGBout(8'b0)
);

TimeDisplay #(
	.color(8'b11100000)
) timeDisplay (
	.clk(clk),
   .resetN(resetN),
   .enable(enable),
	.offsetX(timeDisplayOffsetX),
	.offsetY(timeDisplayOffsetY),
	.InsideRectangle(timeDisplayInsideRectangle),
	.timeInSeconds(timer),
	
	.drawingRequest(timeDisplayDR),
	.RGBout(timeDisplayRGB)
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
	.finishedGenerating(finishedGenerating)
);

// --- 3. OUTPUT MULTIPLEXING ---

// EDGE DETECTION & MEMORY LOADING 
// We use a synchronous clock and check for the rising edge of 'enable'
always_ff @(posedge clk or negedge resetN) begin
	if (!resetN) begin
		enable_d <= 1'b0;
		generateNewLevel <= 0;
		currentLevelGenerated <= 0;
	end else begin
		enable_d <= enable; // Store previous state
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
        collisionOccurred <= 1'b0;
		  drBusLatch <= 0;
		  hookDRLatch <= 0;
		  remainingObjects <= 0;
    end else begin
        if (startOfFrame) begin
				remainingObjects <= 0;
            collisionOccurred <= 1'b0; // Reset at the top of every frame
				drBusLatch <= 0;
				hookDRLatch<= 0;
        end else if (hookDR && (|drBus)) begin
            collisionOccurred <= 1'b1; // Latch the collision if signals overlap
				drBusLatch <= drBus;
				hookDRLatch <= hookDR;
        end
		  else begin 
				remainingObjects <= remainingObjects || (|drBus);
		  end
		  
    end
end


always_ff @(posedge clk or negedge resetN) begin
	if (!resetN) begin  
		currentLevel <= 0;
		lastLevelEnded <= 0;
		
		levelDR <= 0;
		RGBout <= 8'h00;
		
		stageEnded <= 0;
		stagePassed <= 0;
		
		timer <= MAX_TIME;
		scoreIncrease <= 0;
		
	end
   else if(enable && currentLevelGenerated) begin
      stageEnded <= 0;
		stagePassed <= 0;
      levelDR <= 0;
      RGBout <= 8'hFF;
		scoreIncrease <= 0;
		// MUX all drawing requests:
      for(int j = 0; j < MAX_OBJECTS; j = j + 1) begin
          if(drBus[j]) begin
              levelDR <= 1;
              RGBout <= RGBBus[j*8 +: 8];
          end
			 if (valueBus[j] != 0) begin
				scoreIncrease <= valueBus[j];
			 end;
      end
		
		if (hookDR) begin
			levelDR <= 1;
			RGBout <= hookRGB;
		end
		
		if (timeDisplayDR) begin
			levelDR <= 1;
			RGBout <= timeDisplayRGB;
		end
		
		if (&destroyedBus) begin 
			stageEnded <= 1;
			stagePassed <= 1;
			
		end
		// Timer managment:
		if (startingNewLevel) begin
			timer <= MAX_TIME;
			scoreIncrease <= 0;
		end
		else if (oneSecPulse) begin	
			timer <= timer - 1;
			if (timer == 0) stageEnded <= 1;
		end		  
		  
    end	
	 else begin
		stageEnded <= 0;
	 end
end

endmodule