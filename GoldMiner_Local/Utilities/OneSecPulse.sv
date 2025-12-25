module OneSecPulse (	
    input logic clk,
    input logic resetN,
	 output logic pulse
);

localparam int TICKS_IN_SECOND = 31_500_000;

logic [$clog2(TICKS_IN_SECOND)-1:0] ticksSinceReset;

always_ff @(posedge clk or negedge resetN) begin
	if (!resetN) begin  
		pulse <= 0;
		ticksSinceReset <= 0;
	end
	else begin
		pulse <= 0;
	
		if (ticksSinceReset < TICKS_IN_SECOND - 1) begin
			ticksSinceReset <= ticksSinceReset + 1;
		end
		else begin
			pulse <= 1;
			ticksSinceReset <= 0;
		end
	end
end

endmodule