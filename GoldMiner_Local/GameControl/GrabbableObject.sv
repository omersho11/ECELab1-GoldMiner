module	GrabbableObject	(	
			input logic clk,
			input logic resetN,
			input logic manualReset,
			input logic [10:0] idleX,
			input logic [10:0] idleY,
			input logic [10:0] pixelX,
			input logic [10:0] pixelY,
			input logic [3:0] objectType,
			
			input logic [10:0] hookX,
			input logic [10:0] hookY,
			input logic isHooked,
			input logic hookReturned,
			
			output logic [10:0] value,
			output logic destroyed, 
			output logic [7:0] RGBout,
			output logic dr	
);
enum logic [2:0] {STATE_IDLE, STATE_GRABBED, STATE_DESTROYED} state;
typedef enum {FILLER, VALUABLE_1, VALUABLE_2, VALUABLE_3, ROCK_1} TYPES;
localparam OBJECT_WIDTH = 32;
localparam OBJECT_HEIGHT = 32;

localparam [7:0] TRANSPARENT_ENCODING = 8'hFF;
logic [10:0] bottomRightX, bottomRightY, offsetX, offsetY, topLeftX, topLeftY;
logic [3:0] objectTexture;


assign insideBoundingBox = ((pixelX  >= topLeftX) &&  (pixelX < bottomRightX) 
						   && (pixelY  >= topLeftY) &&  (pixelY < bottomRightY));
