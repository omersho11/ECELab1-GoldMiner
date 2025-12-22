module DrawLine (
    input  logic [10:0] pixelX, pixelY, // Current VGA scan position
    input  logic [10:0] x1, y1, x2, y2, // Line coordinates
    input  logic [4:0] width,          // Thickness
    input  logic [7:0] lineColor,     // RRRGGGBB input
    output logic lineDR,
    output logic [7:0] lineRGB
);
	localparam TRANSPARENT_ENCODING = 8'hFF;

	int signed_width;
	assign signed_width = $signed({1'b0, width});

	int signed_x1;
	assign signed_x1 = $signed({1'b0, x1});
	int signed_y1;
	assign signed_y1 = $signed({1'b0, y1});
	int signed_x2;
	assign signed_x2 = $signed({1'b0, x2});
	int signed_y2;
	assign signed_y2 = $signed({1'b0, y2});
	int signed_px;
	assign signed_px = $signed({1'b0, pixelX});
	int signed_py;
	assign signed_py = $signed({1'b0, pixelY});

	int a, b, c, d;
	assign a = signed_px - signed_x1;
	assign b = signed_py - signed_y1;
	assign c = signed_x2 - signed_x1;
	assign d = signed_y2 - signed_y1;

	assign ineq_1 = ((c * b > (d * a - signed_width)) && (c * b < (d * a + signed_width)));
	assign ineq_2 = ((a * d > (b * c - signed_width)) && (a * d < (b * c + signed_width)));
	
	always_comb begin
		if ((ineq_1 || ineq_2) && signed_py >= signed_y1 && signed_py <= signed_y2) begin //  && pixelY > y1 && pixelY < y2
			lineDR = 1'b1;
			lineRGB = lineColor;
		end else begin
			lineDR = 1'b0;
			lineRGB = TRANSPARENT_ENCODING;
		end
	end

endmodule