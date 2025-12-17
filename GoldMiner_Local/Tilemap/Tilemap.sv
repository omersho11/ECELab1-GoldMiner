module Tilemap (
	input logic [10:0] x,
	input logic [10:0] y,
	input logic [3:0] stageID,

	output logic [18:0] MIFAddress
);


//each tile is 32x32, therefore the jump between two tiles has a 1024 offset

localparam int NUM_OF_TILES_WIDTH = 20;
localparam int NUM_OF_TILES_HEIGHT = 15;

logic [5:0] xIndex, yIndex;
logic [4:0] deltaX, deltaY;
logic [9:0] currentTileID;
logic [9:0] tempX,tempY;


// 3D array: [stageID][Rows][Columns]
// Flattened size: 16 stages * 15 rows * 20 columns = 4800 entries
(* ramstyle = "M9K" *) logic [8:0] tilemaps [0:4799];

initial begin
    $readmemh("Stages/all_stages.txt", tilemaps);
end

always_comb begin
	// The msb of the coordinates, same as >>32
	xIndex = x[10:5];
	yIndex = y[10:5];
	// The lsb of the coordinates, same as mod 32
	deltaX = x[4:0];
	deltaY = y[4:0];

	// Manually calculate the 1D index: (Stage * RowsPerStage * ColsPerRow) + (Y * ColsPerRow) + X
	// (stageID * 15 * 20) + (yIndex * 20) + xIndex
	// Simplified: (stageID * 300) + (yIndex * 20) + xIndex
	if (x < 640 && y < 480) begin
	  currentTileID = tilemaps[(stageID * 300) + (yIndex * 20) + xIndex];
	end else begin
	  currentTileID = 9'd0;
	end
	
	MIFAddress = {currentTileID,deltaY,deltaX};
end

endmodule