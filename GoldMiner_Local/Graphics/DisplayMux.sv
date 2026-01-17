module DisplayMux (
	input logic [7:0] RGBBackground,
	
	input logic levelDR,
	input logic [7:0] levelRGB,
	input logic levelDisplayDR,
	input logic [7:0] levelDisplayRGB,
	
	input logic scoreDR,
	input logic [7:0] scoreRGB,
	input logic moneyDR,
	input logic [7:0] moneyRGB,
	input logic targetScoreDR,
	input logic [7:0] targetScoreRGB,
	
	input logic hookDR,
	input logic [7:0] hookRGB,
	
	input logic timeDR,
	input logic [7:0] timeRGB,
	
	input logic shopDR,
	input logic [7:0] shopRGB,
	
	input logic mainMenuDR,
	input logic [7:0] mainMenuRGB,
	
	input logic lossMenuDR,
	input logic [7:0] lossMenuRGB,
	
	output logic [7:0] RGBout
);



always_comb begin
	RGBout = RGBBackground;
	if (hookDR) RGBout = hookRGB;
	else if(scoreDR) RGBout = scoreRGB;
	else if(moneyDR) RGBout = moneyRGB;
	
	else if(targetScoreDR) RGBout = targetScoreRGB;
	else if(timeDR) RGBout = timeRGB;
	else if(levelDR) RGBout = levelRGB;
	else if(levelDisplayDR) RGBout = levelDisplayRGB;
	
	else if(shopDR) RGBout = shopRGB;
	else if(mainMenuDR) RGBout = mainMenuRGB;
	else if(lossMenuDR) RGBout = lossMenuRGB;
end


endmodule