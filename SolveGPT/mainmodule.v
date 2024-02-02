module mainmodule(Clock, resetn, Go, Choice, DataIn, DataResult1, DataResult2, comp_en, inf_en, no_en);
    input Clock;
    input resetn;
    input Go;
	 input Choice;
    input [7:0] DataIn;
    output [8:0] DataResult1;
    output [8:0] DataResult2;
	 output comp_en, inf_en, no_en;

    // lots of wires to connect our datapath and control
    wire ld_a, ld_b, ld_c, ld_d, ld_x1, ld_x2;
    wire ld_alu_out;
    wire [2:0] alu_select_a, alu_select_b;
    wire [2:0] alu_op;
	 wire [8:0] X1, X2;
	 wire c_en, i_en, n_en;
	 
	 control1 C1 (Clock, resetn, Go, ld_a, ld_b, ld_c, ld_d, ld_x1, ld_x2, ld_alu_out, alu_op, alu_select_a, alu_select_b);
	 datapath1 D1 (Clock, resetn, DataIn, ld_alu_out, ld_d, ld_a, ld_b, ld_c, ld_x1, ld_x2, alu_op, alu_select_a, alu_select_b, X1, X2, c_en); 
	 
	 wire ld_A1, ld_A2, ld_B1, ld_B2, ld_C1, ld_C2, ld_D, ld_DX, ld_DY, ld_P1, ld_P2, ld_x, ld_y;
    wire ld_Alu_Out;
    wire [3:0] Alu_Select_A, Alu_Select_B;
    wire [1:0] Alu_Op;
	 wire [8:0] X, Y;
	 
	 control2 C2 (Clock, resetn, Go, ld_Alu_Out, Alu_Op, ld_A1, ld_A2, ld_B1, ld_B2, ld_C1, ld_C2, ld_D, ld_DX, ld_DY, ld_P1, ld_P2, ld_x, ld_y, Alu_Select_A, Alu_Select_B);
	 datapath2 D2(Clock, resetn, DataIn, ld_Alu_Out, ld_A1, ld_A2, ld_B1, ld_B2, ld_C1, ld_C2, ld_D, ld_DX, ld_DY, ld_P1, ld_P2, ld_x, ld_y, Alu_Op, Alu_Select_A, Alu_Select_B, X, Y, i_en, n_en);
	 
	 assign comp_en = Choice ? c_en : 1'b0;
	 assign inf_en = Choice ? 1'b0 : i_en;
	 assign no_en = Choice ? 1'b0 : n_en;
	 
	 assign DataResult1 = Choice ? X1 : X;
	 assign DataResult2 = Choice ? X2 : Y;

 endmodule

