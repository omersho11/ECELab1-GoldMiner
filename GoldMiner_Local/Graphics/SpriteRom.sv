module SpriteRom (
	input logic clk,
	input logic [3:0] objectType,
	input logic [4:0] offsetX,
	input logic [4:0] offsetY,
	output logic [7:0] rgb
);
// 32x32 = 1024 addresses per sprite. 
// objectType allows for 16 different sprites.
	logic [7:0] rom [0:16383]; 

	initial begin
		$readmemh("Bitmaps/sprite_data.hex", rom); 
	end

	always_ff @(posedge clk) begin
		// Linear addressing: {Type[3:0], Y[4:0], X[4:0]}
		rgb <= rom[{objectType, offsetY, offsetX}];
	end
endmodule