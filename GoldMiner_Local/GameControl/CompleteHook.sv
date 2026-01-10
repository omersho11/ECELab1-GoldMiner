module CompleteHook #(
	parameter OFFSET_X = 320,
	parameter OFFSET_Y = 96,
	parameter MIN_LENGTH = 100,
	parameter MAX_LENGTH = 600,
	parameter LINE_THICKNESS = 1,
	parameter LINE_COLOR = 8'hFE
) (
	input logic clk,
	input logic resetN,
	input logic enable,
	input logic startOfFrame,
	input logic sendHook,
	input logic collisionOccurred,
	input logic [8:0] extentionSpeed,
	input logic [8:0] rotationSpeed,
	input logic [10:0] pixelX,
	input logic [10:0] pixelY,

	
	output logic [10:0] hookPosX,
	output logic [10:0] hookPosY,
	output logic hookReturned,
	output logic hookDR,
	output logic [7:0] hookRGB
);

logic lineDR;

Hook #(
		.OFFSET_X(OFFSET_X),
		.OFFSET_Y(OFFSET_Y)
) hook (
    .clk(clk),
    .resetN(resetN),
    .enable(enable),
	 .startOfFrame(startOfFrame),
	 .sendHook(sendHook),
	 .forceReturn(collisionOccurred),
	 
	 .extentionSpeed(extentionSpeed),
	 .rotationSpeed(rotationSpeed),
	 
	 .x(hookPosX),
	 .y(hookPosY),
	 .hookReturnedPulse(hookReturned)

);

DrawLine lineDrawer (
	.pixelX(pixelX),
	.pixelY(pixelY),
	.x1(OFFSET_X),
	.y1(OFFSET_Y),
	.x2(hookPosX),
	.y2(hookPosY),
	.width(LINE_THICKNESS),
	.lineColor(LINE_COLOR),
	
	.lineDR(lineDR),
	.lineRGB(hookRGB),
);



	 	 


always_ff @(posedge clk or negedge resetN) begin
	if (!resetN)
		hookDR <= 0;
	else begin
		hookDR <= lineDR && enable;
	end
end
		 
endmodule