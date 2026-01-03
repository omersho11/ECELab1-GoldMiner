module Random # (
	seed = 16'hBEEF
)(
	input logic clk,
	input logic resetN,
	input logic reseed,
	input logic storeValue,
	
	output logic [15:0] random,
	output logic [15:0] randomLatch
);


always_ff @(posedge clk or negedge resetN) begin
	if (!resetN) begin
		if (seed == 0) begin
			random <= 1;
			randomLatch <= 1;
		end else begin
			random <= seed;
			randomLatch <= seed;
		end
	end else if (reseed) begin
		if (seed == 0) begin
			random <= 1;
			randomLatch <= 1;
		end else begin
			random <= seed;
			randomLatch <= seed;
		end
	end else begin
		random <= {random[14:0], random[15] ^ random[13] ^ random[12] ^ random[10]};
		
		if (storeValue) begin
			randomLatch <= {random[14:0], random[15] ^ random[13] ^ random[12] ^ random[10]};
		end
	end
end

endmodule
