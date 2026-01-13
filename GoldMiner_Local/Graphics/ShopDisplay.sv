module ShopDisplay (
    input  logic clk,
    input  logic resetN,
    input  logic enable,        // Active when state == SHOP
    input  logic [10:0] pixelX,
    input  logic [10:0] pixelY,
	 input logic startOfFrame,

    // --- Price Inputs (From Shop Logic) ---
    input  logic [19:0] priceExtSpeed,
    input  logic [19:0] priceLuck,
    input  logic [19:0] priceMult,
    input  logic [19:0] priceRotSpeed,

    // --- Video Output ---
    output logic shopDR,        // Draw Request
    output logic [7:0] shopRGB  // Color Output
);

 // --- 1. Layout Configuration ---
 logic [10:0] offXExtSpeed, offYExtSpeed;
 logic [10:0] offXLuck,  offYLuck;
 logic [10:0] offXMult,  offYMult;
 logic [10:0] offXRotSpeed,   offYRotSpeed;
 
 
 assign offXExtSpeed = pixelX - POS_X_EXT_SPEED;
 assign offYExtSpeed = pixelY - POS_Y_EXT_SPEED;
 
 assign offXLuck  = pixelX - POS_X_LUCK;
 assign offYLuck  = pixelY - POS_Y_LUCK;
 
 assign offXMult  = pixelX - POS_X_LUCK;
 assign offYMult  = pixelY - POS_Y_LUCK;
 
 assign offXRotSpeed = pixelX - POS_X_ROT_SPEED;
 assign offYRotSpeed = pixelY - POS_Y_ROT_SPEED;
 
 
 localparam POS_X_EXT_SPEED = 11'd80;
 localparam POS_Y_EXT_SPEED = 11'd80;
 localparam POS_Y_TEXT_EXT_SPEED =11'd120; 


 localparam POS_X_LUCK = 11'd160;
 localparam POS_Y_LUCK = 11'd80;
 localparam POS_Y_TEXT_LUCK =11'd120;
 
 localparam POS_X_MULT = 11'd240;
 localparam POS_Y_MULT = 11'd80;
 localparam POS_Y_TEXT_MULT =11'd120;
 
 localparam POS_X_ROT_SPEED = 11'd320;
 localparam POS_Y_ROT_SPEED = 11'd80;
 localparam POS_Y_TEXT_ROT_SPEED =11'd120;
 

 // --- 2. Price Displays (Text) ---
 logic drTextSpeed, drTextLuck, drTextMult, drTextRot;
 logic [7:0] rgbSpeed, rgbLuck, rgbMult, rgbRot;
 
 
// Item 1: Speed (White Text)
FiveDigitNumberDisplay #( .color(8'hFE) ) dispExtSpeed (
  .clk(clk), .resetN(resetN), .enable(enable),
  .topLeftX(POS_X_EXT_SPEED), .topLeftY(POS_Y_TEXT_EXT_SPEED),
  .pixelX(pixelX), .pixelY(pixelY),
  .number(priceExtSpeed),
  .startOfFrame(startOfFrame),
  .drawingRequest(drTextSpeed),
  .RGBout(rgbSpeed)
);

// Item 2: Luck (White Text)
FiveDigitNumberDisplay #( .color(8'hFE) ) dispLuck (
  .clk(clk), .resetN(resetN), .enable(enable),
  .topLeftX(POS_X_LUCK), .topLeftY(POS_Y_TEXT_LUCK),
  .pixelX(pixelX), .pixelY(pixelY),
  .number(priceLuck),
  .startOfFrame(startOfFrame),
  .drawingRequest(drTextLuck),
  .RGBout(rgbLuck)
);

// Item 3: Multiplier (White Text)
FiveDigitNumberDisplay #( .color(8'hFE) ) dispMult (
  .clk(clk), .resetN(resetN), .enable(enable),
  .topLeftX(POS_X_MULT), .topLeftY(POS_Y_TEXT_MULT),
  .pixelX(pixelX), .pixelY(pixelY),
  .number(priceMult),
  .startOfFrame(startOfFrame),
  .drawingRequest(drTextMult),
  .RGBout(rgbMult)
);

// Item 4: Rotation (White Text)
FiveDigitNumberDisplay #( .color(8'hFE) ) dispRotSpeed (
	  .clk(clk), .resetN(resetN), .enable(enable),
	  .topLeftX(POS_X_ROT), .topLeftY(POS_Y_TEXT_ROT_SPEED),
	  .pixelX(pixelX), .pixelY(pixelY),
	  .number(priceRotSpeed),
	  .startOfFrame(startOfFrame),
	  .drawingRequest(drTextRot),
	  .RGBout(rgbRot)
 );
 
 // --- 3. ROM Initialization ---
 
logic [7:0] romRGB;
logic romTransp;

logic [7:0] potion0RGB;
logic potion0DR;
logic [7:0] potion1RGB;
logic potion1DR;
logic [7:0] potion2RGB;
logic potion2DR;
logic [7:0] potion3RGB;
logic potion3DR;

