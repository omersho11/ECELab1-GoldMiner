module	GrabbableObject	(	
			input logic [10:0] topLeftX,
			input logic [10:0] topLeftY,
			input logic [10:0] pixelX,
			input logic [10:0] pixelY,
			input logic [3:0] objectType,
			
			output logic [7:0] RGBout,
			output logic dr									
);
typedef enum {FILLER, VALUABLE_1, VALUABLE_2, VALUABLE_3, ROCK_1} TYPES;
localparam OBJECT_WIDTH = 32;
localparam OBJECT_HEIGHT = 32;

localparam [7:0] TRANSPARENT_ENCODING = 8'hFF;
logic [10:0] bottomRightX, bottomRightY, offsetX, offsetY;

assign bottomRightX = (topLeftX + 11'(OBJECT_WIDTH));
assign bottomRightY = (topLeftY + 11'(OBJECT_HEIGHT));
assign insideBoundingBox = ((pixelX  >= topLeftX) &&  (pixelX < bottomRightX) 
						   && (pixelY  >= topLeftY) &&  (pixelY < bottomRightY));

assign offsetX = pixelX - topLeftX;
assign offsetY = pixelY - topLeftY;
							
logic [TYPES.num()-1:0][OBJECT_WIDTH-1:0][OBJECT_HEIGHT-1:0][7:0] objectsBitmap;

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
	dr = 0;
	RGBout = TRANSPARENT_ENCODING;
	if(insideBoundingBox && objectType != FILLER) begin
		logic [7:0] pixelColor;
		pixelColor = objectsBitmap[objectType][offsetY][offsetX];
		if (pixelColor != TRANSPARENT_ENCODING) begin
			dr = 1;
			RGBout = pixelColor;
		end
		
	end
end
endmodule