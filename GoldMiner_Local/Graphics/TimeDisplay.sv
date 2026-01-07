// Recieves time in seconds and displays in mm:ss format

module TimeDisplay #(
	parameter logic [7:0] color = 8'hff
) (	
	input	logic	clk,
	input	logic	resetN,
	input logic enable,
	input logic	[10:0] topLeftX,
	input logic	[10:0] topLeftY,
	input logic	[10:0] pixelX,
	input logic	[10:0] pixelY,
	input logic [10:0] timeInSeconds,

	output logic drawingRequest, //output that the pixel should be dispalyed 
	output logic [7:0] RGBout
);

assign RGBout = color ; // this is a fixed color

logic [4:0] [3:0] digits; // 01:23
assign digits[0] = (timeInSeconds / 60) / 10;   // tens of minutes
assign digits[1] = (timeInSeconds / 60) % 10;   // ones of minutes
assign digits[2] = 10; // ':'
assign digits[3] = (timeInSeconds % 60) / 10;   // tens of seconds
assign digits[4] = (timeInSeconds % 60) % 10;   // ones of seconds

FiveDigitDisplay display (
	.clk(clk),
	.resetN(resetN),
	.enable(enable),
	.topLeftX(topLeftX),
	.topLeftY(topLeftY),
	.pixelX(pixelX),
	.pixelY(pixelY),
	.digits(digits),

	.drawingRequest(drawingRequest),
);

endmodule