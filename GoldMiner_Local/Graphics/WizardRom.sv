module WizardROM #(
    parameter [10:0] WIDTH = 64,
    parameter [10:0] HEIGHT = 64,
    parameter [3:0] SCALE = 0,
	 parameter logic [4:0] ANIMATION_LENGTH = 2,
	 parameter logic [10:0] TOP = 32,
	 parameter logic [10:0] LEFT = 288,
	 parameter logic [3:0] ANIMATION_SLOWDOWN_RATE = 15
) (
    input logic clk,
	 input logic resetN,
    input logic [10:0] pixelX,
    input logic [10:0] pixelY,
    input logic [2:0] frameIndex, // 0-3
	 input logic startOfFrame,
	 input logic isCasting,

    
    output logic [7:0] RGBout,
    output logic dr
);

import GlobalsPKG::*;
logic isInBoundingBox;
logic [10:0] offsetX;
logic [10:0] offsetY;

localparam int FRAME_SIZE = WIDTH * HEIGHT;
localparam int DEPTH_RAW = WIDTH*HEIGHT*ANIMATION_LENGTH;
localparam int DEPTH = 1 << $clog2(DEPTH_RAW);
 
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
initial $readmemh("Assets/wizard/wizardAnimations.hex", mem);

logic [4:0] animationIndex = 0;
logic [4:0] realAnimationIndex = 0;
logic [15:0] address;
logic [3:0] animationFrameDurationCounter;
	
always_comb begin
	address = 0;
	realAnimationIndex = animationIndex + ((isCasting == 1) ? ANIMATION_LENGTH : 0);

	if (isInBoundingBox) begin
		address = (realAnimationIndex * FRAME_SIZE) + ((offsetY>>SCALE)* WIDTH) + (offsetX>>SCALE);
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