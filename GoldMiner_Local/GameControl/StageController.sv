module	StageController	(	
	input	logic	clk,
	input	logic	resetN,
	input	logic	startOfFrame,  // short pulse every start of frame 30Hz 
	input logic stageEnded,
	input logic playerWon,

	output logic [3:0] stage,
	output logic manualResetN
);

//                    0        1        2            3            4             5
enum  logic [3:0] {S_LEVEL, S_SHOP, S_WIN_MENU ,S_LOSS_MENU, S_MAIN_MENU, S_GAME_END} stageSM;


assign stage = stageSM;
logic stageEnded_d;
logic stageEndedPulse;
assign stageEndedPulse = (stageEnded && (!stageEnded_d));

always_ff@(posedge clk or negedge resetN)
begin
	if(!resetN) begin  
			stageSM <= S_MAIN_MENU;
			stageEnded_d <= 0;
			manualResetN <= 1;
	end
	
	else begin 
		stageEnded_d <= stageEnded;
		
		if(stageEndedPulse) begin
			case (stageSM) 
				S_MAIN_MENU: begin
					stageSM <= S_LEVEL;
				end
				
				S_LEVEL: begin
					if(playerWon) begin						
						stageSM <= S_SHOP;
					end
					else begin
						stageSM <= S_LOSS_MENU;
					end
				end
				
				S_WIN_MENU: begin
					stageSM <= S_SHOP;
				end
				
				S_SHOP: begin
					stageSM <= S_LEVEL;
				end
				
				default: begin
					manualResetN <= 0;
					stageSM <= S_MAIN_MENU;
				end
				
			endcase
		end
	end 
end
endmodule
