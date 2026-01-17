module	MainMenu	(	
			input	logic	clk,
			input	logic	resetN,
			input logic enable,
			input logic [10:0] pixelX,  
			input logic [10:0] pixelY,
			input logic anyKeyPressed,
			output logic drStage,
			output logic stageEnded,
			output logic [7:0] RGBout,     // The pixel color
			output logic dr
);

import GlobalsPKG::*;

logic logoDR, plusToStartDR;
RGB_T logoRGB, plusToStartRGB;

ImageRom # (
	.WIDTH(134),
	.HEIGHT(116),
	.TOP(50),
	.LEFT(186),
	.IMAGE_ID(LOGO),
	.SCALE(1)
) gameLogo (
	.clk(clk),
	.resetN(resetN),
	.pixelX(pixelX),  
	.pixelY(pixelY),

	.RGBout(logoRGB),     // The pixel color
	.dr(logoDR)
);

TextRom # (
	.WIDTH(229),
	.HEIGHT(14),
	.TOP(400),
	.LEFT(91),
	.TEXT_ID(PLUS_TO_START),
	.SCALE(1)
) plusToStart (
	.clk(clk),
	.resetN(resetN),
	.enable(enable),
	.pixelX(pixelX),  
	.pixelY(pixelY),

	.RGBout(plusToStartRGB),     // The pixel color
	.dr(plusToStartDR)
);


always_ff@(posedge clk or negedge resetN) begin
	if (!resetN) begin
		stageEnded <= 0;
	end else begin
		stageEnded <= 0;
		if (enable) stageEnded <= anyKeyPressed;
	end
end

always_ff@(posedge clk or negedge resetN) begin
	if (!resetN) begin
		dr <= 0;
	end else begin
		dr <= 0;
		
		if (enable) begin
			dr <= 1;
			RGBout <= 8'hff;
			
			if (logoDR) RGBout <= logoRGB;
			else if (plusToStartDR) RGBout <= plusToStartRGB;
			else dr <= 0;
		
		end
	end
end

endmodule
