module TextRom # (
	parameter logic [10:0] WIDTH = 64,
	parameter logic [10:0] HEIGHT = 64,
	parameter logic [10:0] TOP = 0,
	parameter logic [10:0] LEFT = 0,
	parameter logic [3:0] TEXT_ID,
	parameter logic [3:0] SCALE = 0
) (
	input logic clk,
	input	logic	resetN,
	input logic enable,
	input logic [10:0] pixelX,  
	input logic [10:0] pixelY,

	output logic [7:0] RGBout,     // The pixel color
	output logic dr
);
import GlobalsPKG::*;

logic isInBoundingBox;
logic [10:0] offsetX;
logic [10:0] offsetY;

localparam int FRAME_SIZE = WIDTH * HEIGHT;

square_object #(
	.OBJECT_WIDTH_X(WIDTH<<SCALE),
	.OBJECT_HEIGHT_Y(HEIGHT<<SCALE)
) squareObject (	
	.clk(clk),
	.resetN(resetN),
	.pixelX(pixelX),
	.pixelY(pixelY),
	.topLeftX(LEFT),
	.topLeftY(TOP),

	.offsetX(offsetX),
	.offsetY(offsetY),
	.drawingRequest(isInBoundingBox),
	.RGBout(0)
);

(* ramstyle = "M10K" *) logic [7:0] mem [0:FRAME_SIZE-1];

logic [15:0] address;

initial begin
	case (TEXT_ID)
		PLUS_TO_CONTINUE: $readmemh("Assets/MenuText/pressPlusToContinue.hex", mem);
		PLUS_TO_START: 	$readmemh("Assets/MenuText/pressPlusToStart.hex", mem);
		YOU_LOST: 		   $readmemh("Assets/MenuText/youLostTryAgain.hex", mem);
		FINAL_SCORE: 		$readmemh("Assets/MenuText/finalScoreText.hex", mem);
		
		default: $readmemh("Assets/MenuText/pressPlusToContinue.hex", mem);
	endcase	
end

always_comb begin
	address = 0;
	if (isInBoundingBox) begin
		address = ((offsetY>>SCALE)* WIDTH) + (offsetX>>SCALE);
	end
end


logic [7:0] q;
always_ff @(posedge clk) begin
	q <= mem[address];
end

logic isInBoundingBox_d;
always_ff @(posedge clk) begin
	isInBoundingBox_d <= isInBoundingBox;
end

always_ff @(posedge clk or negedge resetN) begin
	if (!resetN) begin
		RGBout <= 0;
		dr <= 0;
	end else begin
		RGBout <= 0;
		dr <= 0;
		
		if (enable && isInBoundingBox_d) begin
			RGBout <= q;
			dr <= ((q == 8'hff) ? 0 : 1);
		end
	end
end



endmodule