module AnimationRom # (
	parameter logic [5:0] WIDTH = 18,
	parameter logic [5:0] HEIGHT = 32,
	parameter logic [10:0] TOP = 0,
	parameter logic [10:0] LEFT = 0,
	parameter logic [4:0] ANIMATION_LENGTH = 1,
	parameter logic [3:0] POTION_ID,
	parameter logic [3:0] ANIMATION_SLOWDOWN_RATE = 4,
	parameter logic [3:0] SCALE = 0
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

square_object #(
	.OBJECT_WIDTH_X({4'b0, WIDTH}<<SCALE),
	.OBJECT_HEIGHT_Y({4'b0, HEIGHT}<<SCALE)
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

(* ramstyle = "M10K" *) logic [7:0] mem [0:16383];

logic [4:0] animationIndex = 0;
logic [15:0] address;
logic [3:0] animationFrameDurationCounter;

initial begin
	case (POTION_ID)
		0: $readmemh("Assets/potion0.hex", mem);
		1: $readmemh("Assets/potion1.hex", mem);
		2: $readmemh("Assets/potion2.hex", mem);
		3: $readmemh("Assets/potion3.hex", mem);
		default: $readmemh("Assets/potion0.hex", mem);
	endcase	
end

always_comb begin
	address = 0;

	if (isInBoundingBox) begin
		address = (animationIndex * FRAME_SIZE) + ((offsetY>>SCALE)* WIDTH) + (offsetX>>SCALE);
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