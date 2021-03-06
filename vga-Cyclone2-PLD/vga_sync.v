module VGA_SYNC (
	input wire clk,
	input reset,
	input wire [7:0]iR,
	input wire [7:0]iG,
	input wire [7:0]iB,
	output reg [10:0]cnt_x,
	output reg [9:0]cnt_y,
	output reg Hsync,
	output reg Vsync,
	output reg [7:0]R,
	output reg [7:0]G,
	output reg [7:0]B
	);
	
	
	always @(posedge clk) 
	
		if (reset)
		begin
			cnt_x <=11'd0;
			cnt_y <=10'd0;
			Hsync <=0;
			Ysync <=0;
			R <=0;
			G <=0;
			B <=0;
		end
		else begin 
		
	cnt_x <= cnt_x +1'd1;
	
	if (cnt_x == 11'd1055)
	begin 
		cnt_x <=11'd0;
		cnt_y <=cnt_y + 1'd1;
		
		if (cnt_y == 10'd627)
		begin 
			cnt_y <=10'd0;
		end
	end
	
	if ((cnt_x >=11'd841)&&(cnt_x <=11'd969))
		Hsync <=1;
	else 
		Hsync <=0;
		
	if ((cnt_y >=10'd602)&&(cnt_y <=10'd606))
		Vsync <=1;
	else 
		Vsync <=0;