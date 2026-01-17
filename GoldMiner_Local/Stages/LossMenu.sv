module	LossMenu	(	
			input	logic	clk,
			input	logic	resetN,
			input logic enable,
			input logic [10:0] pixelX,  
			input logic [10:0] pixelY,
			input logic anyKeyPressed,
			input SCORE score,
			input logic startOfFrame,
			output logic drStage,
			output logic stageEnded,
			output logic [7:0] RGBout,     // The pixel color
			output logic dr
);

import GlobalsPKG::*;

logic youLostTextDR, plusToContinueDR, finalScoreTextDR, finalScoreNumberDR;
RGB_T youLostTextRGB, plusToContinueRGB, finalScoreTextRGB, finalScoreNumberRGB;

TextRom # (
	.WIDTH(280),
	.HEIGHT(14),
	.TOP(96),
	.LEFT(40),
	.TEXT_ID(YOU_LOST),
	.SCALE(1)
) youLost (
	.clk(clk),
	.resetN(resetN),
	.enable(enable),
	.pixelX(pixelX),  
	.pixelY(pixelY),

	.RGBout(youLostTextRGB),     // The pixel color
	.dr(youLostTextDR)
);

TextRom # (
	.WIDTH(269),
	.HEIGHT(14),
	.TOP(400),
	.LEFT(51),
	.TEXT_ID(PLUS_TO_CONTINUE),
	.SCALE(1)
) plusToContinue (
	.clk(clk),
	.resetN(resetN),
	.enable(enable),
	.pixelX(pixelX),  
	.pixelY(pixelY),

	.RGBout(plusToContinueRGB),     // The pixel color
	.dr(plusToContinueDR)
);
TextRom # (
	.WIDTH(272),
	.HEIGHT(14),
	.TOP(250),
	.LEFT(48),
	.TEXT_ID(FINAL_SCORE),
	.SCALE(1)
) finalScoreText (
	.clk(clk),
	.resetN(resetN),
	.enable(enable),
	.pixelX(pixelX),  
	.pixelY(pixelY),

	.RGBout(finalScoreTextRGB),     // The pixel color
	.dr(finalScoreTextDR)
);


FiveDigitNumberDisplay #(
    .color(8'hfe),
	 .topLeftX(280),
	 .topLeftY(285)
) finalScoreNumber (
    .clk(clk),
    .resetN(resetN),
    .enable(enable),
    .pixelX(pixelX),
    .pixelY(pixelY),
    .number(score),
    .startOfFrame(startOfFrame),

    .drawingRequest(finalScoreNumberDR),
    .RGBout(finalScoreNumberRGB)
);

always_ff@(posedge clk or negedge resetN) begin
	if (!resetN) begin
		stageEnded <= 0;
	end else begin
		stageEnded <= (enable && anyKeyPressed);
	end
end

always_ff@(posedge clk or negedge resetN) begin
	if (!resetN) begin
		dr <= 0;
		RGBout <= 8'hff;
	end else begin
		dr <= 0;
		if (enable) begin
			dr <= 1;
			RGBout <= 8'hff;
			
			if (youLostTextDR) RGBout <= youLostTextRGB;
			else if (plusToContinueDR) RGBout <= plusToContinueRGB;
			else if (finalScoreTextDR) RGBout <= finalScoreTextRGB;
			else if (finalScoreNumberDR) RGBout <= finalScoreNumberRGB;
			else dr <= 0;
		end
	end
end
endmodule
