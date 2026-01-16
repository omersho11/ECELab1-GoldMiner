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

import GlobalsPKG::*;


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

localparam POS_X_EXT_SPEED = 11'd96;
localparam POS_Y_EXT_SPEED = 11'd80;
localparam POS_X_TEXT_EXT_SPEED = 11'd140; 
localparam POS_Y_TEXT_EXT_SPEED = 11'd100; 
localparam POS_X_BANNER_EXT_SPEED = 11'd96;
localparam POS_Y_BANNER_EXT_SPEED = 11'd0;

localparam POS_X_LUCK = 11'd420;
localparam POS_Y_LUCK = 11'd72;
localparam POS_X_TEXT_LUCK = 11'd448;
localparam POS_Y_TEXT_LUCK = 11'd100;
localparam POS_X_BANNER_LUCK = 11'd416;
localparam POS_Y_BANNER_LUCK = 11'd0;

localparam POS_X_MULT = 11'd110;
localparam POS_Y_MULT = 11'd330;
localparam POS_X_TEXT_MULT = 11'd140;
localparam POS_Y_TEXT_MULT = 11'd360;
localparam POS_X_BANNER_MULT = 11'd100;
localparam POS_Y_BANNER_MULT = 11'd251;

localparam POS_X_ROT_SPEED = 11'd420;
localparam POS_Y_ROT_SPEED = 11'd328;
localparam POS_X_TEXT_ROT_SPEED = 11'd448;
localparam POS_Y_TEXT_ROT_SPEED = 11'd360;
localparam POS_X_BANNER_ROT_SPEED = 11'd416;
localparam POS_Y_BANNER_ROT_SPEED = 11'd251;
 
localparam POS_X_KEY_1 = 11'd144;
localparam POS_Y_KEY_1 = 11'd170;
localparam POS_X_KEY_2 = 11'd464;
localparam POS_Y_KEY_2 = 11'd170;
localparam POS_X_KEY_3 = 11'd144;
localparam POS_Y_KEY_3 = 11'd426;
localparam POS_X_KEY_4 = 11'd464;
localparam POS_Y_KEY_4 = 11'd426; 


 // --- 2. Price Displays (Text) ---
logic drTextSpeed, drTextLuck, drTextMult, drTextRot;
RGB_T rgbSpeed, rgbLuck, rgbMult, rgbRot;
 
 
// Item 1: Speed (White Text)
FiveDigitNumberDisplay #( .color(MONEY_TEXT_COLOR) ) dispExtSpeed (
  .clk(clk), .resetN(resetN), .enable(enable),
  .topLeftX(POS_X_TEXT_EXT_SPEED), .topLeftY(POS_Y_TEXT_EXT_SPEED),
  .pixelX(pixelX), .pixelY(pixelY),
  .number(priceExtSpeed),
  .startOfFrame(startOfFrame),
  .drawingRequest(drTextSpeed),
  .RGBout(rgbSpeed)
);

// Item 2: Luck (White Text)
FiveDigitNumberDisplay #( .color(MONEY_TEXT_COLOR) ) dispLuck (
  .clk(clk), .resetN(resetN), .enable(enable),
  .topLeftX(POS_X_TEXT_LUCK), .topLeftY(POS_Y_TEXT_LUCK),
  .pixelX(pixelX), .pixelY(pixelY),
  .number(priceLuck),
  .startOfFrame(startOfFrame),
  .drawingRequest(drTextLuck),
  .RGBout(rgbLuck)
);

// Item 3: Multiplier (White Text)
FiveDigitNumberDisplay #( .color(MONEY_TEXT_COLOR) ) dispMult (
  .clk(clk), .resetN(resetN), .enable(enable),
  .topLeftX(POS_X_TEXT_MULT), .topLeftY(POS_Y_TEXT_MULT),
  .pixelX(pixelX), .pixelY(pixelY),
  .number(priceMult),
  .startOfFrame(startOfFrame),
  .drawingRequest(drTextMult),
  .RGBout(rgbMult)
);

