module FiveDigitNumberDisplay #(
    parameter logic [7:0] color = 8'hFF
) (
    input  logic        clk,
    input  logic        resetN,
    input  logic        enable,
    input  logic [10:0] topLeftX,
    input  logic [10:0] topLeftY,
    input  logic [10:0] pixelX,
    input  logic [10:0] pixelY,
    input  logic [19:0] number,
    input  logic        startOfFrame,   // 1-cycle pulse at frame start

    output logic        drawingRequest,
    output logic [7:0]  RGBout
);

assign RGBout = color;

// Stable digits for the renderer (ten-thousands ... ones)
logic [4:0][3:0] digitsLatch;

FiveDigitDisplay display (
.clk(clk),
.resetN(resetN),
.enable(enable),
.topLeftX(topLeftX),
.topLeftY(topLeftY),
.pixelX(pixelX),
.pixelY(pixelY),
.digits(digitsLatch),
.drawingRequest(drawingRequest)
);

// ---- Double-dabble state ----
logic [19:0] number_frame;     // sampled at startOfFrame
logic        req;              // "conversion requested" sticky flag

logic [19:0] bcd;              // packed BCD (ones in [3:0])
logic [19:0] bin;              // shifting binary
logic [4:0]  bitCnt;
logic        busy;

logic [4:0][3:0] digits_next;
logic            digits_next_valid;

always_ff @(posedge clk or negedge resetN) begin
	if (!resetN) begin
		digitsLatch       <= '{default:4'd0};
		number_frame      <= 20'd0;
		req               <= 1'b0;
		bcd               <= 20'd0;
		bin               <= 20'd0;
		bitCnt            <= 5'd0;
		busy              <= 1'b0;
		digits_next       <= '{default:4'd0};
		digits_next_valid <= 1'b0;

	end else if (!enable) begin
		// Freeze when disabled (keep last displayed digits)
		busy <= 1'b0;
		req  <= 1'b0;

		end else begin
			// 1) At start of frame: sample number and request convert if changed
			if (startOfFrame) begin
				if (number != number_frame) begin
					number_frame <= number;
					req          <= 1'b1;
				end

				// Commit new digits only at frame boundary (prevents tearing)
				if (digits_next_valid) begin
					digitsLatch       <= digits_next;
					digits_next_valid <= 1'b0;
				end
			end

			// 2) Start conversion if requested and idle
			if (!busy && req) begin
				req    <= 1'b0;
				bcd    <= 20'd0;
				bin    <= number_frame;
				bitCnt <= 5'd20;
				busy   <= 1'b1;
			end
			// 3) Run one double-dabble step per clock while busy
			else if (busy) begin
			logic [19:0] bcd_tmp;
			logic [19:0] bcd_next;

			bcd_tmp = bcd;

			// Add-3 correction on each BCD digit
			for (int d = 0; d < 5; d++) begin
				if (bcd_tmp[d*4 +: 4] >= 4'd5)
					bcd_tmp[d*4 +: 4] = bcd_tmp[d*4 +: 4] + 4'd3;
			end

			// Shift in the next binary MSB
			bcd_next = {bcd_tmp[18:0], bin[19]};

			bcd    <= bcd_next;
			bin    <= {bin[18:0], 1'b0};
			bitCnt <= bitCnt - 1'b1;

			// Done after last shift
			if (bitCnt == 5'd1) begin
				busy <= 1'b0;

				// bcd_next: [3:0]=ones, [7:4]=tens, ...
				digits_next[4] <= bcd_next[3:0];     // ones
				digits_next[3] <= bcd_next[7:4];     // tens
				digits_next[2] <= bcd_next[11:8];    // hundreds
				digits_next[1] <= bcd_next[15:12];   // thousands
				digits_next[0] <= bcd_next[19:16];   // ten-thousands

				digits_next_valid <= 1'b1;
			end
		end
	end
end

//assign digits[0] = (number / 10000) % 10;
//assign digits[1] = (number / 1000) % 10;
//assign digits[2] = (number / 100) % 10;
//assign digits[3] = (number / 10) % 10;
//assign digits[4] = (number / 1) % 10;

endmodule
