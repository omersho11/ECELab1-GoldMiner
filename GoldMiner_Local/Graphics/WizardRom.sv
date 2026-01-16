module WizardROM #(
    parameter [10:0] WIDTH = 64,
    parameter [10:0] HEIGHT = 64,
    parameter [3:0] SCALE = 0
) (
    input logic clk,
    input logic [10:0] pixelX,
    input logic [10:0] pixelY,
    input logic [10:0] topLeftX,
    input logic [10:0] topLeftY,
    input logic [2:0] frameIndex, // 0-3
	 input logic startOfFrame,

    
    output logic [7:0] rgbOut,
    output logic dr
);
    import GlobalsPKG::*;
	 
	 logic [2:0] frameLatch;

    // --- 1. Bounds Check (Scaled) ---
    logic inBox;
    logic [10:0] offsetX, offsetY;
    
    // We multiply Width/Height by Scale to get the Screen Size
    assign inBox = (pixelX >= topLeftX) && (pixelX < topLeftX + (WIDTH << SCALE)) &&
                   (pixelY >= topLeftY) && (pixelY < topLeftY + (HEIGHT << SCALE));

    assign offsetX = pixelX - topLeftX;
    assign offsetY = pixelY - topLeftY;

    // --- 2. Address Calculation ---
    logic [15:0] address;
    localparam FRAME_SIZE = WIDTH * HEIGHT;
	 localparam FRAME_COUNT = 4;

    always_comb begin
        address = 0;
        if (inBox) begin
            // Division by SCALE maps screen pixels back to texture pixels
            address = (frameLatch * FRAME_SIZE) + 
                      ((offsetY >> SCALE) * WIDTH) + 
                      (offsetX >> SCALE);
        end
    end

    // --- 3. Memory ---
    (* ramstyle = "M10K" *) RGB_T mem [0:(FRAME_SIZE*FRAME_COUNT)-1]; 
    initial $readmemh("Assets/wizard/wizardAnimations.hex", mem); 

    // --- 4. Pipeline Read ---
    logic [7:0] q;
    logic inBox_d;

    always_ff @(posedge clk) begin
        q <= mem[address];
        inBox_d <= inBox;
    end
	 
	 always_ff @(posedge clk) begin
        if(startOfFrame) frameLatch <= frameIndex;
    end
	 
    assign rgbOut = q;
    assign dr = inBox_d && (q != 8'hFF); 

endmodule