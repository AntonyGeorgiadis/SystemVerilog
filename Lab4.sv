module Bars (
    input logic clk,   // pixel clock
    input logic rst,       // reset
	input logic incr,
    input logic decr,
    input logic mvUp,
    input logic mvDown,
    output logic hsync,     // horizontal sync
    output logic vsync,     // vertical sync
    output logic [3:0] red,
	output logic [3:0] green,
	output logic [3:0] blue
    );
	
logic pxlClk;
logic [10:0] hcount;
logic [9:0] vcount;

logic [9:0] Pos1; //Position 1
logic [9:0] Pos2; //Position 2
logic [9:0] Pos3; //Position 3

logic [1:0] det_mvUp; //Move Up
logic pos_mvUp;

logic [1:0] det_mvDown; //Move Down
logic  pos_mvDown;

logic [1:0] det_incr; //Bar increase 
logic pos_incr;

logic [1:0] det_decr; //Bar decrease
logic pos_decr;

//VGA Signals

always_ff @(posedge clk) begin
    if (rst)
        pxlClk <= 1'b1;
    else
        pxlClk <= ~pxlClk;
end

always_ff @(posedge clk) begin
    if (rst) begin
         hcount <= 0;
        vcount <= 0;
    end
    else begin
        if (pxlClk) begin
             if (hcount == 1039) begin
                hcount <= 0;
                if (vcount == 665)
                    vcount <= 0;
                else
                    vcount <= vcount + 1'b1;
            end
            else
                hcount <= hcount + 1'b1;

            if (vcount >= 637 && vcount < 643)
                vsync <= 1'b0;
            else
                vsync <= 1'b1;
        
            if (hcount >= 856 && hcount < 976)
                hsync <= 1'b0;
            else
                hsync <= 1'b1;
        end
    end
end


typedef enum logic[2:0] {Position1=3'b001, Position2=3'b010, Position3=3'b100} vga_state;
vga_state state;

always_ff @(posedge clk) begin 
 if (rst) begin 
    Pos1<=270;
	Pos2<=270;
	Pos3<=270;
	state<=Position1;
	red <= 4'b0000;
    green <= 4'b0000;
    blue <= 4'b0000;
    end
	else begin
    case (state)
	Position1: begin
	if(pos_Down) state<=Position2;
	 if (vcount > 80 && vcount <120 && hcount > 130 && hcount < 170) begin 
	  red <=4'b1111;
	  green<=4'b1111;
	  blue<=4'b0000;
	 end
	 if(pos_incr && Pos1 < 750) begin
	 Pos1<=Pos1+32;
	 end
	 else if(pos_decr && Pos1 > 270) begin
	 Pos1<=Pos1-32;
	 end
	end
	Position2: begin
	if(pos_Down) state<=Position3;
	 else if (pos_mvUp) state<=Position1;
	 if (vcount > 280 && vcount < 320 && hcount > 130 && hcount < 170) begin
	  red <=4'b1111;
	  green<=4'b1111;
	  blue<=4'b0000;
	 end
	 if(pos_incr && Pos2 < 750) begin
	 Pos2<=Pos2+32;
	 end
	 else if(pos_decr && Pos2 > 270) begin
	 Pos2<=Pos2-32;
	 end
	end
	Position3: begin 
	if(pos_mvUp) state<=Position1;
	 if(vcount > 480 && vcount < 520 && hcount >130 & hcount < 170) begin 
	  red <=4'b1111;
	  green<=4'b1111;
	  blue<=4'b0000;
	 end
	 if(pos_incr && Pos3 < 750) begin
	 Pos3<=Pos3+32;
	 end
	 else if(pos_decr && Pos3 > 270) begin
	 Pos3<=Pos3-32;
	 end
	end
	endcase
	end

        if (pxlClk) begin
            if (hcount > 250 && hcount < Pos1 && vcount > 50 &&vcount < 150) begin
                red <= 4'b1000;
                green <= 4'b0000;
                blue <= 4'b0000;
            end
            else if (hcount > 250 && hcount < Pos2 && vcount > 250 && vcount < 350) begin
                red <= 4'b0000;
                green <= 4'b1000;
                blue <= 4'b0000;
            end
            else if (hcount > 250 && hcount < Pos3 && vcount > 450 && vcount < 550) begin
                red <= 4'b0000;
                green <= 4'b0000;
                blue <= 4'b1000;
            end
			else begin
                red <= 4'b0000;
                green <= 4'b0000;
                blue <= 4'b0000;
           end
end
end

//	Move Up-Down increase-decrease

	
always_ff @(posedge clk) begin
 if (rst) begin
 det_mvUp <= 2'b00;
 end else begin
 det_mvUp[1] <= det_mvUp[0];
 det_mvUp[0] <= mvUp;
 end
end
assign pos_mvUp = det_mvUp[0] & ~det_mvUp[1];
// 


always_ff @(posedge clk) begin
 if (rst) begin
 det_mvDown <= 2'b00;
 end else begin
 det_mvDown[1] <= det_mvDown[0];
 det_mvDown[0] <= mvDown;
 end
end
assign pos_Down = det_mvDown[0] & ~det_mvDown[1];
//


always_ff @(posedge clk) begin
 if (rst) begin
 det_incr <= 2'b00;
 end else begin
 det_incr[1] <= det_incr[0];
 det_incr[0] <= incr;
 end
end
assign pos_incr = det_incr[0] & ~det_incr[1];
//


always_ff @(posedge clk) begin
 if (rst) begin
 det_decr <= 2'b00;
 end else begin
 det_decr[1] <= det_decr[0];
 det_decr[0] <= decr;
 end
end
assign pos_decr = det_decr[0] & ~det_decr[1];
//

endmodule