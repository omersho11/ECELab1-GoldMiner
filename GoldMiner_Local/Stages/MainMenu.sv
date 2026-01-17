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

TextRom # (
	.WIDTH(229),
	.HEIGHT(14),
	.TOP(200),
	.LEFT(205),
	.TEXT_ID(PLUS_TO_START),
	.SCALE(0)
) plusToStart (
	.clk(clk),
	.resetN(resetN),
	.enable(enable),
	.pixelX(pixelX),  
	.pixelY(pixelY),

	.RGBout(RGBout),     // The pixel color
	.dr(dr)
);


always_ff@(posedge clk or negedge resetN) begin
	if (!resetN) begin
		stageEnded <= 0;
	end else begin
		stageEnded <= 0;
		if (enable) stageEnded <= anyKeyPressed;
	end
end
endmodule
