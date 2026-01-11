module FiveDigitNumberDisplay # (
	parameter logic [7:0] color = 8'hff
) (	
	input	logic	clk,
	input	logic	resetN,
	input logic enable,
	input logic	[10:0] topLeftX,
	input logic	[10:0] topLeftY,
	input logic	[10:0] pixelX,
	input logic	[10:0] pixelY,
	input logic [19:0] number,

	output logic drawingRequest, //output that the pixel should be dispalyed 
	output logic [7:0] RGBout
);

assign RGBout = color ; // this is a fixed color

logic [4:0][3:0] digits;

assign digits[0] = (number / 10000) % 10;
assign digits[1] = (number / 1000) % 10;
assign digits[2] = (number / 100) % 10;
assign digits[3] = (number / 10) % 10;
assign digits[4] = (number / 1) % 10;

FiveDigitDisplay display (
    .clk(clk),
    .resetN(resetN),
    .enable(enable),
    .topLeftX(topLeftX),
    .topLeftY(topLeftY),
    .pixelX(pixelX),
    .pixelY(pixelY),
    .digits(digits),
    .drawingRequest(drawingRequest)
);

endmodule