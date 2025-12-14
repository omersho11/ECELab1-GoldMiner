module BackgroundMux #(
	parameter NUM_UNITS = 8,
	parameter LOG_NUM_UNITS = 3
)
(	
	input logic [NUM_UNITS - 1:0][7:0] data,
	input logic [LOG_NUM_UNITS - 1:0] sel,
	
	output logic [7:0] RGBout
);
 

always_comb begin
	RGBout = data[sel];
end


endmodule