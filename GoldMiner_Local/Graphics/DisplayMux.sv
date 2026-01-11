module DisplayMux (
	input logic [7:0] RGBBackground,
	
	input logic levelDR,
	input logic [7:0] levelRGB,
	
	input logic scoreDR,
	input logic [7:0] scoreRGB,
	input logic moneyDR,
	input logic [7:0] moneyRGB,
	
	input logic hookDR,
	input logic [7:0] hookRGB,
	
	input logic timeDR,
	input logic [7:0] timeRGB,
	
	input logic shopDR,
	input logic [7:0] shopRGB,
	
	output logic [7:0] RGBout
);



always_comb begin
	RGBout = RGBBackground;
	if (hookDR) RGBout = hookRGB;
	else if(levelDR) RGBout = levelRGB;
	else if(scoreDR) RGBout = scoreRGB;
	else if(moneyDR) RGBout = moneyRGB;
	else if(timeDR) RGBout = timeRGB;
	else if(shopDR) RGBout = shopRGB;
end


endmodule