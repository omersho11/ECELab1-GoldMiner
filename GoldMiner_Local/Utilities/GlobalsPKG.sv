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
		logic [4:0] row;
		logic [5:0] col;
	} GRABBABLE_OBJECT_METADATA;
	
	
	// You can also define level parameters here
	parameter int MAX_OBJECTS = 20;
   parameter logic [5:0] MAX_LEVEL = 10;
	parameter logic [7:0] MIN_LEVEL_TIME = 20;
	parameter logic [7:0] EXTRA_TIME_PER_LEVEL = 10;
endpackage