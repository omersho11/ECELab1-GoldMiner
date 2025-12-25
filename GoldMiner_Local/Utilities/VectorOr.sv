module VectorOr #(
parameter int SIZE = 5
) (
	input logic [SIZE-1:0] data,
	output logic out
);

assign out = |data; // uses the "or" reduction operator
endmodule
