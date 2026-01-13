module AnimationRom # (
	parameter logic [5:0] WIDTH = 18,
	parameter logic [5:0] HEIGHT = 32,
	parameter logic [10:0] TOP = 0,
	parameter logic [10:0] LEFT = 0,
	parameter logic [4:0] ANIMATION_LENGTH = 1,
	parameter logic [3:0] POTION_ID,
	parameter logic [3:0] ANIMATION_SLOWDOWN_RATE = 4
) (
	input logic clk,
	input	logic	resetN,
	input logic [10:0] pixelX,  
	input logic [10:0] pixelY,  
	input logic startOfFrame,

	output logic [7:0] RGBout,     // The pixel color
	output logic dr
);

logic isInBoundingBox;
logic [10:0] offsetX;
logic [10:0] offsetY;

localparam int FRAME_SIZE = WIDTH * HEIGHT;
localparam int DEPTH_RAW = WIDTH*HEIGHT*ANIMATION_LENGTH;
localparam int DEPTH = 1 << $clog2(DEPTH_RAW); // rounds up power of two
(* ramstyle = "M10K" *) logic [7:0] mem [0:16383];

logic [4:0] animationIndex = 0;
logic [15:0] address;
logic [3:0] animationFrameDurationCounter;

initial begin
	case (POTION_ID)
		0: begin
				$readmemh("Bitmaps/potion0.hex", mem);
			end
		1: begin
				$readmemh("Bitmaps/potion1.hex", mem);
			end
		2: begin
				$readmemh("Bitmaps/potion2.hex", mem);
			end
		3: begin
				$readmemh("Bitmaps/potion3.hex", mem);
			end
		default: begin
				$readmemh("Bitmaps/potion0.hex", mem);
			end
	endcase	
end

always_comb begin
	address = 0;

	if (isInBoundingBox) begin
		address = (animationIndex * FRAME_SIZE) + (offsetY * WIDTH) + offsetX;
	end
end


always_ff @(posedge clk or negedge resetN) begin
	if (!resetN) begin
		animationIndex <= 0;
	end else begin
		if (startOfFrame) begin
			if (animationFrameDurationCounter >= ANIMATION_SLOWDOWN_RATE) begin
				animationIndex <= ((animationIndex == ANIMATION_LENGTH - 1) ? 0 : animationIndex + 1);
				animationFrameDurationCounter <= 0;
			end else
				animationFrameDurationCounter <= animationFrameDurationCounter + 1;
		end
	end
end

logic [7:0] q;
always_ff @(posedge clk) begin
  q <= mem[address];
end

always_ff @(posedge clk or negedge resetN) begin
	if (!resetN) begin
		RGBout <= 0;
		dr <= 0;
	end else begin
		RGBout <= 0;
		dr <= 0;
		
		if (isInBoundingBox) begin
			RGBout <= q;
			dr <= ((q == 8'hff) ? 0 : 1);
		end
	end
end

square_object #(
	.OBJECT_WIDTH_X(WIDTH),
	.OBJECT_HEIGHT_Y(HEIGHT)
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

endmodule