module Shop(	
	input	logic	clk,
	input	logic	resetN,
	input logic enable,
	input logic [9:0] numberKeyPressed, // 0-9
	input GlobalsPKG::MONEY money,      // Current wallet
	input logic enterKeyPressed,
	input logic [3:0] levelExtSpeed,
 	input logic [3:0] levelLuck,
	input logic [3:0] levelMultiplier,
	input logic [3:0] levelRotSpeed,
	
	// --- Outputs ---
	output logic drStage,               // UI Draw Request
	output logic stageEnded,            // Exit Shop
	
	// Money Transaction
	output GlobalsPKG::MONEY spendAmount,
	output logic spendPulse,
	
	// Stats Transaction (To StatsManager)
	output GlobalsPKG::SHOP_ITEM_T itemToUpgrade,
	output logic upgradeRequestPulse,
	output logic [19:0] currentCostExtSpeed,
	output logic [19:0] currentCostLuck,
	output logic [19:0] currentCostMult,
	output logic [19:0] currentCostRotSpeed
);

	import GlobalsPKG::*;
	// --- level cap ---
	localparam MAX_LEVEL = {3{1'b1}};

	// --- Prices ---
	localparam MONEY BASE_COST_SPEED      = 20'd10;
	localparam MONEY BASE_COST_LUCK       = 20'd10;
	localparam MONEY BASE_COST_MULTIPLIER = 20'd10;
	localparam MONEY BASE_COST_ROTATION   = 20'd30;
	
	// 2. Cost Increase 
	localparam MONEY INC_COST_SPEED      = 20'd10;  
	localparam MONEY INC_COST_LUCK       = 20'd25;
	localparam MONEY INC_COST_MULTIPLIER = 20'd50;
	localparam MONEY INC_COST_ROTATION   = 20'd50;
	
	// --- Calculate Current Costs ---
	// Cost = Base + (Current Level * Increment)
	
	assign currentCostExtSpeed = BASE_COST_SPEED 	  + (levelExtSpeed   * INC_COST_SPEED);
	assign currentCostLuck     = BASE_COST_LUCK       + (levelLuck       * INC_COST_LUCK);
	assign currentCostMult     = BASE_COST_MULTIPLIER + (levelMultiplier * INC_COST_MULTIPLIER);
	assign currentCostRotSpeed = BASE_COST_ROTATION   + (levelRotSpeed   * INC_COST_ROTATION);
	
	// --- Key Logic ---
	logic [9:0] lastKey;
	logic keyPulse;
	logic enterLast;
	logic enterPulse;

	// Edge detection for keys
	always_ff @(posedge clk or negedge resetN) begin
		if(!resetN) begin 
			lastKey <= 0; 
			enterLast <= 0;
		end else begin 
			lastKey <= numberKeyPressed; 
			enterLast <= enterKeyPressed;
		end
	end
	assign keyPulse   = (numberKeyPressed != 0) && (numberKeyPressed != lastKey);
	assign enterPulse = (enterKeyPressed && !enterLast);


	// --- Transaction Logic ---
	always_ff @(posedge clk or negedge resetN) begin
		if(!resetN) begin
			spendAmount <= 0;
			spendPulse  <= 0;
			upgradeRequestPulse <= 0;
			itemToUpgrade <= ITEM_NONE;
			stageEnded <= 0;
			
		end else if (enable) begin
			// Default pulses to 0 every cycle
			spendPulse <= 0;
			upgradeRequestPulse <= 0;
			itemToUpgrade <= ITEM_NONE; // Clear item bus
			stageEnded <= 0; // Default
			
			if (keyPulse) begin
				case(numberKeyPressed)
					EXTENSION_SPEED_KEY: begin // BUY EXTENSION SPEED
						if ((money >= currentCostExtSpeed) && (levelExtSpeed < MAX_LEVEL)) begin
							spendAmount <= currentCostExtSpeed;
							spendPulse  <= 1;
							
							itemToUpgrade <= ITEM_EXT_SPEED;
							upgradeRequestPulse <= 1; 
						end
					end
					
					LUCK_KEY: begin // BUY LUCK
						if ((money >= currentCostLuck) && (levelLuck < MAX_LEVEL)) begin
							spendAmount <= currentCostLuck;
							spendPulse  <= 1;
							
							itemToUpgrade <= ITEM_LUCK;
							upgradeRequestPulse <= 1;
						end
					end
					
					MULTIPLIER_KEY: begin // BUY MULTIPLIER
						if ((money >= currentCostMult) && (levelMultiplier < MAX_LEVEL)) begin
							spendAmount <= currentCostMult;
							spendPulse  <= 1;
							
							itemToUpgrade <= ITEM_MULTIPLIER;
							upgradeRequestPulse <= 1;
						end
					end
					
					ROTATION_SPEED_KEY: begin // BUY ROTATION SPEED
						if ((money >= currentCostRotSpeed) && (levelRotSpeed < MAX_LEVEL)) begin
							spendAmount <= currentCostRotSpeed;
							spendPulse  <= 1;
							
							itemToUpgrade <= ITEM_ROT_SPEED;
							upgradeRequestPulse <= 1;
						end
					end
					
					default: ;
				endcase
			end
			
			if (enterPulse) stageEnded <= 1;
			
		end else begin
			spendPulse <= 0;
			upgradeRequestPulse <= 0;
			stageEnded <= 0;
		end
	end
endmodule