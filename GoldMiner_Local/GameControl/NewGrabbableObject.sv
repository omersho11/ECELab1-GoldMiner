module NewGrabbableObject (
    input  logic clk,
    input  logic resetN,
    input  logic manualReset,
    input  logic [10:0] idleX, idleY,
    input  logic [10:0] pixelX, pixelY,
    input  LEVEL_ELEMENTS objectType,
    input  logic [10:0] hookX, hookY,
    input  logic isHooked,
    input  logic hookReturned,
    
    output logic [10:0] value,
    output logic destroyed,
    output logic [3:0]  texToRead,
    output logic [4:0]  addrX, addrY,
    output logic        isInside,
	 output logic valuePulse
);

	 import GlobalsPKG::*;
	 
	 const logic [3:0][10:0] VALUE_TABLE = {11'd0,11'd2,11'd5,11'd10,11'd1}; 
    enum logic [1:0] {STATE_IDLE, STATE_GRABBED, STATE_DESTROYED} state;
    logic [10:0] topLeftX, topLeftY;

    // State Machine
    always_ff @(posedge clk or negedge resetN) begin
        if(!resetN) begin
				state <= (objectType == FILLER ? STATE_DESTROYED : STATE_IDLE);
            value <= 0;
				destroyed <= 0;
				valuePulse <= 0;
        end else begin
				valuePulse <= 0;
		  
				if (manualReset) begin
					state <= (objectType == FILLER ? STATE_DESTROYED : STATE_IDLE);
					value <= 0;
					destroyed <= 0;
				end
				else begin case(state)
						STATE_IDLE:      if (isHooked) state <= STATE_GRABBED;
						STATE_GRABBED:   if (hookReturned) begin
                                    state <= STATE_DESTROYED;
                                    value <= VALUE_TABLE[objectType];
												valuePulse <= 1;

                                 end
						STATE_DESTROYED: begin 
							state <= STATE_DESTROYED; 
							destroyed <= 1;
							value <= 0;
							end
					endcase
				end
        end
    end

    // Position Logic
    always_comb begin
        case(state)
            STATE_GRABBED:   {topLeftX, topLeftY} = {hookX - 11'd16, hookY - 11'd16};
            STATE_DESTROYED: {topLeftX, topLeftY} = {11'd2047, 11'd2047}; // Off-screen
            default:         {topLeftX, topLeftY} = {idleX, idleY};
        endcase
    end

    // Coordinate Math
    assign addrX = 5'(pixelX - topLeftX);
    assign addrY = 5'(pixelY - topLeftY);
    assign isInside = (pixelX >= topLeftX && pixelX < topLeftX + 32) &&
                      (pixelY >= topLeftY && pixelY < topLeftY + 32) &&
                      (objectType != FILLER) && (state != STATE_DESTROYED);
endmodule