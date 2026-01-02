module Counter (
	input logic clk,
	input logic resetN,
	input logic [19:0] increase,
	input logic [19:0] decrease,
	
	output logic [19:0] value
);



always_ff @(posedge clk or negedge resetN) begin
	if (!resetN) begin
		 value <= 0;
	end else begin
		if ((increase != 0) || (decrease != 0)) begin
			value <= value + increase;
			if (value + increase < decrease) value <= 0;
		end
	end
end


endmodule