module control1(clk, resetn, go, ld_a, ld_b, ld_c, ld_d, ld_x1, ld_x2, ld_alu_out, alu_op, alu_select_a, alu_select_b);

	 input clk, resetn, go;
    output reg ld_a, ld_b, ld_c, ld_d, ld_x1, ld_x2;
	 output reg ld_alu_out;
	 output reg [2:0]alu_op;
    output reg [2:0]alu_select_a, alu_select_b;
	 
    reg [4:0] current_state, next_state;

    localparam  LOAD_A        = 5'd0,
                LOAD_A_WAIT   = 5'd1,
                LOAD_B        = 5'd2,
                LOAD_B_WAIT   = 5'd3,
                LOAD_C        = 5'd4,
                LOAD_C_WAIT   = 5'd5,
                CYCLE_ROOT_0  = 5'd6,
                CYCLE_ROOT_1  = 5'd7,
                CYCLE_ROOT_2  = 5'd8,
					 CYCLE_ROOT_3  = 5'd9,
                CYCLE_ROOT_4  = 5'd10,
					 CYCLE_ROOT_5  = 5'd11,
                CYCLE_ROOT_6  = 5'd12,
                CYCLE_ROOT_7  = 5'd13,
					 CYCLE_ROOT_8  = 5'd14,
                CYCLE_ROOT_9  = 5'd15,
                CYCLE_ROOT_10  = 5'd16;
					 
    // Next state logic aka our state table
    always@(*)
    begin: state_table
            case (current_state)
                LOAD_A: next_state = go ? LOAD_A_WAIT : LOAD_A; // Loop in current state until value is input
                LOAD_A_WAIT: next_state = go ? LOAD_A_WAIT : LOAD_B; // Loop in current state until go signal goes low
                LOAD_B: next_state = go ? LOAD_B_WAIT : LOAD_B; // Loop in current state until value is input
                LOAD_B_WAIT: next_state = go ? LOAD_B_WAIT : LOAD_C; // Loop in current state until go signal goes low
                LOAD_C: next_state = go ? LOAD_C_WAIT : LOAD_C; // Loop in current state until value is input
                LOAD_C_WAIT: next_state = go ? LOAD_C_WAIT : CYCLE_ROOT_0; // Loop in current state until go signal goes low
                CYCLE_ROOT_0: next_state = CYCLE_ROOT_1;
                CYCLE_ROOT_1: next_state = CYCLE_ROOT_2;
					 CYCLE_ROOT_2: next_state = CYCLE_ROOT_3;
                CYCLE_ROOT_3: next_state = CYCLE_ROOT_4;
					 CYCLE_ROOT_4: next_state = CYCLE_ROOT_5;
					 CYCLE_ROOT_5: next_state = CYCLE_ROOT_6;
					 CYCLE_ROOT_6: next_state = CYCLE_ROOT_7;
                CYCLE_ROOT_7: next_state = CYCLE_ROOT_8;
					 CYCLE_ROOT_8: next_state = CYCLE_ROOT_9;
					 CYCLE_ROOT_9: next_state = CYCLE_ROOT_10;
                CYCLE_ROOT_10: next_state = LOAD_A;
					 
            default: next_state = LOAD_A;
        endcase
    end // state_table


    // Output logic aka all of our datapath control signals
    always @(*)
    begin: enable_signals
        // By default make all our signals 0
        ld_alu_out = 1'b0;
        ld_a = 1'b0;
        ld_b = 1'b0;
        ld_c = 1'b0;
        ld_d = 1'b0;
        ld_x1 = 1'b0;
		  ld_x2 = 1'b0;
		  
        alu_select_a = 3'b0;
        alu_select_b = 3'b0;
        alu_op      = 3'b0;

        case (current_state)
            LOAD_A: begin
                ld_a = 1'b1;
                end
            LOAD_B: begin
                ld_b = 1'b1;
                end
            LOAD_C: begin
                ld_c = 1'b1;
                end
            CYCLE_ROOT_0: begin // Do D <- B*B; 
                ld_d = 1'b1; // store result back into D
                alu_select_a = 3'b001; // Select register B
                alu_select_b = 3'b001; // Also select register B
                alu_op = 3'b010; // Do multiply operation
            end
            CYCLE_ROOT_1: begin //Do B <- -B
                ld_alu_out = 1'b1; ld_b = 1'b1; // store result in B 
                alu_select_a = 3'b001; // Select register B
                alu_op = 3'b011; // Do negation operation
            end
				CYCLE_ROOT_2: begin // Do C <- A*C
                ld_alu_out = 1'b1; ld_c = 1'b1; // store result in c 
                alu_select_a = 3'b000; // Select register A
					 alu_select_b = 3'b010; // select register C
                alu_op = 3'b010; // Do multiplication operation
            end
				CYCLE_ROOT_3: begin //Do C <- 4*(A*C)
                ld_alu_out = 1'b1; ld_c = 1'b1; // store result in c 
                alu_select_a = 3'b100; // Select register P1
					 alu_select_b = 3'b010; //  select register C
                alu_op = 3'b010; // Do multiplication operation
            end
				CYCLE_ROOT_4: begin //Do A <- 2*A
                ld_alu_out = 1'b1; ld_a = 1'b1; // store result in A 
                alu_select_a = 3'b101; // Select register P2
					 alu_select_b = 3'b000; //  select register A
                alu_op = 3'b010; // Do multiplication operation
            end
				CYCLE_ROOT_5: begin // Do D <- (B*B) - (4*A*C); 
                ld_d = 1'b1; // store result back into D
                alu_select_a = 3'b011; // Select register D
                alu_select_b = 3'b010; // select register C
                alu_op = 3'b001; // Do subtraction
			   end
				CYCLE_ROOT_6: begin //Do D <- sqrt(D)
                ld_d = 1'b1; // store result in C 
                alu_select_a = 3'b011; // Select register D
                alu_op = 3'b101; // Do square root 
            end
				CYCLE_ROOT_7: begin //Do C <- -B - D
                ld_alu_out = 1'b1; ld_c = 1'b1; // store result in C 
                alu_select_a = 3'b001; // Select register B
					 alu_select_b = 3'b011; // Select register D
                alu_op = 3'b001; // Do subtraction 
            end
				CYCLE_ROOT_8: begin //Do B <- -B + D
                ld_alu_out = 1'b1; ld_b = 1'b1; // store result in B 
                alu_select_a = 3'b001; // Select register B
					 alu_select_b = 3'b011; //Select Register D
                alu_op = 3'b000; // Do addition 
            end
				CYCLE_ROOT_9: begin //Do X1 <- B/A
                ld_x1 = 1'b1; // store result in C 
                alu_select_a = 3'b001; // Select register B
					 alu_select_b = 3'b000; // Select register A
                alu_op = 3'b100; // Do division 
            end
				CYCLE_ROOT_10: begin //Do X2 <- C/A
                ld_x2 = 1'b1; // store result in C 
                alu_select_a = 3'b010; // Select register B
					 alu_select_b = 3'b000; // Select register A
                alu_op = 3'b100; // Do division 
            end
				
        // default:    // don't need default since we already made sure all of our outputs were assigned a value at the start of the always block
        endcase
    end // enable_signals
	 
    // current_state registers
    always@(posedge clk)
    begin: state_FFs
        if(!resetn)
            current_state <= LOAD_A;
        else
            current_state <= next_state;
    end // state_FFS
