// Recieves time in seconds and displays in mm:ss format

module FiveDigitNumberDisplay #(
	parameter logic [7:0] color = 8'hff
) (	
	input	logic	clk,
	input	logic	resetN,
	input logic enable,
	input logic	[10:0] topLeftX,
	input logic	[10:0] topLeftY,
	input logic	[10:0] pixelX,
	input logic	[10:0] pixelY,
	input logic [10:0] number,

	output logic drawingRequest, //output that the pixel should be dispalyed 
	output logic [7:0] RGBout
);

assign RGBout = color ; // this is a fixed color

logic [4:0][3:0] digits;
//logic [36:0] shift;
//logic [5:0] bitCnt;
//logic busy;
//logic [10:0] number_r;

assign digits[0] = (number / 10000) % 10;
assign digits[1] = (number / 1000) % 10;
assign digits[2] = (number / 100) % 10;
assign digits[3] = (number / 10) % 10;
assign digits[4] = (number / 1) % 10;




//always_ff @(posedge clk or negedge resetN) begin
//    if(!resetN) number_r <= 0;
//    else number_r <= number;
//end
//
//logic start;
//assign start = (number_r != number);
//
//always_ff @(posedge clk or negedge resetN) begin
//    if(!resetN) begin
//        busy   <= 0;
//        bitCnt <= 0;
//        shift  <= 0;
//    end else begin
//        if(start && !busy) begin
//            shift <= 0;
//            shift[10:0] <= number;
//            bitCnt <= 11;
//            busy <= 1;
//        end
//        else if(busy) begin
//            for(int i=0;i<5;i++) begin
//                if(shift[11 + i*4 +:4] >= 5)
//                    shift[11 + i*4 +:4] <= shift[11 + i*4 +:4] + 3;
//            end
//
//            shift <= shift << 1;
//            bitCnt <= bitCnt - 1;
//
//            if(bitCnt == 1) begin
//                busy <= 0;
//                for(int i=0;i<5;i++)
//                    digits[i] <= shift[11 + i*4 +:4];
//            end
//        end
//    end
//end

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