module	MainMenu	(	
			input	logic	clk,
			input	logic	resetN,
			input logic enable,
			input logic anyKeyPressed,
			output logic drStage,
			output logic stageEnded
);


always_ff@(posedge clk or negedge resetN) begin
	if (!resetN) begin
		stageEnded <= 0;
	end else begin
		stageEnded <= 0;
		if (enable) stageEnded <= anyKeyPressed;
	end
end
endmodule