// Item 4: Rotation (White Text)
FiveDigitNumberDisplay #( .color(MONEY_TEXT_COLOR) ) dispRotSpeed (
	  .clk(clk), .resetN(resetN), .enable(enable),
	  .topLeftX(POS_X_TEXT_ROT_SPEED), .topLeftY(POS_Y_TEXT_ROT_SPEED),
	  .pixelX(pixelX), .pixelY(pixelY),
	  .number(priceRotSpeed),
	  .startOfFrame(startOfFrame),
	  .drawingRequest(drTextRot),
	  .RGBout(rgbRot)
 );
 
 // --- 3. ROM Initialization ---
 
RGB_T romRGB;
logic romTransp;

RGB_T potion0RGB, potion1RGB, potion2RGB, potion3RGB;
logic potion0DR, potion1DR, potion2DR, potion3DR;

RGB_T bannerExtSpeedRGB, bannerLuckRGB, bannerMultRGB, bannerRotSpeedRGB;
logic bannerExtSpeedDR, bannerLuckDR, bannerMultDR, bannerRotSpeedDR;

RGB_T key1RGB, key2RGB, key3RGB, key4RGB;
logic key1DR, key2DR, key3DR, key4DR;


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
		
		if (drTextSpeed) shopRGB <= rgbSpeed;
		else if (drTextLuck) shopRGB <= rgbLuck;
		else if (drTextMult) shopRGB <= rgbMult;
		else if (drTextRot) shopRGB <= rgbRot;
		
		else if (potion0DR) shopRGB <= potion0RGB;
		else if (potion1DR) shopRGB <= potion1RGB;
		else if (potion2DR) shopRGB <= potion2RGB;
		else if (potion3DR) shopRGB <= potion3RGB;
		
		else if (bannerExtSpeedDR) shopRGB <= bannerExtSpeedRGB;
		else if (bannerLuckDR) shopRGB <= bannerLuckRGB;
		else if (bannerMultDR) shopRGB <= bannerMultRGB;
		else if (bannerRotSpeedDR) shopRGB <= bannerRotSpeedRGB;
		
		else if (key1DR) shopRGB <= key1RGB;
		else if (key2DR) shopRGB <= key2RGB;
		else if (key3DR) shopRGB <= key3RGB;
		else if (key4DR) shopRGB <= key4RGB;
		
		else shopDR <= 0;
	end else begin
		shopDR <= 0;
		shopRGB <= 8'hFF;
	end
end
// Extention Speed Potion
AnimationRom #(
	.WIDTH(18),
	.HEIGHT(32),
	.TOP (POS_Y_EXT_SPEED),
	.LEFT(POS_X_EXT_SPEED),
	.ANIMATION_LENGTH(22),
	.POTION_ID(0),
	.ANIMATION_SLOWDOWN_RATE(8),
	.SCALE(1)
) potion0 (
	.clk(clk),
	.resetN(resetN),
	.pixelX(pixelX),  
	.pixelY(pixelY),  
	.startOfFrame(startOfFrame), 

	.RGBout(potion0RGB),
	.dr(potion0DR)
);
// Multiplier Potion
AnimationRom #(
	.WIDTH(18),
	.HEIGHT(32),
	.TOP (POS_Y_MULT),
	.LEFT(POS_X_MULT),
	.ANIMATION_LENGTH(14),
	.POTION_ID(1),
	.ANIMATION_SLOWDOWN_RATE(8),
	.SCALE(1)
) potion1 (
	.clk(clk),
	.resetN(resetN),
	.pixelX(pixelX),  
	.pixelY(pixelY),  
	.startOfFrame(startOfFrame), 

	.RGBout(potion1RGB),
	.dr(potion1DR)
);
// Rotation Speed Potion
AnimationRom #(
	.WIDTH(18),
	.HEIGHT(32),
	.TOP (POS_Y_ROT_SPEED),
	.LEFT(POS_X_ROT_SPEED),
	.ANIMATION_LENGTH(15),
	.POTION_ID(2),
	.ANIMATION_SLOWDOWN_RATE(8),
	.SCALE(1)
) potion2 (
	.clk(clk),
	.resetN(resetN),
	.pixelX(pixelX),  
	.pixelY(pixelY),  
	.startOfFrame(startOfFrame), 

	.RGBout(potion2RGB),
	.dr(potion2DR)
);
// Luck Potion
AnimationRom #(
	.WIDTH(18),
	.HEIGHT(32),
	.TOP (POS_Y_LUCK),
	.LEFT(POS_X_LUCK),
	.ANIMATION_LENGTH(24),
	.POTION_ID(3),
	.ANIMATION_SLOWDOWN_RATE(8),
	.SCALE(1)
) potion3 (
	.clk(clk),
	.resetN(resetN),
	.pixelX(pixelX),  
	.pixelY(pixelY),  
	.startOfFrame(startOfFrame), 

	.RGBout(potion3RGB),
	.dr(potion3DR)
);