endmodule


module datapath1(clk, resetn, data_in, ld_alu_out, ld_d, ld_a, ld_b, ld_c, ld_x1, ld_x2, alu_op, alu_select_a, alu_select_b, X1, X2, comp_en);

    input clk, resetn;
	 input [7:0] data_in;
	 input ld_alu_out;
	 input ld_d, ld_a, ld_b, ld_c;
	 input ld_x1, ld_x2;
	 input [2:0]alu_op;
	 input [2:0]alu_select_a, alu_select_b;
	 output reg signed [8:0] X1, X2;
	 output reg comp_en;
	 
    // input registers
    reg signed [8:0] a, b, c, d, p1, p2;

    // output of the alu
    reg signed [8:0] alu_out;
    // alu input muxes
    reg signed [8:0] alu_a, alu_b;
	 
	 wire signed [8:0] Q, R;
	 wire signed [4:0] val;
	 wire signed [5:0] rem;

    // Registers a, b, c, d with respective input logic
    always@(posedge clk) begin
        if(!resetn) begin
            a <= 9'b0;
            b <= 9'b0;
            c <= 9'b0;
            d <= 9'b0;
				p1 <= 9'd4;
				p2 <= 9'd2;
				comp_en <= 1'b0;
        end
        else begin
            if(ld_a)
                a <= ld_alu_out ? alu_out : data_in; // load alu_out if load_alu_out signal is high, otherwise load from data_in
            if(ld_b)
                b <= ld_alu_out ? alu_out : data_in; // load alu_out if load_alu_out signal is high, otherwise load from data_in
			   if(ld_c)
                c <= ld_alu_out ? alu_out : data_in; // load alu_out if load_alu_out signal is high, otherwise load from data_in
            if(ld_d)
				begin
                d <= alu_out;
					 if(d < 0)
					 begin
					 comp_en <= 1'b1;
					 end
				end	 
        end
    end

    // Output result register
    always@(posedge clk) begin
        if(!resetn) begin
            X1 <= 9'b0;
				X2 <= 9'b0;
        end
        else
		  begin
			if(comp_en)
			begin
				X1 <= 0;
				X2 <= 0;
			end
			else
			begin
            if(ld_x1)
                X1 <= alu_out;
				if(ld_x2)
				    X2 <= alu_out;
			end
		  end
    end

    // The ALU input multiplexers
    always @(*)
    begin
        case (alu_select_a)
            3'd0:
                alu_a = a;
            3'd1:
                alu_a = b;
            3'd2:
                alu_a = c;
            3'd3:
                alu_a = d;
				3'd4:
				    alu_a = p1;
				3'd5:
				    alu_a = p2;
				
            default: alu_a = 9'b0;
        endcase

        case (alu_select_b)
            3'd0:
                alu_b = a;
            3'd1:
                alu_b = b;
            3'd2:
                alu_b = c;
            3'd3:
                alu_b = d;
				3'd4:
				    alu_b = p1;
				3'd5:
				    alu_b = p2;
            default: alu_b = 9'b0;
        endcase
    end
	 
	 //Perform Division
	 DivCkt u0 (alu_b, alu_a, Q, R);
	 
	 //Perform Square Root
	 sqrt u1 (alu_a, val, rem);

    // The ALU
    always @(*)
    begin : ALU
        // alu
        case (alu_op)
            3'd0: begin
                   alu_out = alu_a + alu_b; //performs addition
               end
            3'd1: begin
                   alu_out = alu_a - alu_b; //performs subtraction
					end
				3'd2: begin
                   alu_out = alu_a * alu_b; //performs multiplication
               end
				3'd3: begin
				      alu_out = -alu_a;//perform negation
					end
				3'd4: begin
				      alu_out = Q;//Assign to Quotient
					end
				3'd5: begin
				      alu_out = val;//Assign to square root value
				   end 
            default: alu_out = 9'b0;
        endcase
    end

