module Hook #(
    parameter OFFSET_X = 320,
    parameter OFFSET_Y = 96,
    parameter MIN_LENGTH = 100,
	 parameter MAX_LENGTH = 600,
	 parameter EXTENTION_SPEED = 1,
	 parameter ROTATION_SPEED = 1
)
(
    input  logic clk,
    input  logic resetN,
    input  logic enable,
    input  logic startOfFrame,
	 input  logic sendHook,
	 
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
	 
	 logic isHookOut;
	 int length;
	 logic isHookRetracting;
	 assign isNotInBoundingBox = (x <= EXTENTION_SPEED || x >= 640-EXTENTION_SPEED || y <= EXTENTION_SPEED || y >= 480-EXTENTION_SPEED);
	 

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
				isHookOut <= 0;
				isHookRetracting <= 0;
				length <= MIN_LENGTH;
				
            angle <= startingPosition;
            direction <= 1;
				
            frame_divider <= 0;
        end else if (enable && startOfFrame) begin
            frame_divider <= frame_divider + 1;
            // Only update angle every 4th frame to prevent "too fast" rotation
				
				isHookOut <= isHookOut || sendHook;
				
            if (frame_divider == 0) begin
                if (angle >= 250) begin
                    direction <= -1;
					 end
					 if (angle <= 132) begin
						  direction <= 1;
                end
					 if (isHookOut) begin
						  angle <= angle;
						  length <= (isHookRetracting) ? length - EXTENTION_SPEED : length + EXTENTION_SPEED;

						  if (length >= MAX_LENGTH) begin
								isHookRetracting <= 1;
								length <= MAX_LENGTH;
						  end
						  if (length < MIN_LENGTH && isHookRetracting) begin
								isHookRetracting <= 0;
								isHookOut <= 0;
								length <= MIN_LENGTH;
						  end
						  if (isNotInBoundingBox) isHookRetracting <= 1;
						  
						  
					 end else begin
						  angle <= angle + ROTATION_SPEED*direction; 
					 end
            end
        end
		  else if(!enable) begin
				length <= MIN_LENGTH;
				isHookOut <= 0;
				isHookRetracting <= 0;
				
				angle <= startingPosition;
            direction <= 1;
		  end
    end


    always_comb begin
		shortint offsetX, offsetY;

		offsetX = (length * rawCos) >>> 8;
		offsetY = (length * rawSin) >>> 8;
		
		if (cosNeg) begin
			x = ((OFFSET_X > offsetX) ? OFFSET_X - offsetX : 0);
		end else begin
			x = OFFSET_X + offsetX;
		end
		
		y = OFFSET_Y + (sinNeg ? offsetY : -offsetY);
end

endmodule