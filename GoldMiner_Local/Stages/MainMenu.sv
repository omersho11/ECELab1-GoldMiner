module	MainMenu	(	
			input	logic	clk,
			input	logic	resetN,
			input logic enable,
			input logic anyKeyPressed,
			output logic drLevel,
			output logic stateEnded
);


always_ff@(posedge clk or negedge resetN)
begin
	stateEnded = (enable && anyKeyPressed);
end
endmodule
