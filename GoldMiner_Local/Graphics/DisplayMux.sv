module DisplayMux (
	input logic [7:0] RGBBackground,
	
	input logic levelDR,
	input logic [7:0] levelRGB,
	
	output logic [7:0] RGBout
);
 
 


always_comb begin
	RGBout = RGBBackground;
	if(levelDR) RGBout = levelRGB;
end


endmodule