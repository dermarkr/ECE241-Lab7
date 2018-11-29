// Part 2 skeleton

	module main
		(
			CLOCK_50,						//	On Board 50 MHz
			SW,
			KEY,  							// On Board Keys
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
		wire draw, start, erase, WAIT, predraw;
		wire [2:0] current_state, next_state;


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
//		

		
		datapath d0(.clk(CLOCK_50), .resetn(KEY[0]), .colour_in(SW[9:7]), .draw(draw), .erase(erase), .start(start), .WAIT(WAIT), .predraw(predraw), .x(x), .y(y), .colour_out(colour), .VGA_DRAW(writeEn));
		
		controller c0(.clk(CLOCK_50), .resetn(KEY[0]), .draw(draw), .start(start), .erase(erase), .WAIT(WAIT), .predraw(predraw), .current_state(current_state), .next_state(next_state));
		
		
		
		
			
		// Put your code here. Your code should produce signals x,y,colour and writeEn
		// for the VGA controller, in addition to any other functionality your design may require.
	
	
endmodule
     
                

module controller(
					input clk,
					input resetn,
					output reg  draw, start, erase, WAIT, predraw,
					output reg [2:0] current_state, next_state
					);

	
	reg [23:0] counter4;
	reg [3:0] counter2;
	reg [3:0] counter;
    
	localparam  S_START		= 3'd0,
					S_ERASE     = 3'd1,
					S_PREDRAW	= 3'd2,
					S_DRAW   	= 3'd3,
					S_WAIT      = 3'd4;




	 // Next state logic aka our state table
    always@(posedge clk)
    begin
			if(current_state == S_START) begin
				next_state = S_DRAW;	
				counter2 = 4'b0;
				counter4 = 24'b0;
				counter = 4'b0000;
				end
			else if(current_state == S_ERASE)
				begin
					counter = 4'b0000;
					if(counter2 == 4'b1111) next_state = S_PREDRAW;
					else counter2 = counter2 + 1;
				end
			else if(current_state == S_PREDRAW) next_state = S_DRAW;
			else if(current_state == S_DRAW)
				begin
					counter4 = 24'b0;
					if(counter == 4'b1111)	next_state = S_WAIT;
					else counter = counter + 1;
				end
			else if(current_state == S_WAIT)
				begin
				if(counter4 == 24'd12500000) begin  //change timer to 12500000
					next_state = S_ERASE;
					counter2 = 15'b0;
				end
				else counter4 = counter4 + 1;
			end

			else next_state = S_ERASE;
    end // state_table
   

    // Output logic aka all of our datapath control signals
    always @(*)
    begin: enable_signals
        // By default make all our signals 0 to avoid latches.
        // This is a different style from using a default statement.
        // It makes the code easier to read.  If you add other out
        // signals be sure to assign a default value for them here.

        draw = 1'b0;
        erase = 1'b0;

        case (current_state)
				S_START: begin
					 start = 1'b1;
					 predraw = 1'b0;
					 draw = 1'b0;
					 erase = 1'b0;
					 WAIT = 1'b0;
				end
				S_ERASE: begin
					 start = 1'b0;
					 predraw = 1'b0;
					 draw = 1'b0;
					 erase = 1'b1;
					 WAIT = 1'b0;
				end
				S_PREDRAW: begin
					 start = 1'b0;
					 predraw = 1'b1;
                draw = 1'b0;
					 erase = 1'b0;
					 WAIT = 1'b0;
            end
            S_DRAW: begin
					 start = 1'b0;
					 predraw = 1'b0;
                draw = 1'b1;
					 erase = 1'b0;
					 WAIT = 1'b0;
            end
            S_WAIT: begin
					 start =1'b0;
					 predraw = 1'b0;
					 draw = 1'b0;
                erase = 1'b0;
					 WAIT = 1'b1;
            end
        // default:    // don't need default since we already made sure all of our outputs were assigned a value at the start of the always block
        endcase
    end // enable_signals
   
    // current_state registers
    always@(posedge clk)
    begin: state_FFs
        if(!resetn)
            current_state <= S_START;
        else
            current_state <= next_state;
    end // state_FFS
endmodule

module datapath(
    input clk,
    input resetn,
	 input [2:0] colour_in,
    input draw, erase, start, WAIT, predraw,
    output reg [7:0] x,
	 output reg [6:0] y,
	 output reg [2:0] colour_out,
	 output reg VGA_DRAW
    );
    
	 reg [7:0] x_in;
	 reg [6:0] y_in;
	 reg x_shift, y_shift;
	 
	 
	 reg [1:0] x_count, y_count;
	 reg draw_count;
	 reg [6:0] random_count;
	 reg [2:0] rng_colour;

    // Registers a, b, c, x with respective input logic
    always@(posedge clk) begin
		random_count <= random_count + 1;
        if(!resetn) begin
            x_in <= 8'b0; 
            y_in <= 7'b0;
				x_count <= 2'b0;
				y_count <= 2'b0;

				VGA_DRAW <= 1'b0;
				colour_out <= 1'b000;
				
        end
        else begin
				if(start) begin
					 x <= 8'd156;
					 x_in <= 8'd156;
					 y <= 7'b0000000;
					 y_in <= 7'b0000000;
					 x_shift <= 1'b0;
					 y_shift <= 1'b1;

					 x_count <= 2'b0;
					 y_count <= 2'b0;
				end 
            if(draw)
				begin
					VGA_DRAW <= 1;
					colour_out <= colour_in; //change to colour_in
					x <= x_in + x_count;
					y <= y_in + y_count;
					x_count <= x_count + 1;
					if(x_count == 'b11) 
						y_count <= y_count + 1;
				end
            if(erase)
				begin
					VGA_DRAW <= 1;
					colour_out <= 'b000; //fun COLOURS
					x <= x_in + x_count;
					y <= y_in + y_count;
					x_count <= x_count + 1;
					if(x_count == 'b11) 
						y_count <= y_count + 1;				
				
					draw_count <= 1'b0;
				end
            if(predraw)
				begin
					VGA_DRAW <= 0;
					colour_out <= colour_in;
					if(draw_count == 1) begin
						if(x_shift == 1'b0) x_in <= x_in - 1;
						else if(x_shift == 1'b1) x_in <= x_in + 1;
						if(y_shift == 1'b0) y_in <= y_in - 1;
						else if(y_shift == 1'b1) y_in <= y_in + 1;
						
						if(x_in == 8'd0) begin
							x_shift <= 1'b1;
							rng_colour <= random_count;
							end
						else if (x_in == 8'd155) begin
							x_shift <= 1'b0;
							rng_colour <= random_count;
						end
						if(y_in == 7'd0) begin
							y_shift <= 1'b1;
							rng_colour <= random_count;
						end
						else if (y_in == 7'd115) begin
							y_shift <= 1'b0;
							rng_colour <= random_count;
						end
					end
					else draw_count <= draw_count + 1;
					
					x<= x_in;
					y<= y_in;
					
				end                
        end
    end

	 
    
endmodule



