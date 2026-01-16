module MagicProjectileROM #(
    parameter [10:0] WIDTH = 32,
    parameter [10:0] HEIGHT = 32
) (
    input logic clk,
    input logic resetN,       // <--- Added for timer reset
    input logic startOfFrame, // <--- Added for animation timing (30Hz/60Hz)
    
    input logic [10:0] pixelX,
    input logic [10:0] pixelY,
    input logic [10:0] centerX, 
    input logic [10:0] centerY,
    
    output logic [7:0] rgbOut,
    output logic dr
);

    // --- 1. Calculate Top-Left from Center ---
    logic [10:0] topLeftX, topLeftY;
    assign topLeftX = centerX - (WIDTH >> 1);
    assign topLeftY = centerY - (HEIGHT >> 1);

    // --- 2. Animation Timer ---
    // Toggles frameIndex every 0.5 seconds (approx 15 frames at 30Hz)
    logic [3:0] timer;
    logic frameIndex; // 0 or 1

    always_ff @(posedge clk or negedge resetN) begin
        if (!resetN) begin
            timer <= 0;
            frameIndex <= 0;
        end else if (startOfFrame) begin
            if (timer >= 15) begin // 15 frames @ 30fps = 0.5 seconds
                timer <= 0;
                frameIndex <= ~frameIndex; 
            end else begin
                timer <= timer + 1;
            end
        end
    end

    // --- 3. Bounds Check ---
    logic inBox;
    logic [10:0] offsetX, offsetY;
    
    assign inBox = (pixelX >= topLeftX) && (pixelX < topLeftX + WIDTH) &&
                   (pixelY >= topLeftY) && (pixelY < topLeftY + HEIGHT);

    assign offsetX = pixelX - topLeftX;
    assign offsetY = pixelY - topLeftY;

    // --- 4. Address Calculation ---
    logic [15:0] address;
    localparam FRAME_SIZE = WIDTH * HEIGHT;
    localparam TOTAL_SIZE = FRAME_SIZE * 2; // 2 Frames

    always_comb begin
        address = 0;
        if (inBox) begin
            // Offset by FRAME_SIZE if we are on frame 1
            address = (frameIndex * FRAME_SIZE) + (offsetY * WIDTH) + offsetX;
        end
    end

    // --- 5. Memory ---
    // Size is now 32 * 32 * 2 = 2048 bytes
    (* ramstyle = "M10K" *) logic [7:0] mem [0:TOTAL_SIZE-1]; 
    
    // Ensure your hex file now contains 2048 entries (Frame 0 followed by Frame 1)
    initial $readmemh("Assets/bubble.hex", mem); 

    // --- 6. Pipeline Output ---
    logic inBox_d;
    logic [7:0] q;
    
    always_ff @(posedge clk) begin
        q <= mem[address];
        inBox_d <= inBox; // Pipeline alignment
    end
    
    always_comb begin
        rgbOut = q;
        dr = inBox_d && (q != 8'hFF);
    end

endmodule