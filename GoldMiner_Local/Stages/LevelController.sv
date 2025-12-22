module LevelController (	
    input logic clk,
    input logic resetN,
    input logic cycleLevel,
    input logic [10:0] pixelX,
    input logic [10:0] pixelY,
    input logic enable,
	 input logic oneSecPulse,
	 input logic startOfFrame,
	 
    output logic levelDR,
    output logic [7:0] RGBout,
    output logic stageFailed,
	 output logic stagePassed,
    output logic lastLevelEnded
);

localparam MAX_LEVEL = 1;
localparam OBJECTS_COUNT = 20;
localparam MAX_TIME = 60;

int score;
int money;
int timer;
int currentLevel;
logic enable_d; // Delayed version of enable to detect the edge


localparam [10:0] HOOK_ORIGIN_X = 320;
localparam [10:0] HOOK_ORIGIN_Y = 96;
localparam [4:0] LINE_THICKNESS = 1;
localparam [7:0] LINE_COLOR = 8'hFE;
logic [10:0] hookPosX, hookPosY;
wire hookDR;
logic [7:0] hookRGB;


// location and type of objects on screen
// Using a 1D array for memory, indexed as [level * offset + object_index]
(* ramstyle = "M9K" *) logic [8:0] levelData [0:(OBJECTS_COUNT*3*MAX_LEVEL)-1];

initial begin
    $readmemh("Stages/level_data.txt", levelData);
end

logic [8:0] activeLevelData [0:(OBJECTS_COUNT*3-1)];
logic [OBJECTS_COUNT-1:0] drBus;
logic [(OBJECTS_COUNT*8)-1:0] RGBBus;

// --- 1. EDGE DETECTION & MEMORY LOADING ---
// We use a synchronous clock and check for the rising edge of 'enable'
always_ff @(posedge clk or negedge resetN) begin
    if (!resetN) begin
        enable_d <= 1'b0;
    end else begin
        enable_d <= enable; // Store previous state
        
        // Detect rising edge: enable is high now, but was low last cycle
        if (enable && !enable_d) begin
				timer <= MAX_TIME;
            for (int k = 0; k < OBJECTS_COUNT*3; k++) begin
                activeLevelData[k] <= levelData[(currentLevel * OBJECTS_COUNT * 3) + k];
            end
        end
    end
end

// --- 2. OBJECT INSTANTIATION ---
Hook #(
		.OFFSET_X(HOOK_ORIGIN_X),
		.OFFSET_Y(HOOK_ORIGIN_Y)
) hook (
    .clk(clk),
    .resetN(resetN),
    .enable(enable),
	 .startOfFrame(startOfFrame),
	 
	 .x(hookPosX),
	 .y(hookPosY)
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
	.lineRGB(hookRGB)
);



genvar i;
generate 
	for(i=0; i<OBJECTS_COUNT; i=i+1) begin: GrabbableObject_GEN
		GrabbableObject obj_inst (
			.topLeftX(activeLevelData[3*i]),
			.topLeftY(activeLevelData[3*i + 1]),
			.objectType(activeLevelData[3*i + 2]),
			.pixelX(pixelX),
			.pixelY(pixelY),

			.dr(drBus[i]),
			.RGBout(RGBBus[i*8 +: 8]) // Corrected indexing syntax
		);
	end
endgenerate

// --- 3. OUTPUT MULTIPLEXING ---
always_ff @(posedge clk or negedge resetN) begin
	if (!resetN) begin  
		currentLevel <= 0;
		lastLevelEnded <= 0;
		levelDR <= 0;
		RGBout <= 8'h00;
	end 
   else if(enable) begin
      // Combinational-like defaults within the FF
      levelDR <= 0;
      RGBout <= 8'hFF;
		
      for(int j = 0; j < OBJECTS_COUNT; j = j + 1) begin
          if(drBus[j]) begin
              levelDR <= 1;
              RGBout <= RGBBus[j*8 +: 8]; // Corrected indexing syntax
          end
      end
		
		if (hookDR) begin
			levelDR <= 1;
			RGBout <= hookRGB;
		end
		  
		  
		  
//		timer <= timer - 1;
//		if (timer <= 0) stageEnded = 1;
		  
		  
    end	
end

endmodule