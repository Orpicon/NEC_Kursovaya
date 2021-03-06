module IRDA(input wire clk,
	input wire rst,
	output reg led_out,
	output wire tx,
	input wire rx,
	input wire sig);
	
parameter start_bit = 2'b00;
parameter wait_start = 2'b01;
parameter read_data = 2'b10;
parameter reset = 2'b11;
parameter trans = 3'b100;

	
	
reg [31:0] cnt;
reg [8:0] bit_tx;
reg flag;
reg [2:0] curState;
reg [6:0] bitCount;
reg clr_cnt;
wire txclk_en;
wire rxclk_en;
reg [31:0] full_data;
reg [7:0] data;
wire rdy;




initial begin
led_out = 1'b1;
full_data = 32'b0;
curState = start_bit;
bitCount = 0;
bit_tx=0;
flag=0;
clr_cnt = 0;
end


always@(posedge clk or negedge rst or posedge flag)
begin
	if(!rst) cnt <= 32'b0;	
	else if(flag) cnt <= 32'b0;
	else if(cnt>32'd27000000) cnt <= 32'b0;

	else cnt <= cnt + 32'b1;
end
	
	
always@(posedge clk or negedge rst)
begin
	if(!rst)
		begin
			led_out <= 1'b1;
			full_data <= 32'b0;
			bitCount = 0;
			bit_tx=0;
			flag=0;
			clr_cnt = 0;
			curState = start_bit;
		end
	else 
		begin
			case(curState)
			start_bit:
				begin
					if(!sig)
						begin
							curState <= wait_start;
							flag=1;
						end
				end
			wait_start:
				begin
				flag=0;
				if((cnt>32'd625000)&&(cnt<32'd710000)&&(!sig))
					begin
					curState = read_data;
					flag=1;
				   end
				end
			read_data:
				begin
					clr_cnt = 0;
					flag=0;
					if((cnt>32'd41000)&&(cnt<32'd86000)&&(!sig))
					begin
						data=8'b00110000;
						full_data[bitCount]<= 1'b0;
						bitCount=bitCount+1;
						clr_cnt = 1;
						flag=1;
					end
					else if((cnt>32'd97500)&&(cnt<32'd127500)&&(!sig))
					begin
						data=8'b00110001;
						full_data[bitCount]<= 1'b1;
						bitCount=bitCount+1;
						clr_cnt = 1;
						flag=1;
					end
					if(bitCount==32)
					begin
					bitCount=0;
					flag<=0;
					clr_cnt = 0;
					led_out <= 1'b0;
					flag<=1;
					curState = trans;
					end
				end
			trans:
				begin
				flag<=1;
				if(cnt>32'd1000000) curState = reset;
				end
			reset:
				begin
				full_data <= 0;
				if(cnt>32'd1000000) curState <= start_bit;
				bitCount <= 0;
				bit_tx<= 0;
				flag<= 0;
				clr_cnt <=  0;
				end
			endcase
		end
end


baud_rate_gen uart_baud (.clk_50m(clk), .rxclk_en(rxclk_en), .txclk_en(txclk_en));

transmitter uart_tx(.din(data), 
	.wr_en(clr_cnt), 
	.clk_50m(clk),
	.clken(txclk_en),
	.tx(tx));

/*receiver uart_rx( .rx(rx),
		.rdy(rdy),
		.rdy_clr(rdy),
		.clk_50m(clk),
		.clken(rxclk_en),
		.data(data));
*/


endmodule