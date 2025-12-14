module DisplayMux #(
	parameter NUM_UNITS = 4,
	parameter LOG_NUM_UNITS = 2) (
		
	input logic [LOG_NUM_UNITS - 1:0][7:0] RGBLayers,
	input logic [LOG_NUM_UNITS - 1:0] inputDRs,
	input logic [LOG_NUM_UNITS - 1:0][3:0] layerZIndexes,

	input logic [7:0] RGBBackground,
	
	output logic [7:0] RGBout
);
 
 


always_comb begin
	int smallestzIndex = 99;
	int indexOfLayerToDraw = -1;
	
	for (int i = 0; i < NUM_UNITS; i = i + 1) begin
		if (inputDRs[i]) begin
			if (layerZIndexes[i] < smallestzIndex) begin
				smallestzIndex = layerZIndexes[i];
				indexOfLayerToDraw = i;
			end
		end
	end
	
	RGBout = RGBBackground;
	if (indexOfLayerToDraw != -1) begin
		RGBout = RGBLayers[indexOfLayerToDraw];
	end
end


endmodule