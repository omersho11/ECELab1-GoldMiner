module Counter (
    input logic clk,
    input logic resetN,
    input logic [19:0] increase,
    input logic [19:0] decrease,
    output logic [19:0] value
);

    // Use a slightly larger intermediate signal to detect overflow/underflow
    logic signed [21:0] next_value;

    always_comb begin
        // Calculate the potential new value
        // We cast to signed to handle the case where decrease > (value + increase)
        next_value = 22'(value) + 22'(increase) - 22'(decrease);
    end

    always_ff @(posedge clk or negedge resetN) begin
        if (!resetN) begin
            value <= 0;
        end else begin
            if (next_value < 0) begin
                value <= 0; // Saturate at zero (Underflow protection)
            end else if (next_value > 20'hFFFFF) begin
                value <= 20'hFFFFF; // Saturate at max (Overflow protection)
            end else begin
                value <= 20'(next_value);
            end
        end
    end
endmodule