endmodule


module control2(clk, resetn, go, ld_alu_out, alu_op, ld_A1, ld_A2, ld_B1, ld_B2, ld_C1, ld_C2, ld_D, ld_DX, ld_DY, ld_P1, ld_P2, ld_x, ld_y, alu_select_a, alu_select_b);

	 input clk, resetn, go;
	 output reg ld_A1, ld_A2, ld_B1, ld_B2, ld_C1, ld_C2, ld_D, ld_DX, ld_DY, ld_P1, ld_P2, ld_x, ld_y;
	 output reg ld_alu_out;
	 output reg [1:0] alu_op;
    output reg [3:0]  alu_select_a, alu_select_b;

    reg [4:0] current_state, next_state;

    localparam  LOAD_A1        = 5'd0,
                LOAD_A1_WAIT   = 5'd1,
                LOAD_A2        = 5'd2,
                LOAD_A2_WAIT   = 5'd3,
                LOAD_B1        = 5'd4,
                LOAD_B1_WAIT   = 5'd5,
                LOAD_B2        = 5'd6,
                LOAD_B2_WAIT   = 5'd7,
					 LOAD_C1        = 5'd8,
                LOAD_C1_WAIT   = 5'd9,
                LOAD_C2        = 5'd10,
                LOAD_C2_WAIT   = 5'd11,
                CYCLE_SIM_0    = 5'd12,
                CYCLE_SIM_1    = 5'd13,
                CYCLE_SIM_2    = 5'd14,
                CYCLE_SIM_3    = 5'd15,
					 CYCLE_SIM_4    = 5'd16,
					 CYCLE_SIM_5    = 5'd17,
                CYCLE_SIM_6    = 5'd18,
                CYCLE_SIM_7    = 5'd19,
                CYCLE_SIM_8    = 5'd20,
					 CYCLE_SIM_9    = 5'd21,
					 CYCLE_SIM_10   = 5'd22;
					 
    // Next state logic aka our state table
    always@(*)
    begin: state_table
            case (current_state)
					 LOAD_A1: next_state = go ? LOAD_A1_WAIT : LOAD_A1; // Loop in current state until value is input
                LOAD_A1_WAIT: next_state = go ? LOAD_A1_WAIT : LOAD_A2; // Loop in current state until go signal goes low
					 LOAD_A2: next_state = go ? LOAD_A2_WAIT : LOAD_A2; // Loop in current state until value is input
                LOAD_A2_WAIT: next_state = go ? LOAD_A2_WAIT : LOAD_B1	; // Loop in current state until go signal goes low
					 LOAD_B1: next_state = go ? LOAD_B1_WAIT : LOAD_B1; // Loop in current state until value is input
                LOAD_B1_WAIT: next_state = go ? LOAD_B1_WAIT : LOAD_B2; // Loop in current state until go signal goes low
					 LOAD_B2: next_state = go ? LOAD_B2_WAIT : LOAD_B2; // Loop in current state until value is input
                LOAD_B2_WAIT: next_state = go ? LOAD_B2_WAIT : LOAD_C1; // Loop in current state until go signal goes low
					 LOAD_C1: next_state = go ? LOAD_C1_WAIT : LOAD_C1; // Loop in current state until value is input
                LOAD_C1_WAIT: next_state = go ? LOAD_C1_WAIT : LOAD_C2; // Loop in current state until go signal goes low
					 LOAD_C2: next_state = go ? LOAD_C2_WAIT : LOAD_C2; // Loop in current state until value is input
                LOAD_C2_WAIT: next_state = go ? LOAD_C2_WAIT : CYCLE_SIM_0; // Loop in current state until go signal goes low
					 CYCLE_SIM_0: next_state = CYCLE_SIM_1;
                CYCLE_SIM_1: next_state = CYCLE_SIM_2;
					 CYCLE_SIM_2: next_state = CYCLE_SIM_3;
                CYCLE_SIM_3: next_state = CYCLE_SIM_4;
					 CYCLE_SIM_4: next_state = CYCLE_SIM_5;
					 CYCLE_SIM_5: next_state = CYCLE_SIM_6;
					 CYCLE_SIM_6: next_state = CYCLE_SIM_7;
                CYCLE_SIM_7: next_state = CYCLE_SIM_8;
					 CYCLE_SIM_8: next_state = CYCLE_SIM_9;
                CYCLE_SIM_9: next_state = CYCLE_SIM_10;
					 CYCLE_SIM_10: next_state = LOAD_A1;
					 
            default: next_state = LOAD_A1;
        endcase
    end // state_table


    // Output logic aka all of our datapath control signals
    always @(*)
    begin: enable_signals
        // By default make all our signals 0
        ld_alu_out = 1'b0;
		  ld_A1 = 1'b0;
		  ld_A2 = 1'b0;
		  ld_B1 = 1'b0;
		  ld_B2 = 1'b0;
		  ld_C1 = 1'b0;
		  ld_C2 = 1'b0;
		  ld_D = 1'b0;
		  ld_DX = 1'b0;
		  ld_DY = 1'b0;
		  ld_P1 = 1'b0;
		  ld_P2 = 1'b0;
		  ld_x = 1'b0;
		  ld_y = 1'b0;
        alu_select_a = 4'b0;
        alu_select_b = 4'b0;
        alu_op       = 2'b0;

        case (current_state)
            LOAD_A1: begin
                ld_A1 = 1'b1;
                end
            LOAD_A2: begin
                ld_A2 = 1'b1;
                end
            LOAD_B1: begin
                ld_B1 = 1'b1;
                end
            LOAD_B2: begin
                ld_B2 = 1'b1;
                end
				LOAD_C1: begin
                ld_C1 = 1'b1;
                end
            LOAD_C2: begin
                ld_C2 = 1'b1;
                end
            CYCLE_SIM_0: begin // Do P1 <- A1 * B2
                ld_P1 = 1'b1; // store result back into P1
                alu_select_a = 4'd0; // Select register A1
                alu_select_b = 4'd3; // Also select register B2
                alu_op = 2'b01; // Do multiply operation
            end
            CYCLE_SIM_1: begin
                ld_P2 = 1'b1; // store result back into P2
                alu_select_a = 4'd2; // Select register B1
                alu_select_b = 4'd1; // Select register A2
                alu_op = 2'b01; // Do multiply operation
            end
				CYCLE_SIM_2: begin
                ld_alu_out = 1'b1; ld_B2 = 1'b1; // store result back into B2
                alu_select_a = 4'd4; // Select register C1
                alu_select_b = 4'd3; // Select register B2
                alu_op = 2'b01; // Do multiply operation
            end
				CYCLE_SIM_3: begin
                ld_alu_out = 1'b1; ld_B1 = 1'b1; // store result back into B1
                alu_select_a = 4'd2; // Select register B1
                alu_select_b = 4'd5; // Select register C2
                alu_op = 2'b01; // Do multiply operation
            end
				CYCLE_SIM_4: begin
                ld_alu_out = 1'b1; ld_A1 = 1'b1; // store result back into A1
                alu_select_a = 4'd0; // Select register A1
                alu_select_b = 4'd5; // Select register C2
                alu_op = 2'b01; // Do multiply operation
            end
				CYCLE_SIM_5: begin
                ld_alu_out = 1'b1; ld_A2 = 1'b1; // store result back into A2
                alu_select_a = 4'd4; // Select register C1
                alu_select_b = 4'd1; // Select register A2
                alu_op = 2'b01; // Do multiply operation
            end
				CYCLE_SIM_6: begin
                ld_D = 1'b1; // store result back into D
                alu_select_a = 4'd9; // Select register P1
                alu_select_b = 4'd10; // Select register P2
                alu_op = 2'b10; // Do subtraction
            end
				CYCLE_SIM_7: begin
                ld_DY = 1'b1; // store result back into DY
                alu_select_a = 4'd0; // Select register A1
                alu_select_b = 4'd1; // Select register A2
                alu_op = 2'b10; // Do subtraction
            end
				CYCLE_SIM_8: begin
                ld_DX = 1'b1; // store result back into DX
                alu_select_a = 4'd3; // Select register B2
                alu_select_b = 4'd2; // Select register B1
                alu_op = 2'b10; // Do subtraction
            end
				CYCLE_SIM_9: begin
                ld_x = 1'b1; // store result back into X
                alu_select_a = 4'd7; // Select register DX
                alu_select_b = 4'd6; // Select register D
                alu_op = 2'b11; // Do division
            end
				CYCLE_SIM_10: begin
                ld_y = 1'b1; // store result back into Y
                alu_select_a = 4'd8; // Select register DY
                alu_select_b = 4'd6; // Select register D
                alu_op = 2'b11; // Do division
            end
				
        // default:    // don't need default since we already made sure all of our outputs were assigned a value at the start of the always block
        endcase
    end // enable_signals
	 
    // current_state registers
    always@(posedge clk)
    begin: state_FFs
        if(!resetn)
            current_state <= LOAD_A1;
        else
            current_state <= next_state;
    end // state_FFS
