module	LossMenu	(	
			input	logic	clk,
			input	logic	resetN,
			input logic enable,
			input logic anyKeyPressed,
			output logic drStage,
			output logic stageEnded
);


always_ff@(posedge clk or negedge resetN)
begin
	stageEnded <= 0;
	stageEnded <= (enable && anyKeyPressed);
end
endmodule
