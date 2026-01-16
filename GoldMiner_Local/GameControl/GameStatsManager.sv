module GameStatsManager (
    input  logic clk,
    input  logic resetN,
    input  logic upgradePulse,
    input  GlobalsPKG::SHOP_ITEM_T itemBought, 
	 
    // --- The Outputs that go to LevelController ---
    output GlobalsPKG::SPEED_T      currentExtSpeed,
    output GlobalsPKG::SPEED_T      currentRotSpeed,
    output GlobalsPKG::LUCK_T       currentLuck,
    output GlobalsPKG::MULTIPLIER_T currentMultiplier,
	 
	 output logic [3:0] rawExtSpeedLevel,
 	 output logic [3:0] rawRotSpeedLevel,
	 output logic [3:0] rawLuckLevel,
	 output logic [3:0] rawMultLevel
);

    import GlobalsPKG::*;

    // --- Base Stats Constants ---
    localparam SPEED_T      BASE_EXT_SPEED   = 9'd3;
    localparam SPEED_T      BASE_ROT_SPEED   = 9'd1;
    localparam LUCK_T       BASE_LUCK        = 4'd1;
    localparam MULTIPLIER_T BASE_MULTIPLIER  = 20'd1;

    // --- Internal Counters (How many upgrades bought) ---
    logic [3:0] extSpeedLevel;
    logic [3:0] rotSpeedLevel;
    logic [3:0] luckLevel;
    logic [3:0] multLevel;
	 
	 
	 assign rawExtSpeedLevel = extSpeedLevel;
	 assign rawRotSpeedLevel = rotSpeedLevel;
	 assign rawLuckLevel = luckLevel;
	 assign rawMultLevel = multLevel;

    always_ff @(posedge clk or negedge resetN) begin
        if (!resetN) begin
            extSpeedLevel <= 0;
            rotSpeedLevel <= 0;
            luckLevel     <= 0;
            multLevel     <= 0;
        end else begin
            if (upgradePulse) begin
                case (itemBought)
                    ITEM_EXT_SPEED:  extSpeedLevel <= extSpeedLevel + 1;
                    ITEM_LUCK:       luckLevel     <= luckLevel + 1;
                    ITEM_MULTIPLIER: multLevel     <= multLevel + 1;
                    ITEM_ROT_SPEED:  rotSpeedLevel <= rotSpeedLevel + 1;
                    default: ; 
                endcase
            end
        end
    end

    // --- Calculate Actual Game Values ---
    // Example: Speed = Base 3 + (Level * 1)
    assign currentExtSpeed   = BASE_EXT_SPEED + {5'b0, extSpeedLevel};
    assign currentRotSpeed   = BASE_ROT_SPEED + {5'b0, rotSpeedLevel}; 
    assign currentLuck       = BASE_LUCK + luckLevel;
    assign currentMultiplier = BASE_MULTIPLIER + {16'b0, multLevel};

endmodule