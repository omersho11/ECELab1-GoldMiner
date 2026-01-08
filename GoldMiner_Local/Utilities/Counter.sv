module Counter #(
    parameter int WIDTH = 20
) (
    input  logic clk,
    input  logic resetN,
    input  logic [WIDTH-1:0] increase,
    input  logic [WIDTH-1:0] decrease,
    
    output logic [WIDTH-1:0] value
);

    logic signed [WIDTH+1:0] next_value;

    always_comb begin
        next_value = (WIDTH+2)'(signed'({1'b0, value})) + 
                     (WIDTH+2)'(signed'({1'b0, increase})) - 
                     (WIDTH+2)'(signed'({1'b0, decrease}));
    end

    always_ff @(posedge clk or negedge resetN) begin
        if (!resetN) begin
            value <= '0;
        end else begin
            if (next_value < 0) begin
                value <= '0;
            end else if (next_value > (WIDTH+2)'({WIDTH{1'b1}})) begin
                value <= {WIDTH{1'b1}};
            end 
            else begin
                value <= next_value[WIDTH-1:0];
            end
        end
    end
endmodule