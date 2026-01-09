module DisplayMux (
	input logic [7:0] RGBBackground,
	
	input logic levelDR,
	input logic [7:0] levelRGB,
	
	input logic scoreDR,
	input logic [7:0] scoreRGB,
	input logic moneyDR,
	input logic [7:0] moneyRGB,
	
	output logic [7:0] RGBout
);
 
 


always_comb begin
	RGBout = RGBBackground;
	if(levelDR) RGBout = levelRGB;
	else if(scoreDR) RGBout = scoreRGB;
	else if(moneyDR) RGBout = moneyRGB;
end


endmodule