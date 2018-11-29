// Part 2 skeleton

	module main
		(
			CLOCK_50,						//	On Board 50 MHz
			SW,
			KEY,								// On Board Keys
			// The ports below are for the VGA output.  Do not change.
			VGA_CLK,   						//	VGA Clock
			VGA_HS,							//	VGA H_SYNC
			VGA_VS,							//	VGA V_SYNC
			VGA_BLANK_N,						//	VGA BLANK
			VGA_SYNC_N,						//	VGA SYNC
			VGA_R,   						//	VGA Red[9:0]
			VGA_G,	 						//	VGA Green[9:0]
			VGA_B   						//	VGA Blue[9:0]
		);

		input			CLOCK_50;				//	50 MHz
		input	[3:0]	KEY;
		input [9:0] SW;
		// Declare your inputs and outputs here
		// Do not change the following outputs
		output			VGA_CLK;   				//	VGA Clock
		output			VGA_HS;					//	VGA H_SYNC
		output			VGA_VS;					//	VGA V_SYNC
		output			VGA_BLANK_N;				//	VGA BLANK
		output			VGA_SYNC_N;				//	VGA SYNC
		output	[7:0]	VGA_R;   				//	VGA Red[7:0] Changed from 10 to 8-bit DAC
		output	[7:0]	VGA_G;	 				//	VGA Green[7:0]
		output	[7:0]	VGA_B;   				//	VGA Blue[7:0]
		
		wire resetn;
		assign resetn = KEY[0];
		
		
		// Create the colour, x, y and writeEn wires that are inputs to the controller.

		wire [2:0] colour;
		wire [7:0] x;
		wire [6:0] y;
		wire writeEn;
		wire ld_x, ld_y, do_draw;


		// Create an Instance of a VGA controller - there can be only one!
		// Define the number of colours as well as the initial background
		// image file (.MIF) for the controller.
		vga_adapter VGA(
								.resetn(resetn),
								.clock(CLOCK_50),
								.colour(colour),
								.x(x),
								.y(y),
								.plot(writeEn),
								/* Signals for the DAC to drive the monitor. */
								.VGA_R(VGA_R),
								.VGA_G(VGA_G),
								.VGA_B(VGA_B),
								.VGA_HS(VGA_HS),
								.VGA_VS(VGA_VS),
								.VGA_BLANK(VGA_BLANK_N),
								.VGA_SYNC(VGA_SYNC_N),
								.VGA_CLK(VGA_CLK));
		defparam VGA.RESOLUTION = "160x120";
		defparam VGA.MONOCHROME = "FALSE";
		defparam VGA.BITS_PER_COLOUR_CHANNEL = 1;
		defparam VGA.BACKGROUND_IMAGE = "black.mif";
		
		
		
		
		datapath d0(.clk(CLOCK_50), .resetn(KEY[0]), .colour_in(SW[9:7]), .data_in(SW[6:0]), .ld_x(ld_x), .ld_y(ld_y), .blank(~KEY[2]), .do_draw(do_draw), .x(x), .y(y), .colour_out(colour), .VGA_DRAW(writeEn));
		
		controller c0(.clk(CLOCK_50), .resetn(KEY[0]), .go(KEY[3]), .draw(~KEY[1]), .ld_x(ld_x), .ld_y(ld_y), .do_draw(do_draw));
		
		
		
		
			
		// Put your code here. Your code should produce signals x,y,colour and writeEn
		// for the VGA controller, in addition to any other functionality your design may require.
	
	
endmodule
     
                

