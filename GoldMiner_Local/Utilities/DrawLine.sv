module DrawLine (
	input  logic enable,
	input  logic [10:0] pixelX, pixelY,
	input  logic [10:0] x1, y1, x2, y2,
	input  logic [4:0]  width,
	input  logic [7:0]  lineColor,
	output logic lineDR,
	output logic [7:0]  lineRGB
);
    localparam TRANSPARENT_ENCODING = 8'hFF;

    // 1. Optimize Bit Widths
    // Screen coords need 11 bits + 1 sign bit = 12 bits. 
    // We use 14 bits to be safe for intermediate subtractions.
    logic signed [13:0] s_x1, s_y1, s_x2, s_y2, s_px, s_py;
    logic signed [13:0] width_s;

    assign s_x1 = {3'b0, x1};
    assign s_y1 = {3'b0, y1};
    assign s_x2 = {3'b0, x2};
    assign s_y2 = {3'b0, y2};
    assign s_px = {3'b0, pixelX};
    assign s_py = {3'b0, pixelY};
    assign width_s = {9'b0, width};

    // 2. Deltas (Max value ~640, fits in 14 bits)
    logic signed [13:0] a, b, c, d;
    assign a = s_px - s_x1;
    assign b = s_py - s_y1;
    assign c = s_x2 - s_x1;
    assign d = s_y2 - s_y1;

    // 3. Manhattan Length (Max ~1120)
    logic signed [13:0] abs_dx, abs_dy, lengthAprox;
    assign abs_dx = (c < 0) ? -c : c;
    assign abs_dy = (d < 0) ? -d : d;
    assign lengthAprox = abs_dx + abs_dy;

    // 4. Scaled Width (Max 5 * 1120 = 5600, fits in 14 bits)
    logic signed [23:0] scaledWidth; // Give extra headroom for multiplication result
    assign scaledWidth = width_s * lengthAprox;

    // 5. Cross Products (Max 640*640 = 409,600, requires ~19 bits)
    logic signed [23:0] cross1, cross2;
    assign cross1 = c * b; // (x2-x1)*(py-y1)
    assign cross2 = d * a; // (y2-y1)*(px-x1)

    // 6. Inequality Logic
    logic ineq;
    logic yBound;
    
    // Combine the logic to verify distance from line
    assign ineq = (cross1 > (cross2 - scaledWidth)) && (cross1 < (cross2 + scaledWidth));

    // Fix potential wrapping/ordering issue in bounding box
    assign yBound = (s_y1 <= s_y2) ? (s_py >= s_y1 && s_py <= s_y2) : (s_py >= s_y2 && s_py <= s_y1);

    always_comb begin
        if (ineq && yBound) begin
            lineDR = 1'b1 && enable;
            lineRGB = lineColor;
        end else begin
            lineDR = 1'b0;
            lineRGB = TRANSPARENT_ENCODING;
        end
    end
endmodule