// Extention Speed Banner
ImageRom #(
	.TOP (POS_Y_BANNER_EXT_SPEED),
	.LEFT(POS_X_BANNER_EXT_SPEED),
	.IMAGE_ID(BANNER_EXT_SPEED),
	.SCALE(1)
) bannerExtSpeed (
	.clk(clk),
	.resetN(resetN),
	.pixelX(pixelX),  
	.pixelY(pixelY),  

	.RGBout(bannerExtSpeedRGB),
	.dr(bannerExtSpeedDR)
);

// Luck Banner
ImageRom #(
	.TOP (POS_Y_BANNER_LUCK),
	.LEFT(POS_X_BANNER_LUCK),
	.IMAGE_ID(BANNER_LUCK),
	.SCALE(1)
) bannerLuck (
	.clk(clk),
	.resetN(resetN),
	.pixelX(pixelX),  
	.pixelY(pixelY),  

	.RGBout(bannerLuckRGB),
	.dr(bannerLuckDR)
);

// Multiplier Banner
ImageRom #(
	.TOP (POS_Y_BANNER_MULT),
	.LEFT(POS_X_BANNER_MULT),
	.IMAGE_ID(BANNER_MULT),
	.SCALE(1)
) bannerMult (
	.clk(clk),
	.resetN(resetN),
	.pixelX(pixelX),  
	.pixelY(pixelY),  

	.RGBout(bannerMultRGB),
	.dr(bannerMultDR)
);

// Rotation Speed Banner
ImageRom #(
	.TOP (POS_Y_BANNER_ROT_SPEED),
	.LEFT(POS_X_BANNER_ROT_SPEED),
	.IMAGE_ID(BANNER_ROT_SPEED),
	.SCALE(1)
) bannerRotSpeed (
	.clk(clk),
	.resetN(resetN),
	.pixelX(pixelX),  
	.pixelY(pixelY),  

	.RGBout(bannerRotSpeedRGB),
	.dr(bannerRotSpeedDR)
);

ImageRom #(
	.WIDTH(32), .HEIGHT(32),
	.TOP (POS_Y_KEY_1),
	.LEFT(POS_X_KEY_1),
	.IMAGE_ID(KEY_1)
) key1rom (
	.clk(clk),
	.resetN(resetN),
	.pixelX(pixelX),  
	.pixelY(pixelY),  

	.RGBout(key1RGB),
	.dr(key1DR)
);

ImageRom #(
	.WIDTH(32), .HEIGHT(32),
	.TOP (POS_Y_KEY_2),
	.LEFT(POS_X_KEY_2),
	.IMAGE_ID(KEY_2)
) key2rom (
	.clk(clk),
	.resetN(resetN),
	.pixelX(pixelX),  
	.pixelY(pixelY),  

	.RGBout(key2RGB),
	.dr(key2DR)
);

ImageRom #(
	.WIDTH(32), .HEIGHT(32),
	.TOP (POS_Y_KEY_3),
	.LEFT(POS_X_KEY_3),
	.IMAGE_ID(KEY_3)
) key3rom (
	.clk(clk),
	.resetN(resetN),
	.pixelX(pixelX),  
	.pixelY(pixelY),  

	.RGBout(key3RGB),
	.dr(key3DR)
);

ImageRom #(
	.WIDTH(32), .HEIGHT(32),
	.TOP (POS_Y_KEY_4),
	.LEFT(POS_X_KEY_4),
	.IMAGE_ID(KEY_4)
) key4rom (
	.clk(clk),
	.resetN(resetN),
	.pixelX(pixelX),  
	.pixelY(pixelY),  

	.RGBout(key4RGB),
	.dr(key4DR)
);


endmodule