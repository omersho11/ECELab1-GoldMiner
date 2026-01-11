module ShopDisplay (
    input  logic clk,
    input  logic resetN,
    input  logic enable,        // Active when state == SHOP
    input  logic [10:0] pixelX,
    input  logic [10:0] pixelY,

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
	 
	 logic [3:0] animFrame;
    logic [25:0] animCounter;
    always_ff @(posedge clk) begin
        animCounter <= animCounter + 1;
        if (animCounter == 26'd5_000_000) begin
            animCounter <= 0;
            animFrame <= animFrame + 1;
        end
    end
	 
	 // Item 1: Speed (White Text)
    FiveDigitNumberDisplay #( .color(8'hFE) ) dispExtSpeed (
        .clk(clk), .resetN(resetN), .enable(enable),
        .topLeftX(POS_X_EXT_SPEED), .topLeftY(POS_Y_TEXT_EXT_SPEED),
        .pixelX(pixelX), .pixelY(pixelY),
        .number(priceExtSpeed),
        .drawingRequest(drTextSpeed),
        .RGBout(rgbSpeed)
    );

    // Item 2: Luck (White Text)
    FiveDigitNumberDisplay #( .color(8'hFE) ) dispLuck (
        .clk(clk), .resetN(resetN), .enable(enable),
        .topLeftX(POS_X_LUCK), .topLeftY(POS_Y_TEXT_LUCK),
        .pixelX(pixelX), .pixelY(pixelY),
        .number(priceLuck),
        .drawingRequest(drTextLuck),
        .RGBout(rgbLuck)
    );

    // Item 3: Multiplier (White Text)
    FiveDigitNumberDisplay #( .color(8'hFE) ) dispMult (
        .clk(clk), .resetN(resetN), .enable(enable),
        .topLeftX(POS_X_MULT), .topLeftY(POS_Y_TEXT_MULT),
        .pixelX(pixelX), .pixelY(pixelY),
        .number(priceMult),
        .drawingRequest(drTextMult),
        .RGBout(rgbMult)
    );

    // Item 4: Rotation (White Text)
    FiveDigitNumberDisplay #( .color(8'hFE) ) dispRotSpeed (
        .clk(clk), .resetN(resetN), .enable(enable),
        .topLeftX(POS_X_ROT), .topLeftY(POS_Y_TEXT_ROT_SPEED),
        .pixelX(pixelX), .pixelY(pixelY),
        .number(priceRotSpeed),
        .drawingRequest(drTextRot),
        .RGBout(rgbRot)
    );
	 
	 // --- 3. ROM Initialization ---
	 
	 logic [7:0] romRGB;
    logic romTransp;
    logic [1:0] currentPotionID;
    logic [5:0] currentOffsetX, currentOffsetY;
	 
	 PotionAssetsROM potionROM (
        .clk(clk),
        .potionID(currentPotionID),
        .frameIndex(animFrame),
        .offsetX(currentOffsetX),
        .offsetY(currentOffsetY),
        .rgbOut(romRGB),
        .isTransparent(romTransp)
    );
	 
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
	always_comb begin
		shopDR  = 1'b0;
		shopRGB = 8'hFF;

		if (enable) begin
			// Priority 1: Text (Prices)
			if (drTextSpeed) begin
				 shopRGB = rgbSpeed;
			end
			else if (drTextLuck) begin
				 shopRGB = rgbLuck;
			end
			else if (drTextMult) begin
				 shopRGB = rgbMult;
			end
			else if (drTextRot) begin
				 shopRGB = rgbRot;
			end
			
			if (!romTransp) begin
				 shopRGB = romRGB;
			end
			
			shopDR = ((shopRGB == 8'hFF) ? 0 : 1);

			
		end
	end
endmodule