module	StageController	(	
			input	logic	clk,
			input	logic	resetN,
			input	logic	startOfFrame,  // short pulse every start of frame 30Hz 
			input logic stageEnded,
			input logic playerWon,
			output logic [3:0] stage									
);

	//                    0        1        2            3            4             5
	enum  logic [3:0] {S_LEVEL, S_SHOP, S_WIN_MENU ,S_LOSS_MENU, S_MAIN_MENU, S_GAME_END} stageSM;
	
	logic incrementLevel;
	
	assign stage = stageSM;
	
	always_ff@(posedge clk or negedge resetN)
	begin
		if(!resetN)
		begin  
				stageSM <= S_MAIN_MENU;
				incrementLevel = 0;
		end
		
		else begin 
			incrementLevel = 0;
			
			if(stageEnded) begin
				case (stageSM) 
					S_MAIN_MENU: begin
						stageSM <= S_LEVEL;
					end
					
					S_LEVEL: begin
						if(playerWon) begin
							incrementLevel = 1;
						
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
						stageSM <= S_MAIN_MENU;
					end
					
				endcase
			end
		end 
	end
endmodule
