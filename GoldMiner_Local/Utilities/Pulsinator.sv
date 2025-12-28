module Pulsinator
(
    input logic clk,
    input logic resetN,
	 input logic data,
    
	 output logic pulse
);

logic data_d;

always_ff @(posedge clk or negedge resetN) begin
	if (!resetN) begin
		data_d <= 0;
	end else begin
		data_d <= data;		
	end
end

assign pulse = (!data_d && data);

endmodule