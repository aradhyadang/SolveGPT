// Part 2 skeleton

module ProjectFSM
	(
		CLOCK_50,						//	On Board 50 MHz
		// Your inputs and outputs here
		KEY,							// On Board Keys
		SW,
		HEX0,
		HEX1,
		HEX3,
		HEX4,
		LEDR,
		PS2_CLK,
		PS2_DAT,
		
		// The ports below are for the VGA output.  Do not change.
		VGA_CLK,   						//	VGA Clock
		VGA_HS,							//	VGA H_SYNC
		VGA_VS,							//	VGA V_SYNC
		VGA_BLANK_N,						//	VGA BLANK
		VGA_SYNC_N,						//	VGA SYNC
		VGA_R,   						//	VGA Red[9:0]
		VGA_G,	 						//	VGA Green[9:0]
		VGA_B,   						//	VGA Blue[9:0]
		AUD_ADCDAT,

	   // Bidirectionals
	   AUD_BCLK,
	   AUD_ADCLRCK,
	   AUD_DACLRCK,

	   FPGA_I2C_SDAT,

	   // Outputs
	   AUD_XCK,
	   AUD_DACDAT,

	   FPGA_I2C_SCLK,
	);

	input			CLOCK_50;				//	50 MHz
	input	[3:0]	KEY;
	input [9:0]SW;
	input PS2_CLK;
	input PS2_DAT;
	
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
	output [6:0]HEX0;
	output [6:0]HEX1;
	output [6:0]HEX3;
	output [6:0]HEX4;
	output [9:0]LEDR;
	
	wire resetn;
	assign resetn = KEY[2];
	
	// Create the colour, x, y and writeEn wires that are inputs to the controller.

	wire [2:0] colour;
	wire [7:0] x;
	wire [6:0] y;
	wire writeEn;
	
	assign colour=0;
	assign x=0;
	assign y=0;
	assign writeEN=0;
	
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
		defparam VGA.RESOLUTION = "320x240";
		defparam VGA.MONOCHROME = "FALSE";
		defparam VGA.BITS_PER_COLOUR_CHANNEL = 3;
		defparam VGA.BACKGROUND_IMAGE = "design.mif";
			
	// Put your code here. Your code should produce signals x,y,colour and writeEn
	// for the VGA controller, in addition to any other functionality your design may require.
	
	//audio
	input				AUD_ADCDAT;

  // Bidirectionals
  inout				AUD_BCLK;
  inout				AUD_ADCLRCK;
  inout				AUD_DACLRCK;

  inout				FPGA_I2C_SDAT;

  // Outputs
  output				AUD_XCK;
  output				AUD_DACDAT;

  output				FPGA_I2C_SCLK;
  
  main_audio m0 (CLOCK_50, KEY, AUD_ADCDAT, AUD_BCLK, AUD_ADCLRCK, AUD_DACLRCK, FPGA_I2C_SDAT, AUD_XCK, AUD_DACDAT, FPGA_I2C_SCLK, SW);
  
  wire [7:0]zero,one,two,three,four,five,six,seven,eight,nine;
	
  Keyboard U2(.PS2_CLK(PS2_CLK), .PS2_DAT(PS2_DAT),.zero(zero),.one(one),.two(two),.three(three),.four(four),.five(five),.six(six),.seven(seven),.eight(eight),.nine(nine));

	
	
	//logic
	
 wire signed [8:0] val1, val2;
 wire reset_n = KEY[0];
 wire go = ~KEY[1];
 wire input_choice;
 reg [7:0]inputKeyBoard;
 wire [7:0] inputMain;
 
 assign input_choice = SW[8]; 
 
 always@(*)
 begin
 if(zero)
 inputKeyBoard = 8'd0;
 else if(one)
 inputKeyBoard = 8'd1;
 else if(two)
 inputKeyBoard = 8'd2;
 else if(three)
 inputKeyBoard = 8'd3;
 else if(four)
 inputKeyBoard = 8'd4;
 else if(five)
 inputKeyBoard = 8'd5;
 else if(six)
 inputKeyBoard = 8'd6;
 else if(seven)
 inputKeyBoard = 8'd7;
 else if(eight)
 inputKeyBoard = 8'd8;
 else
 inputKeyBoard = 8'd9;
 end
 
 assign inputMain = input_choice ? inputKeyBoard : SW[7:0];
	
 mainmodule a0 (CLOCK_50, reset_n , go, SW[9], inputMain, val1, val2, LEDR[9], LEDR[5], LEDR[4]);
 hex_decoder h0 (val1[3:0], HEX0);
 hex_decoder h1 (val1[7:4], HEX1);
 hex_decoder h2 (val2[3:0], HEX3);
 hex_decoder h3 (val2[7:4], HEX4);
 
 assign LEDR[0] = val1[8];
 assign LEDR[1] = val2[8];
	
endmodule
