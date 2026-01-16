module CompleteHook #(
    parameter OFFSET_X = 320,
    parameter OFFSET_Y = 96,
    parameter MIN_LENGTH = 100,
    parameter MAX_LENGTH = 600,
    parameter LINE_THICKNESS = 1, 
    parameter LINE_COLOR = 8'hFE
) (
    input logic clk,
    input logic resetN,
    input logic enable,
    input logic startOfFrame,
    input logic sendHook,
    input logic collisionOccurred,
    input logic [8:0] extentionSpeed,
    input logic [8:0] rotationSpeed,
    input logic [10:0] pixelX,
    input logic [10:0] pixelY,
    input logic hookSlowdown,

    output logic [10:0] hookPosX,
    output logic [10:0] hookPosY,
    output logic hookReturned,
    output logic hookDR,
    output logic [7:0] hookRGB,
	 output logic isHookOut
);

    // --- 1. Physics Engine ---
    Hook #(
        .OFFSET_X(OFFSET_X),
        .OFFSET_Y(OFFSET_Y),
        .MIN_LENGTH(MIN_LENGTH), 
        .MAX_LENGTH(MAX_LENGTH)
    ) hook (
        .clk(clk),
        .resetN(resetN),
        .enable(enable),
        .startOfFrame(startOfFrame),
        .sendHook(sendHook),
        .forceReturn(collisionOccurred),
        .extentionSpeed(extentionSpeed),
        .rotationSpeed(rotationSpeed),
        .hookRetractSlowdown(hookSlowdown),
        
        .x(hookPosX),   // Connects to Projectile
        .y(hookPosY),
        .hookReturnedPulse(hookReturned)
    );

    // --- 2. The Static Cursor (Line) ---
    // Always drawn, freezes when casting because cursorX/Y freeze
    logic lineDR;
    logic [7:0] lineRGB_out; // Renamed to avoid collision
    
    DrawLine lineDrawer (
        .pixelX(pixelX),
        .pixelY(pixelY),
		  .width(LINE_THICKNESS),
		  .lineColor(LINE_COLOR),
        .x1(OFFSET_X),
        .y1(OFFSET_Y),
        .x2(hookPosX), // Draw only to the Cursor Tip
        .y2(hookPosY),
        
        .lineDR(lineDR),
        .lineRGB(lineRGB_out) 
    );

    // --- 3. The Projectile (Sprite) ---
    // Moves away from the cursor when cast
    logic spriteDR;
    logic [7:0] spriteRGB;

    MagicProjectileROM #(
        .WIDTH(32), 
        .HEIGHT(32)
    ) projectile (
        .clk(clk),
        .resetN(resetN),             
        .startOfFrame(startOfFrame), 
        .pixelX(pixelX),
        .pixelY(pixelY),
        .centerX(hookPosX), 
        .centerY(hookPosY),
        
        .rgbOut(spriteRGB),
        .dr(spriteDR)
    );
	 
    // --- 4. Final Mixer ---
    always_ff @(posedge clk or negedge resetN) begin
        if (!resetN) begin
            hookDR <= 0;
            hookRGB <= 0;
				isHookOut <= 0;
        end else if (enable) begin
            // Priority: Draw Projectile on top of Line
				isHookOut <= isHookOut || sendHook;
				if (hookReturned) isHookOut <= 0;
				
            if (spriteDR && isHookOut) begin
                hookDR <= 1;
                hookRGB <= spriteRGB;
            end else if (lineDR) begin
                hookDR <= 1;
                hookRGB <= LINE_COLOR; // Or lineRGB_out if your module outputs color
            end else begin
                hookDR <= 0;
                hookRGB <= 8'hFF;
            end
        end else begin
            hookDR <= 0;
        end
    end

endmodule