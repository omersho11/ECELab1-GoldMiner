package GlobalsPKG;
   // Define your object types here
	typedef enum logic [2:0] {
		FILLER      = 3'd0,
		VALUABLE_1  = 3'd1,
		VALUABLE_2  = 3'd2,
		VALUABLE_3  = 3'd3,
		ROCK_1      = 3'd4
	} LEVEL_ELEMENTS; 

	typedef struct packed {
		LEVEL_ELEMENTS elementType;
		logic [8:0] index;
	} GRABBABLE_OBJECT_METADATA;
	
	
	// You can also define level parameters here
	parameter int MAX_OBJECTS = 20;
	parameter int GRID_ROWS = 15;
	parameter int GRID_COLS = 20;
endpackage