module controller(
					input clk,
					input resetn,
					input go,
					input draw,
					output reg  ld_x, ld_y, do_draw
					);

	reg [6:0] current_state, next_state;
	reg [4:0] counter;
    
	localparam  S_LOAD_X       = 3'd0,
					S_LOAD_X_WAIT  = 3'd1,
					S_LOAD_Y       = 3'd2,
					S_LOAD_Y_WAIT  = 3'd3,
					S_DRAW			= 3'd4;



	 // Next state logic aka our state table
    always@(posedge clk)
    begin
			if(current_state == S_LOAD_X)
				begin
					counter = 4'b0000;
					if(draw) next_state = S_DRAW;
					else if (!go) next_state = S_LOAD_X_WAIT;
					else if (go) next_state = S_LOAD_X;
				end
			else if(current_state == S_LOAD_X_WAIT)
				begin
					if(draw) next_state = S_DRAW;
					else if (!go) next_state = S_LOAD_X_WAIT;
					else if (go) next_state = S_LOAD_Y;
				end
			else if(current_state == S_LOAD_Y)
				begin
					if(draw) next_state = S_DRAW;
					else if (!go) next_state = S_LOAD_Y_WAIT;
					else if (go) next_state = S_LOAD_Y;
				end
			else if(current_state == S_LOAD_Y_WAIT)
				begin
					if(draw) next_state = S_DRAW;
					else if (!go) next_state = S_LOAD_Y_WAIT;
					else if (go) next_state = S_DRAW;
				end
			else if(current_state == S_DRAW)
				begin
				if(counter == 4'b1111)	next_state = S_LOAD_X;
				else counter = counter + 1;
			end

			else next_state = S_LOAD_X;
    end // state_table
   

    // Output logic aka all of our datapath control signals
    always @(*)
    begin: enable_signals
        // By default make all our signals 0 to avoid latches.
        // This is a different style from using a default statement.
        // It makes the code easier to read.  If you add other out
        // signals be sure to assign a default value for them here.

        ld_x = 1'b0;
        ld_y = 1'b0;

        case (current_state)
            S_LOAD_X: begin
                ld_x = 1'b1;
					 ld_y = 1'b0;
					 do_draw = 1'b0;
                end
            S_LOAD_Y: begin
					 ld_x = 1'b0;
                ld_y = 1'b1;
					 do_draw = 1'b0;
                end
				S_DRAW: begin
					 ld_x = 1'b0;
                ld_y = 1'b0;
					 do_draw = 1'b1;
				end
				

        // default:    // don't need default since we already made sure all of our outputs were assigned a value at the start of the always block
        endcase
    end // enable_signals
   
    // current_state registers
    always@(posedge clk)
    begin: state_FFs
        if(!resetn)
            current_state <= S_LOAD_X;
        else
            current_state <= next_state;
    end // state_FFS
endmodule

module datapath(
    input clk,
    input resetn,
    input [6:0] data_in,
	 input [2:0] colour_in,
    input ld_x, ld_y, do_draw,
	 input blank,
    output reg [7:0] x,
	 output reg [6:0] y,
	 output reg [2:0] colour_out,
	 output reg VGA_DRAW
    );
    
	 reg [7:0] x_in;
	 reg [6:0] y_in;
	 
	 reg [1:0] x_count, y_count;
	 reg [7:0] x_blank;
	 reg [6:0] y_blank;

    // Registers a, b, c, x with respective input logic
    always@(posedge clk) begin
        if(!resetn) begin
            x_in <= 8'b0; 
            y_in <= 7'b0;
				x_count <= 2'b0;
				y_count <= 2'b0;
				x_blank <= 7'b0;
				y_blank <= 7'b0;
				VGA_DRAW <= 0;
        end
		  else if(blank) begin
				VGA_DRAW <= 1;
				x <= x_blank;
				y <= y_blank;
				colour_out <= 3'b000;
				x_blank <= x_blank + 1;
				if(x_blank == 8'b1111111) y_blank <= y_blank + 1;
			end
        else begin
            if(ld_x)
				begin
					 VGA_DRAW <= 0;
                x_in <= {1'b0, data_in};
					 x <= x_in;
					 colour_out <= colour_in;
				end
            if(ld_y)
				begin
					 VGA_DRAW <= 0;
                y_in <= data_in;
					 y <= y_in;
					 colour_out <= colour_in;
				end
            if(do_draw)
				begin
					VGA_DRAW <= 1;
					colour_out <= colour_in;
					x <= x_in + x_count;
					y <= y_in + y_count;
					x_count <= x_count + 1;
					if(x_count == 'b11) 
						y_count <= y_count + 1;
				end                
        end
    end
    
endmodule