endmodule


module datapath2(clk, resetn, data_in, ld_alu_out, ld_A1, ld_A2, ld_B1, ld_B2, ld_C1, ld_C2, ld_D, ld_DX, ld_DY, ld_P1, ld_P2, ld_x, ld_y, alu_op, alu_select_a, alu_select_b, X, Y, inf_en, no_en);

    input clk, resetn;
	 input [7:0] data_in;
	 input ld_alu_out;
	 input ld_A1, ld_A2, ld_B1, ld_B2, ld_C1, ld_C2;
	 input ld_D, ld_DX, ld_DY, ld_P1, ld_P2, ld_x, ld_y;
	 input [1:0]alu_op;
	 input [3:0] alu_select_a, alu_select_b;
	 output reg signed [8:0] X, Y;
	 output reg inf_en, no_en;
	 
    // input registers
    reg signed [8:0] a1, a2, b1, b2, c1, c2;
	 reg signed [8:0] d, dx, dy, p1, p2;

    // output of the alu
    reg signed [8:0] alu_out;
	 
	 // alu input muxes
    reg signed [8:0] alu_a, alu_b;
	 
	 wire signed [8:0] Q, R;
	 reg wrong_en;
	 
    // Registers a, b, c, x with respective input logic
    always@(posedge clk) begin
        if(!resetn) begin
            a1 <= 9'b0;
				a2 <= 9'b0;
            b1 <= 9'b0;
				b2 <= 9'b0;
            c1 <= 9'b0;
            c2 <= 9'b0;
				d  <= 9'b0;
				dx <= 9'b0;
				dy <= 9'b0;
				p1 <= 9'b0;
				p2 <= 9'b0;
				wrong_en <= 1'b0;
				inf_en <= 1'b0;
				no_en <= 1'b0;
        end
        else begin
            if(ld_A1)
                a1 <= ld_alu_out ? alu_out : data_in; 
				if(ld_A2)
                a2 <= ld_alu_out ? alu_out : data_in; 
            if(ld_B1)
                b1 <= ld_alu_out ? alu_out : data_in; 
			   if(ld_B2)
                b2 <= ld_alu_out ? alu_out : data_in; 
            if(ld_C1)
                c1 <= data_in;
            if(ld_C2)
                c2 <= data_in;
				if(ld_D)
				begin
                d <= alu_out;
					 if(alu_out == 9'd0)
					 begin
						wrong_en <= 1'b1;
					 end
				end
            if(ld_DX)
				begin
                dx <= alu_out;
					 if(wrong_en == 1'b1)
					 begin
						if(alu_out == 9'd0)
							inf_en <= 1'b1;
						else
							wrong_en <= 1'b1;
					 end
				end
				if(ld_DY)
				begin
					dy <= alu_out;
					if(wrong_en == 1'b1)
					begin
					if(alu_out == 9'd0)
						inf_en <= 1'b1;
					else
						no_en <= 1'b1;
					end
				end
				if(ld_P1)
                p1 <= alu_out;
            if(ld_P2)
                p2 <= alu_out;
        end
    end

    // Output result register
    always@(posedge clk) begin
        if(!resetn) begin
            X <= 9'b0;
				Y <= 9'b0;
        end
			else
			begin
				if(wrong_en)
				begin
					X <= 0;
					Y <= 0;
				end
				else
				begin
					if(ld_x)
						X <= alu_out;
					if(ld_y)
						Y <= alu_out;
				end
		  end
    end

    // The ALU input multiplexers
    always @(*)
    begin
        case (alu_select_a)
            4'd0:
                alu_a = a1;
            4'd1:
                alu_a = a2;
            4'd2:
                alu_a = b1;
            4'd3:
                alu_a = b2;
				4'd4:
                alu_a = c1;
				4'd5:
                alu_a = c2;
				4'd6:
                alu_a = d;
			   4'd7:
                alu_a = dx;
				4'd8:
                alu_a = dy;
				4'd9:
                alu_a = p1;
				4'd10:
                alu_a = p2;
            default: alu_a = 10'b0;
        endcase

        case (alu_select_b)
            4'd0:
                alu_b = a1;
            4'd1:
                alu_b = a2;
            4'd2:
                alu_b = b1;
            4'd3:
                alu_b = b2;
				4'd4:
                alu_b = c1;
				4'd5:
                alu_b = c2;
				4'd6:
                alu_b = d;
			   4'd7:
                alu_b = dx;
				4'd8:
                alu_b = dy;
				4'd9:
                alu_b = p1;
				4'd10:
                alu_b = p2;
            default: alu_b = 9'b0;
        endcase
    end
	 
	  DivCkt u0 (alu_b, alu_a, Q, R);
	  
    // The ALU
    always @(*)
    begin : ALU
        // alu
        case (alu_op)
            2'b00: begin
                   alu_out = alu_a + alu_b; //performs addition
               end
            2'b01: begin
                   alu_out = alu_a * alu_b; //performs multiplication
               end
				2'b10: begin
                   alu_out = alu_a - alu_b; //performs subtraction
               end
				2'b11: begin
                   alu_out = Q; //assigns to quotient
               end
            default: alu_out = 9'b0;
        endcase
    end

endmodule



