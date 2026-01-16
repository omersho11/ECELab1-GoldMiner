module ImageRom # (
	parameter logic [10:0] WIDTH = 64,
	parameter logic [10:0] HEIGHT = 64,
	parameter logic [10:0] TOP = 0,
	parameter logic [10:0] LEFT = 0,
	parameter logic [3:0] IMAGE_ID,
	parameter logic [3:0] SCALE = 0
) (
	input logic clk,
	input	logic	resetN,
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
	case (IMAGE_ID)
		BANNER_EXT_SPEED: $readmemh("Assets/extentionSpeedUpgradeIcon.hex", mem);
		BANNER_LUCK: $readmemh("Assets/playerLuckUpgradeIcon.hex", mem);
		BANNER_MULT: $readmemh("Assets/scoreMultiplierUpgradeIcon.hex", mem);
		BANNER_ROT_SPEED: $readmemh("Assets/rotationSpeedUpgradeIcon.hex", mem);
		KEY_1: $readmemh("Assets/key1.hex", mem);
		KEY_2: $readmemh("Assets/key2.hex", mem);
		KEY_3: $readmemh("Assets/key3.hex", mem);
		KEY_4: $readmemh("Assets/key4.hex", mem);
		
		default: $readmemh("Assets/extentionSpeedUpgradeIcon.hex", mem);
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
		
		if (isInBoundingBox_d) begin
			RGBout <= q;
			dr <= ((q == 8'hff) ? 0 : 1);
		end
	end
end



endmodule