logic [1:0] currentPotionID;
logic [5:0] currentOffsetX, currentOffsetY;

	 
always_comb begin
	currentPotionID = 0;
	currentOffsetX  = 0;
	currentOffsetY  = 0;

	if ((pixelX >= POS_X_EXT_SPEED && pixelX < POS_X_EXT_SPEED + 64) && 
		(pixelY >= POS_Y_EXT_SPEED && pixelY < POS_Y_EXT_SPEED + 32)) begin
		currentPotionID = 0;
		currentOffsetX  = offXExtSpeed;
		currentOffsetY  = offYExtSpeed;
	end 
	else if ((pixelX >= POS_X_LUCK && pixelX < POS_X_LUCK + 64) && 
		(pixelY >= POS_Y_LUCK && pixelY < POS_Y_LUCK + 32)) begin
		currentPotionID = 1;
		currentOffsetX  = offXLuck;
		currentOffsetY  = offYLuck;
	end 
	else if ((pixelX >= POS_X_MULT && pixelX < POS_X_MULT + 64) && 
		(pixelY >= POS_Y_MULT && pixelY < POS_Y_MULT + 32)) begin
		currentPotionID = 2;
		currentOffsetX  = offXMult;
		currentOffsetY  = offYMult;
	end 
	else if ((pixelX >= POS_X_ROT_SPEED && pixelX < POS_X_ROT_SPEED + 64) && 
		(pixelY >= POS_Y_ROT_SPEED && pixelY < POS_Y_ROT_SPEED + 32)) begin
		currentPotionID = 3;
		currentOffsetX  = offXRotSpeed;
		currentOffsetY  = offYRotSpeed;
	end 
end
    
	 
// --- 4. Final Output Multiplexer ---
always_ff @(posedge clk or negedge resetN) begin
	if (!resetN) begin
		shopDR <= 0;
		shopRGB <= 8'hFF;
	end else if (enable) begin
		shopDR <= 1;
		
		if (drTextSpeed) begin
			shopRGB <= rgbSpeed;
		end
		else if (drTextLuck) begin
			shopRGB <= rgbLuck;
		end
		else if (drTextMult) begin
			shopRGB <= rgbMult;
		end
		else if (drTextRot) begin
			shopRGB <= rgbRot;
		end
		else if (potion0DR) begin
			shopRGB <= potion0RGB;
		end
		else if (potion1DR) begin
			shopRGB <= potion1RGB;
		end
		else if (potion2DR) begin
			shopRGB <= potion2RGB;
		end
		else if (potion3DR) begin
			shopRGB <= potion3RGB;
		end
		else shopDR <= 0;
	end else begin
		shopDR <= 0;
		shopRGB <= 8'hFF;
	end
end

AnimationRom #(
	.WIDTH(18),
	.HEIGHT(32),
	.TOP (80),
	.LEFT(100),
	.ANIMATION_LENGTH(22),
	.POTION_ID(0),
	.ANIMATION_SLOWDOWN_RATE(4)
) potion0 (
	.clk(clk),
	.resetN(resetN),
	.pixelX(pixelX),  
	.pixelY(pixelY),  
	.startOfFrame(startOfFrame), 

	.RGBout(potion0RGB),
	.dr(potion0DR)
);
AnimationRom #(
	.WIDTH(18),
	.HEIGHT(32),
	.TOP (80),
	.LEFT(120),
	.ANIMATION_LENGTH(14),
	.POTION_ID(1),
	.ANIMATION_SLOWDOWN_RATE(4)
) potion1 (
	.clk(clk),
	.resetN(resetN),
	.pixelX(pixelX),  
	.pixelY(pixelY),  
	.startOfFrame(startOfFrame), 

	.RGBout(potion1RGB),
	.dr(potion1DR)
);

AnimationRom #(
	.WIDTH(18),
	.HEIGHT(32),
	.TOP (80),
	.LEFT(140),
	.ANIMATION_LENGTH(15),
	.POTION_ID(2),
	.ANIMATION_SLOWDOWN_RATE(4)
) potion2 (
	.clk(clk),
	.resetN(resetN),
	.pixelX(pixelX),  
	.pixelY(pixelY),  
	.startOfFrame(startOfFrame), 

	.RGBout(potion2RGB),
	.dr(potion2DR)
);

AnimationRom #(
	.WIDTH(18),
	.HEIGHT(32),
	.TOP (80),
	.LEFT(160),
	.ANIMATION_LENGTH(24),
	.POTION_ID(3),
	.ANIMATION_SLOWDOWN_RATE(4)
) potion3 (
	.clk(clk),
	.resetN(resetN),
	.pixelX(pixelX),  
	.pixelY(pixelY),  
	.startOfFrame(startOfFrame), 

	.RGBout(potion3RGB),
	.dr(potion3DR)
);

	
endmodule