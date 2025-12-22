module Hook #(
    parameter OFFSET_X = 320,
    parameter OFFSET_Y = 96,
    parameter LENGTH   = 100 
)
(
    input  logic clk,
    input  logic resetN,
    input  logic enable,
    input  logic startOfFrame,
    output logic [10:0] x,
    output logic [10:0] y
);

    // 8-bit angle constants
    localparam [7:0] ANGLE_PI          = 8'd128;
    localparam [7:0] ANGLE_ONE_HALF_PI = 8'd192; // 270 deg (Bottom)
    localparam [7:0] ANGLE_TWO_PI      = 8'd255; 
    
    logic [7:0] angle;
	 logic [7:0] startingPosition = ANGLE_ONE_HALF_PI;
    int direction; // Using 32-bit signed for 'sign' logic

    // Trig Table Outputs (Q8.7 format from your specific module)
    logic [7:0] rawSin;
    logic [7:0] rawCos;
	 logic sinNeg, cosNeg;

    RotationTable trigTable (
        .angle(angle),
		  
        .sin(rawSin),
		  .sinIsNegative(sinNeg),
        .cos(rawCos),
		  .cosIsNegative(cosNeg)
    );

    // --- Part 1: Motion Logic (Slowed down for visibility) ---
    logic [1:0] frame_divider; 

    always_ff @(posedge clk or negedge resetN) begin
        if (!resetN) begin
            angle <= startingPosition;
            direction <= 1;
            frame_divider <= 0;
        end else if (enable && startOfFrame) begin
            frame_divider <= frame_divider + 1;
            
            // Only update angle every 4th frame to prevent "too fast" rotation
            if (frame_divider == 0) begin
                if (angle >= 250) begin
                    direction <= -1;
					 end
					 if (angle <= 132) begin
						  direction <= 1;
                end
					 
                angle <= angle + 1*direction; 
            end
        end
    end


    always_comb begin
		shortint offsetX, offsetY;

		offsetX = (LENGTH * rawCos) >>> 8;
		offsetY = (LENGTH * rawSin) >>> 8;

		x = OFFSET_X + (cosNeg ? -offsetX : offsetX);
		y = OFFSET_Y + (sinNeg ? offsetY : -offsetY);
end

endmodule