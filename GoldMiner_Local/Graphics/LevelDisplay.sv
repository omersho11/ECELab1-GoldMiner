module LevelDisplay (
    input  logic clk,
    input  logic resetN,
    input  logic enable,
    input  logic startOfFrame, 
    input  logic [10:0] pixelX,
    input  logic [10:0] pixelY,
    
    // --- Inputs ---
    input  logic isCasting,    
    
    // --- Video Output ---
    output logic levelDisplayDR,
    output logic [7:0] levelDisplayRGB
);
import GlobalsPKG::*;

// --- Configuration ---
localparam WIZ_X = 11'd297; 
localparam WIZ_Y = 11'd26;
localparam SPARK_X = 11'd299; 
localparam SPARK_Y = 11'd24; 
localparam FRAMES_PER_SWITCH = 15; // 0.5s at 30Hz

// --- Animation Timer ---
logic [4:0] timer;
logic animToggle;

always_ff @(posedge clk or negedge resetN) begin
	if (!resetN) begin
		timer <= 0;
		animToggle <= 0;
	end else if (startOfFrame) begin
		if (timer >= FRAMES_PER_SWITCH) begin
			 timer <= 0;
			 animToggle <= ~animToggle; 
		end else begin
			 timer <= timer + 1;
		end
	end
end

// --- Frame Calculation ---
logic [2:0] currentFrame;

always_comb begin
	if (isCasting) begin
		// CASTING: Offset by 2 (Frames 2 and 3)
		currentFrame = {2'b0, animToggle} + 3'd2; 
	end else begin
		// IDLE: No Offset (Frames 0 and 1)
		currentFrame = {2'b0, animToggle}; 
	end
end

    // --- Instantiate Wizard ---
logic wizDR, sparkDR;
RGB_T wizRGB, sparkRGB;

 WizardROM #(
	.SCALE(0),
	.TOP(WIZ_Y),
	.LEFT(WIZ_X)
 )wizard (
	.clk(clk),
	.resetN(resetN),
	.pixelX(pixelX),
	.pixelY(pixelY),
	.frameIndex(currentFrame),
	.startOfFrame(startOfFrame),
	.isCasting(isCasting),
	.RGBout(wizRGB),
	.dr(wizDR)
);
	 
AnimationRom #(
	.WIDTH(16),
	.HEIGHT(16),
	.TOP (SPARK_Y),
	.LEFT(SPARK_X),
	.ANIMATION_LENGTH(4),
	.POTION_ID(4),
	.ANIMATION_SLOWDOWN_RATE(4),
	.SCALE(0)
) spark (
	.clk(clk),
	.resetN(resetN),
	.pixelX(pixelX),  
	.pixelY(pixelY),  
	.startOfFrame(startOfFrame), 

	.RGBout(sparkRGB),
	.dr(sparkDR)
);


always_ff @(posedge clk or negedge resetN) begin
	if (!resetN) begin
		levelDisplayDR <= 0;
		levelDisplayRGB <= 8'hFF;
	end else if (enable) begin
		levelDisplayDR <= 1;
		
		if (sparkDR && isCasting ) levelDisplayRGB <= sparkRGB;
		else if (wizDR) levelDisplayRGB <= wizRGB;
		
		else levelDisplayDR <= 0;
		
	end else begin
		levelDisplayDR <= 0;
		levelDisplayRGB <= 8'hFF;
	end
end

endmodule