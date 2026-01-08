package GlobalsPKG;
	// --- Level Elements ---
	typedef enum logic [2:0] {
		FILLER      = 3'd0,
		VALUABLE_1  = 3'd1,
		VALUABLE_2  = 3'd2,
		VALUABLE_3  = 3'd3,
		ROCK_1      = 3'd4
	} LEVEL_ELEMENTS; 

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

	// --- Constants ---
	parameter int MAX_OBJECTS = 20;
	parameter logic [5:0] MAX_LEVEL = 10;
	parameter logic [7:0] MIN_LEVEL_TIME = 20;
	parameter logic [7:0] EXTRA_TIME_PER_LEVEL = 10;
	
endpackage