module SafeManualReset (
	input logic clk,
	input logic realResetN,
	input logic manualResetN,

	output logic resetN
);

logic manualResetN_d;
logic manualResetNFallingEdge;
assign manualResetNFallingEdge = manualResetN_d && (!manualResetN);

always_ff @(posedge clk) begin
	manualResetN_d <= manualResetN;
	
	resetN <= manualResetNFallingEdge && realResetN;
end

endmodule