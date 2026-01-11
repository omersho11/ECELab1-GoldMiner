module PotionAssetsROM (
    input  logic        clk,
    input  logic [1:0]  potionID,   // 0=Speed, 1=Luck, 2=Mult, 3=Rot
    input  logic [3:0]  frameIndex, // Animation frame (0, 1, 2...)
    input  logic [5:0]  offsetX,    // 0-63 relative to top-left
    input  logic [5:0]  offsetY,    // 0-63 relative to top-left
    
    output logic [7:0]  rgbOut,     // The pixel color
    output logic        isTransparent
);

    // --- 1. CONFIGURATION: Sprite Dimensions ---
    // Change these values to match your actual pixel art sizes!
    logic [5:0] width, height;
    logic [15:0] baseAddress; // Where this potion starts in memory
    logic [15:0] frameSize;   // width * height

    // Metadata Lookup Table
    always_comb begin
        case (potionID)
            2'd0: begin // POTION 0: SPEED 22 FRAMES
                width  = 18;
                height = 32;
                baseAddress = 0; 
            end
            2'd1: begin // POTION 1: LUCK 14 FRAMES
                width  = 18;
                height = 32;
                baseAddress = 18*32*22; 
            end
            2'd2: begin // POTION 2: MULTIPLIER 15 FRAMES
                width  = 18;
                height = 32;
                baseAddress = (18*32*22) + (18*32*14); 
            end
            2'd3: begin // POTION 3: ROTATION 24 FRAMES
                width  = 16;
                height = 16;
                baseAddress = (18*32*22) + (18*32*14) + (18*32*15);
            end
            default: begin width = 0; height = 0; baseAddress=0; end
        endcase
        
        frameSize = width * height;
    end

    // --- 2. ADDRESS CALCULATION ---
    logic [15:0] readAddress;
    logic inBounds;

    assign inBounds = (offsetX < width) && (offsetY < height);

    always_comb begin
        if (inBounds) begin
            // Address = Base + (Frame * SizeOfOneFrame) + (Y * Width) + X
            readAddress = baseAddress + 
                          (16'(frameIndex) * frameSize) + 
                          (16'(offsetY) * 16'(width)) + 
                          16'(offsetX);
        end else begin
            readAddress = 0; // Dummy address for safety
        end
    end

    // --- 3. MEMORY STORAGE (The Actual Art) ---
	 always_ff @(posedge clk) begin
        data <= mem[readAddress];
    end

    // --- 4. OUTPUT ---
    logic [7:0] mem [0:43199];
    initial $readmemh("Bitmaps/potions.hex", mem);
    
    logic [7:0] data;
    logic inBounds_d;
    
    always_ff @(posedge clk) begin
        inBounds_d <= inBounds;
    end

    // Use the delayed signal for transparency check
    assign isTransparent = (!inBounds_d) || (data == 8'hFF); 
    assign rgbOut = data;

endmodule