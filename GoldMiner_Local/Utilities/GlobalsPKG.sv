package GlobalsPKG;
	// --- Level Elements ---
	typedef enum logic [2:0] {
		FILLER      = 3'd0,
		VALUABLE_1  = 3'd1,
		VALUABLE_2  = 3'd2,
		VALUABLE_3  = 3'd3,
		ROCK_1      = 3'd4
	} LEVEL_ELEMENTS; 
	
	const logic [4:0][10:0] VALUE_TABLE = '{
    FILLER      		: 11'd0,   
    VALUABLE_1       : 11'd2,   
    VALUABLE_2       : 11'd5,   
    VALUABLE_3     	: 11'd10,  
    ROCK_1 				: 11'd1,   
    default     		: 11'd0    // Safety catch-all
};

	
	typedef enum logic [3:0] {
		BANNER_EXT_SPEED = 4'd0,
		BANNER_LUCK      = 4'd1,
		BANNER_MULT      = 4'd2,
		BANNER_ROT_SPEED = 4'd3,
		KEY_1 			  = 4'd4,
		KEY_2				  = 4'd5,
		KEY_3				  = 4'd6,
		KEY_4 			  = 4'd7,
		TEXT_SCORE       = 4'd8,
		TEXT_MONEY       = 4'd9,
		TEXT_COST        = 4'd10
		
	} IMAGE_IDS;
	
	typedef enum logic [3:0] {
		PLUS_TO_CONTINUE = 4'd0,
		PLUS_TO_START    = 4'd1,
		YOU_LOST         = 4'd2,
		FINAL_SCORE		  = 4'd3
	} TEXT_IDS;

	typedef struct packed {
		LEVEL_ELEMENTS elementType;
		logic [4:0] row;
		logic [5:0] col;
	} GRABBABLE_OBJECT_METADATA;
	
	// --- Economy & Stats Types ---
	typedef logic [19:0] MONEY;
	typedef logic [19:0] SCORE;
	
	typedef logic [8:0]  SPEED_T;      // 9 bits for hook movement
	typedef logic [3:0]  LUCK_T;       // 4 bits for luck stat
	typedef logic [19:0] MULTIPLIER_T; // 20 bits for score multiplier
	
	// --- Shop Types ---
	typedef enum logic [2:0] {
		ITEM_NONE          = 3'd0,
		ITEM_EXT_SPEED     = 3'd1,
		ITEM_LUCK          = 3'd2,
		ITEM_MULTIPLIER    = 3'd3,
		ITEM_ROT_SPEED     = 3'd4
	} SHOP_ITEM_T;
	
	typedef enum logic [9:0] {
		EXTENSION_SPEED_KEY  = 10'b0000000010,
		LUCK_KEY 				= 10'b0000000100,
		MULTIPLIER_KEY 		= 10'b0000001000,
		ROTATION_SPEED_KEY 	= 10'b0000010000
	} SHOP_KEYBINDS;
	// --- Common Types ---
	typedef logic [7:0] RGB_T;
	typedef logic [10:0] PIXEL_T;
	// --- Constants ---
	parameter int MAX_OBJECTS = 20;
	parameter logic [5:0] MAX_LEVEL = 10;
	parameter logic [7:0] MIN_LEVEL_TIME = 20;
	parameter logic [7:0] EXTRA_TIME_PER_LEVEL = 10;
	parameter RGB_T MONEY_TEXT_COLOR = 8'b000_100_01; // Green
	parameter RGB_T SCORE_TEXT_COLOR = 8'b111_111_10; // Almost white
	
endpackage