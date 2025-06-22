module tick_10ms (
	input clk,
	input rst,

	output reg tick_10ms
);

	localparam FCNT = 1000_000;
	
	reg [($clog2(FCNT) - 1): 0] tcnt;

	always @(posedge clk or posedge rst) begin
		if(rst) begin
			tcnt <= 0;
			tick_10ms <= 0;
		end
		else if(tcnt == (FCNT - 1)) begin
			tick_10ms <=  1;
			tcnt <= 0;
		end
		else begin
			tick_10ms <= 0;
			tcnt <= tcnt + 1;
		end
	end
endmodule