assign bottomRightX = (topLeftX + 11'(OBJECT_WIDTH));
assign bottomRightY = (topLeftY + 11'(OBJECT_HEIGHT));
assign offsetX = pixelX - topLeftX;
assign offsetY = pixelY - topLeftY;

assign destroyed = (state == STATE_DESTROYED || objectType == FILLER);
							
logic [TYPES.num()-1:0][OBJECT_WIDTH-1:0][OBJECT_HEIGHT-1:0][7:0] objectsBitmap;

const logic [3:0][10:0] VALUE_TABLE = {11'd0,11'd10,11'd100,11'd1000,11'd1}; 

assign objectsBitmap = '{
    // Index 0: FILLER - All transparent/zero
    default: '0,

    1: '{
        {8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
        {8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
        {8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
        {8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
        {8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
        {8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
        {8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hb4,8'hb4,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
        {8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hb4,8'hfc,8'hfc,8'h8c,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
        {8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'h8c,8'hfc,8'hfc,8'hfc,8'hfc,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
        {8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hd4,8'hfc,8'hfc,8'hfc,8'hfc,8'h8c,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
        {8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'h8c,8'h8c,8'hff,8'hff,8'hff,8'hff,8'hd4,8'hf8,8'hf8,8'hf8,8'hfc,8'h90,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
        {8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'h8c,8'hfc,8'hfc,8'hf8,8'h8c,8'hff,8'hff,8'hb0,8'hfc,8'hfc,8'hfc,8'hd4,8'h90,8'hff,8'hff,8'h8c,8'hf8,8'hf8,8'h8c,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
        {8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'h8c,8'hfc,8'hfc,8'hfc,8'hf8,8'h8c,8'h64,8'hf8,8'hfc,8'hfd,8'hfc,8'hd4,8'hb0,8'hff,8'h8c,8'hf8,8'hfc,8'hfc,8'h8c,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
        {8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'h8c,8'hfc,8'hf8,8'hfc,8'hfc,8'hd4,8'h64,8'hf8,8'hf8,8'hfc,8'hd4,8'hb0,8'h8c,8'h64,8'hf8,8'hfc,8'hfc,8'hf8,8'h8c,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
        {8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'h6c,8'hfc,8'hfc,8'hfc,8'hfc,8'hf8,8'hd4,8'hd4,8'hd4,8'hf8,8'hb0,8'hb0,8'h8c,8'hf8,8'hfc,8'hfc,8'hfc,8'hf8,8'h8c,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
        {8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'h8c,8'hf8,8'hfc,8'hfc,8'hb0,8'hb4,8'hb4,8'hf8,8'hf8,8'hb0,8'h8c,8'hb0,8'hf8,8'hf8,8'hfc,8'hf8,8'hb0,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
        {8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'h64,8'hb0,8'hb0,8'hf8,8'hb0,8'hfc,8'hfc,8'hf8,8'hb0,8'h8c,8'h8c,8'hd4,8'hf8,8'hf8,8'hd4,8'hd4,8'h64,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
        {8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hb0,8'hb0,8'hb4,8'hb0,8'hfc,8'hfc,8'hfc,8'hf8,8'h8c,8'hd4,8'hf8,8'hfc,8'hf8,8'hb0,8'h6c,8'h64,8'h64,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
        {8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'h64,8'h64,8'hd4,8'hb4,8'h8c,8'hfc,8'hfc,8'hfc,8'hf8,8'hb0,8'hd4,8'hd4,8'hf8,8'hd4,8'hd4,8'h8c,8'h90,8'h64,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
        {8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'h64,8'h90,8'h6c,8'h90,8'h8c,8'hf8,8'hf8,8'hd4,8'hb0,8'h90,8'h90,8'hf8,8'hf8,8'h8c,8'h90,8'h90,8'h8c,8'h64,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
        {8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'h64,8'h8c,8'h8c,8'h90,8'h6c,8'hf8,8'hf8,8'hd4,8'hb0,8'hb0,8'hfc,8'hfc,8'hfc,8'h8c,8'h8c,8'h8c,8'hb0,8'hb0,8'h8c,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
        {8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hb4,8'hfc,8'hfc,8'h8c,8'h8c,8'h90,8'hf8,8'hd4,8'hb0,8'hfc,8'hfc,8'hf8,8'hf8,8'h6c,8'h8c,8'hfc,8'hf8,8'hfc,8'h8c,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
        {8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hb4,8'hf8,8'hfc,8'hf8,8'h8c,8'h8c,8'h90,8'hd4,8'hd4,8'hfc,8'hd4,8'hd4,8'h8c,8'h90,8'hd4,8'hfc,8'hf8,8'h8c,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
        {8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'h8c,8'hfc,8'hfc,8'hf8,8'h8c,8'hfc,8'hfc,8'hb0,8'hd4,8'hd4,8'hd4,8'hb0,8'h8c,8'hb4,8'hb0,8'h90,8'h90,8'h64,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
        {8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'h64,8'h6c,8'hb0,8'h90,8'hd4,8'hf8,8'hfc,8'hf8,8'hb0,8'hb0,8'hb0,8'h8c,8'h90,8'hb4,8'h8c,8'h64,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
        {8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'h64,8'hb0,8'h90,8'h8c,8'hfc,8'hfc,8'hf8,8'hb0,8'h90,8'h8c,8'h90,8'hb4,8'h64,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
        {8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'h64,8'h90,8'h90,8'h6c,8'hd4,8'hd4,8'h8c,8'h6c,8'h6c,8'h64,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
        {8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'h64,8'h64,8'h64,8'h64,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
        {8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
        {8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
        {8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
        {8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff}
    },

    4: '{
        {8'h71,8'h71,8'h71,8'h71,8'h71,8'h71,8'h71,8'h71,8'h71,8'h71,8'h71,8'h71,8'h71,8'h71,8'h71,8'h24,8'h24,8'h24,8'h71,8'h71,8'h71,8'h71,8'h71,8'h71,8'h71,8'h71,8'h71,8'h71,8'h71,8'h71,8'h71,8'h71},
        {8'h71,8'h71,8'h71,8'h71,8'h71,8'h71,8'h71,8'h71,8'h71,8'h71,8'h71,8'h71,8'h71,8'h24,8'h24,8'hb6,8'hda,8'hb6,8'h24,8'h71,8'h71,8'h71,8'h71,8'h71,8'h71,8'h71,8'h71,8'h71,8'h71,8'h71,8'h71,8'h71},
        {8'h71,8'h71,8'h71,8'h71,8'h71,8'h71,8'h71,8'h71,8'h71,8'h71,8'h71,8'h71,8'h24,8'hb6,8'hda,8'hda,8'hda,8'hda,8'hb6,8'h24,8'h71,8'h71,8'h71,8'h71,8'h71,8'h71,8'h71,8'h71,8'h71,8'h71,8'h71,8'h71},
        {8'h71,8'h71,8'h71,8'h71,8'h71,8'h71,8'h71,8'h71,8'h71,8'h24,8'h24,8'hb6,8'hda,8'hda,8'hda,8'hda,8'hda,8'hda,8'hda,8'h6d,8'h24,8'h71,8'h71,8'h71,8'h71,8'h71,8'h71,8'h71,8'h71,8'h71,8'h71,8'h71},
        {8'h71,8'h71,8'h71,8'h71,8'h71,8'h71,8'h71,8'h91,8'hb6,8'hb6,8'hda,8'hda,8'hda,8'hda,8'hda,8'hda,8'hda,8'hda,8'hda,8'h91,8'h91,8'h24,8'h71,8'h71,8'h71,8'h71,8'h71,8'h71,8'h71,8'h71,8'h71,8'h71},
        {8'h71,8'h71,8'h71,8'h71,8'h71,8'h71,8'h24,8'hda,8'hda,8'hda,8'hda,8'hda,8'hda,8'hda,8'hda,8'hda,8'hda,8'hda,8'h91,8'h91,8'h91,8'h6d,8'h71,8'h71,8'h71,8'h71,8'h71,8'h71,8'h71,8'h71,8'h71,8'h71},
        {8'h71,8'h71,8'h71,8'h71,8'h71,8'h24,8'hda,8'hda,8'hda,8'hda,8'hda,8'hda,8'hda,8'hda,8'hda,8'hda,8'hda,8'hda,8'h6d,8'h91,8'h91,8'h91,8'h24,8'h71,8'h71,8'h71,8'h71,8'h71,8'h71,8'h71,8'h71,8'h71},
        {8'h71,8'h71,8'h71,8'h71,8'h71,8'hb6,8'hda,8'hda,8'hda,8'hda,8'hda,8'hda,8'hda,8'hda,8'hda,8'hda,8'hda,8'hda,8'h91,8'h6d,8'hb6,8'hb6,8'h24,8'h24,8'h71,8'h71,8'h71,8'h71,8'h71,8'h71,8'h71,8'h71},
        {8'h71,8'h71,8'h71,8'h71,8'h71,8'h91,8'hda,8'hda,8'hda,8'hda,8'h6d,8'h91,8'hda,8'hda,8'hda,8'hda,8'hda,8'hb6,8'h6d,8'h6d,8'hda,8'hda,8'hda,8'h24,8'h71,8'h71,8'h71,8'h71,8'h71,8'h71,8'h71,8'h71},
        {8'h71,8'h71,8'h71,8'h71,8'h71,8'h24,8'hda,8'hda,8'hda,8'hda,8'hda,8'hda,8'hda,8'hda,8'hda,8'hb6,8'h6d,8'h91,8'h6d,8'h91,8'hda,8'hda,8'hda,8'hda,8'h24,8'h71,8'h71,8'h71,8'h71,8'h71,8'h71,8'h71},
        {8'h71,8'h71,8'h71,8'h71,8'h71,8'h91,8'h91,8'hda,8'hda,8'hda,8'hda,8'hda,8'hda,8'hda,8'hda,8'h91,8'h91,8'h6d,8'h6d,8'hda,8'hda,8'hda,8'hda,8'hda,8'hda,8'h6d,8'h24,8'h71,8'h71,8'h71,8'h71,8'h71},
        {8'h71,8'h71,8'h71,8'h71,8'h24,8'h91,8'h6d,8'hda,8'hda,8'hda,8'hda,8'hda,8'hda,8'hda,8'hda,8'h6d,8'h6d,8'h6d,8'h91,8'hda,8'hda,8'hda,8'hda,8'hda,8'hda,8'hda,8'hb6,8'h24,8'h71,8'h71,8'h71,8'h71},
        {8'h71,8'h71,8'h71,8'h71,8'h24,8'h91,8'h24,8'hda,8'hda,8'hda,8'hda,8'hda,8'hda,8'hda,8'hda,8'hb6,8'h6d,8'h6d,8'h91,8'hda,8'hda,8'hda,8'hda,8'hda,8'hda,8'hda,8'hda,8'h91,8'h24,8'h71,8'h71,8'h71},
        {8'h71,8'h71,8'h71,8'h24,8'h91,8'h91,8'h6d,8'hb6,8'hda,8'hda,8'hda,8'hda,8'hda,8'hda,8'hda,8'hda,8'h91,8'h6d,8'hda,8'hda,8'hda,8'hda,8'hda,8'hda,8'hda,8'hda,8'hb6,8'h91,8'h24,8'h71,8'h71,8'h71},
        {8'h71,8'h71,8'h71,8'h91,8'h91,8'h91,8'h6d,8'hb6,8'hda,8'hda,8'hda,8'hda,8'hda,8'hda,8'hda,8'hda,8'h6d,8'h91,8'hda,8'hda,8'hda,8'hda,8'hda,8'hda,8'hda,8'hda,8'hb6,8'h91,8'h91,8'h24,8'h71,8'h71},
        {8'h71,8'h71,8'h71,8'h91,8'h91,8'h91,8'h6d,8'h91,8'hb6,8'hb6,8'hda,8'hda,8'hda,8'hda,8'hda,8'h91,8'hda,8'h91,8'h6d,8'hb6,8'hda,8'hda,8'hda,8'hda,8'hda,8'hda,8'hda,8'h6d,8'h91,8'h24,8'h71,8'h71},
        {8'h71,8'h71,8'h24,8'h91,8'h91,8'h91,8'h6d,8'h91,8'h91,8'h91,8'hb6,8'hda,8'hda,8'hda,8'hda,8'h91,8'hda,8'hda,8'hda,8'hb6,8'h6d,8'h91,8'hb6,8'hda,8'hda,8'hda,8'hda,8'hda,8'h91,8'h6d,8'h71,8'h71},
        {8'h71,8'h71,8'h24,8'h91,8'h91,8'h6d,8'h6d,8'h91,8'h91,8'h91,8'h91,8'h91,8'hda,8'hda,8'h91,8'hda,8'hda,8'hda,8'hda,8'hda,8'hda,8'h91,8'h6d,8'h91,8'hb6,8'hb6,8'hda,8'hda,8'hb6,8'h91,8'h24,8'h71},
        {8'h71,8'h71,8'h24,8'h91,8'h91,8'h6d,8'h6d,8'h91,8'h91,8'h6d,8'h91,8'h91,8'h91,8'hb6,8'hb6,8'hda,8'hda,8'hda,8'hda,8'hda,8'hda,8'hda,8'h91,8'h6d,8'h6d,8'h91,8'hb6,8'hb6,8'hb6,8'h91,8'h24,8'h71},
        {8'h71,8'h71,8'h24,8'h6d,8'h6d,8'hb6,8'hda,8'hda,8'hda,8'hda,8'h6d,8'h91,8'h91,8'h6d,8'hda,8'hda,8'hda,8'hda,8'hda,8'hda,8'hda,8'hda,8'h91,8'h91,8'h6d,8'h6d,8'h91,8'hb6,8'hb6,8'h91,8'h6d,8'h71},
        {8'h71,8'h71,8'h91,8'hb6,8'hda,8'hda,8'hda,8'hda,8'hda,8'hda,8'hb6,8'h91,8'h91,8'h6d,8'hda,8'hda,8'hda,8'hda,8'hda,8'hda,8'h91,8'h91,8'h91,8'h91,8'h6d,8'h6d,8'h6d,8'h91,8'h91,8'h91,8'h6d,8'h71},
        {8'h71,8'h91,8'hda,8'hda,8'hda,8'hda,8'hda,8'hda,8'hb6,8'h91,8'hb6,8'hb6,8'h6d,8'h6d,8'h91,8'hda,8'hda,8'hda,8'hda,8'hb6,8'h91,8'h91,8'h91,8'h91,8'h91,8'h6d,8'h6d,8'h6d,8'h91,8'h91,8'h6d,8'h24},
        {8'h24,8'hb6,8'h91,8'hb6,8'hda,8'hda,8'hda,8'hda,8'hda,8'hb6,8'hb6,8'hb6,8'h91,8'h91,8'h91,8'hda,8'hda,8'h6d,8'h91,8'h6d,8'h91,8'h91,8'h91,8'h91,8'h91,8'h91,8'h91,8'h6d,8'h6d,8'h91,8'h6d,8'h24},
        {8'h91,8'hb6,8'hb6,8'hb6,8'hda,8'hda,8'hda,8'hb6,8'hb6,8'hb6,8'hb6,8'hb6,8'hb6,8'h91,8'h6d,8'hda,8'hb6,8'hb6,8'hb6,8'h6d,8'h91,8'h91,8'h91,8'h91,8'h91,8'h91,8'h91,8'h6d,8'h6d,8'h91,8'h6d,8'h6d},
        {8'h91,8'hb6,8'hb6,8'hb6,8'hb6,8'hb6,8'hb6,8'hb6,8'hb6,8'hb6,8'hb6,8'hb6,8'hb6,8'h91,8'h6d,8'h91,8'hb6,8'hb6,8'hb6,8'h6d,8'h91,8'h91,8'h91,8'h91,8'h91,8'h91,8'h91,8'h91,8'h6d,8'h91,8'h6d,8'h91},
        {8'h24,8'hb6,8'hb6,8'hb6,8'hb6,8'hb6,8'h6d,8'h6d,8'h6d,8'h6d,8'h91,8'h91,8'h91,8'h91,8'h6d,8'h6d,8'hb6,8'hb6,8'hb6,8'hb6,8'h91,8'h91,8'h91,8'h91,8'h91,8'h91,8'h91,8'h91,8'h91,8'h91,8'h6d,8'h24},
        {8'h71,8'h91,8'hb6,8'hb6,8'hb6,8'hb6,8'hb6,8'hb6,8'hb6,8'hb6,8'hb6,8'h6d,8'h91,8'h91,8'h6d,8'h6d,8'hb6,8'hb6,8'hb6,8'hb6,8'h91,8'h91,8'h91,8'h91,8'h91,8'h91,8'h91,8'h91,8'h91,8'h6d,8'h6d,8'h24},
        {8'h71,8'h6d,8'hb6,8'hb6,8'hb6,8'hb6,8'hb6,8'hb6,8'hb6,8'hb6,8'hb6,8'hb6,8'h91,8'h91,8'h6d,8'h6d,8'hb6,8'hb6,8'hb6,8'hb6,8'hb6,8'h91,8'h91,8'h91,8'h91,8'h91,8'h91,8'h91,8'h91,8'h6d,8'h24,8'h71},
        {8'h71,8'h24,8'h91,8'h91,8'h91,8'h91,8'hb6,8'hb6,8'hb6,8'hb6,8'hb6,8'hb6,8'h6d,8'h6d,8'h6d,8'h6d,8'hb6,8'hb6,8'hb6,8'hb6,8'hb6,8'h91,8'h91,8'h91,8'h91,8'h91,8'h91,8'h91,8'h6d,8'h6d,8'h24,8'h71},
        {8'h71,8'h71,8'h24,8'h24,8'h6d,8'h6d,8'h6d,8'h91,8'h91,8'h91,8'h91,8'h91,8'h91,8'h6d,8'h6d,8'h6d,8'hb6,8'hb6,8'hb6,8'hb6,8'hb6,8'h91,8'h91,8'h91,8'h91,8'h6d,8'h6d,8'h6d,8'h6d,8'h24,8'h71,8'h71},
        {8'h71,8'h71,8'h71,8'h71,8'h71,8'h71,8'h71,8'h24,8'h24,8'h24,8'h24,8'h6d,8'h6d,8'h6d,8'h6d,8'h6d,8'h91,8'h91,8'h91,8'h91,8'hb6,8'h6d,8'h6d,8'h6d,8'h6d,8'h6d,8'h24,8'h24,8'h24,8'h71,8'h71,8'h71},
        {8'h71,8'h71,8'h71,8'h71,8'h71,8'h71,8'h71,8'h71,8'h71,8'h71,8'h71,8'h71,8'h71,8'h71,8'h71,8'h71,8'h71,8'h71,8'h71,8'h71,8'h24,8'h24,8'h24,8'h24,8'h24,8'h71,8'h71,8'h71,8'h71,8'h71,8'h71,8'h71}
    }
};



always_comb begin
	case(state)
		STATE_GRABBED: begin
			topLeftX = hookX - 16;
			topLeftY = hookY - 16;
		end
		STATE_DESTROYED: begin
			topLeftX = 700;
			topLeftY = 700;
		end
		default: begin // STATE_IDLE
			topLeftX = idleX;
			topLeftY = idleY;
		end
	endcase
end


always_ff@(posedge clk or negedge resetN) begin
	if(!resetN) begin  
		state <= STATE_IDLE;
		value <= 0;

	end else if (manualReset) begin 
		state <= STATE_IDLE;
		value <= 0;

	end
	else begin
		case(state)
			STATE_IDLE: begin
				objectTexture <= objectType;
				if (isHooked) state <= STATE_GRABBED;
			end
			STATE_GRABBED: begin
				if (hookReturned) begin
					state <= STATE_DESTROYED;
					value <= VALUE_TABLE[objectType];
				end
			end
			STATE_DESTROYED: begin
				value <= 0;
				objectTexture <= FILLER;
			end
			default: begin
				state <= STATE_IDLE;
			end
		endcase
	end
end


always_comb begin
	dr = 0;
	RGBout = TRANSPARENT_ENCODING;
	if(insideBoundingBox && objectType != FILLER) begin
		logic [7:0] pixelColor;
		pixelColor = objectsBitmap[objectTexture][OBJECT_HEIGHT - 1 - offsetY][OBJECT_WIDTH - 1 - offsetX];
		if (pixelColor != TRANSPARENT_ENCODING) begin
			dr = 1;
			RGBout = pixelColor;
		end
		
	end
end
endmodule