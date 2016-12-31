module LMS (
	input         clk,    // 50 MHz
	input	  KEY,         // Pushbutton[3:0]
	input  [3:0] SW,
	input         AUD_DACLRCK,
	input [15:0]  audio_inL,
	output [15:0] audio_outL
);

logic reset;
reg reset1;
assign reset = ~KEY;
reg [15:0] audio_inR;
reg signed [15:0] audio_outLtemp, audio_outRtemp;
reg [3:0]state;

reg signed [31:0] w1,w2,w3,w4,w5,w6,w7,w8,w9,w10,w11,w12,w13,w14,w15,w16;
reg signed [31:0] u0,u1,u2,u3,u4,u5,u6,u7,u8,u9,u10,u11,u12,u13,u14,u15;
logic [3:0] step;
logic signed [31:0] error ;

logic signed [31:0] 	w1_x_u15,w2_x_u14,w3_x_u13,w4_x_u12,w5_x_u11,w6_x_u10,w7_x_u9,w8_x_u8,w9_x_u7,w10_x_u6,w11_x_u5,w12_x_u4,w13_x_u3,w14_x_u2,w15_x_u1,w16_x_u0;
// mult for weight times ref and weight times phase-shifted ref
multiplier w1xu15(w1_x_u15, w1, u15);
multiplier w2xu14(w2_x_u14, w2, u14);
multiplier w3xu13(w3_x_u13, w3, u13);
multiplier w4xu12(w4_x_u12, w4, u12) ;
multiplier w5xu11(w5_x_u11, w5, u11);
multiplier w6xu10(w6_x_u10, w6, u10) ;
multiplier w7xu9(w7_x_u9, w7, u9);
multiplier w8xu8(w8_x_u8, w8, u8) ;
multiplier w9xu7(w9_x_u7, w1, u7);
multiplier w10xu6(w10_x_u6, w2, u6) ;
multiplier w11xu5(w11_x_u5, w3, u5);
multiplier w12xu4(w12_x_u4, w4, u4) ;
multiplier w13xu3(w13_x_u3, w5, u3);
multiplier w14xu2(w14_x_u2, w6, u2) ;
multiplier w15xu1(w15_x_u1, w7, u1);
multiplier w16xu0(w16_x_u0, w8, u0) ;

assign error = {audio_inL, 16'd0}- (w1_x_u15 + w2_x_u14 + w3_x_u13 + w4_x_u12 + w5_x_u11 + w6_x_u10 + w7_x_u9 + w8_x_u8 + w9_x_u7 + w10_x_u6 + w11_x_u5 + w12_x_u4 + w13_x_u3 + w14_x_u2 + w15_x_u1 + w16_x_u0);
assign step=4'd1;

reg signed [31:0]circl_buffer[15:0];
reg unsigned [6:0] base_ptr;


reg [3:0] counter;
always@(posedge AUD_DACLRCK)
begin
	if (~reset) begin
		counter <= 0;
	end else begin
	if (counter <10)
		counter<=counter+1;
	end
	if (counter == 8) begin
		reset1 <= 1;
	end
	else begin
		reset1 <= 0;
	end
end


always@(negedge AUD_DACLRCK)
begin
	if(SW[0])
		begin
			audio_outLtemp<={audio_inL[15],audio_inL[15:1]};
		end
	else
if (AUD_DACLRCK==0)
	begin
		audio_outLtemp[15:0]<=error[31:16];
	end
end

assign audio_outL = audio_outLtemp;

always@(posedge clk) begin
	if((~reset) | (reset1 == 1)) begin
		w1 <= 32'd0 ;
		w2 <= 32'd0 ;
		w3 <= 32'd0 ;
		w4 <= 32'd0 ;
		w5 <= 32'd0 ;
		w6 <= 32'd0 ;
		w7 <= 32'd0 ;
		w8 <= 32'd0 ;
		w9 <= 32'd0 ;
		w10 <= 32'd0 ;
		w11 <= 32'd0 ;
		w12 <= 32'd0 ;
		w13 <= 32'd0 ;
		w14 <= 32'd0 ;
		w15 <= 32'd0 ;
		w16 <= 32'd0 ;
		base_ptr<=5'd0;
	end

	else if (AUD_DACLRCK==0) begin
		state<=1;
	end
	else begin
		case(state)
			1:begin
				u15<=-{audio_inL,16'd0};
				state<=2;
			end
			2:begin
				w1 <= w1 + (((u15[31])? -error : error)>>>step);
				w2 <= w2 + (((u14[31])? -error : error)>>>step);
				w3 <= w3 + (((u13[31])? -error : error)>>>step);
				w4 <= w4 + (((u12[31])? -error : error)>>>step);
				w5 <= w5 + (((u11[31])? -error : error)>>>step);
				w6 <= w6 + (((u10[31])? -error : error)>>>step);
				w7 <= w7 + (((u9[31])? -error : error)>>>step);
				w8 <= w8 + (((u8[31])? -error : error)>>>step);
				w9 <= w9 + (((u7[31])? -error : error)>>>step);
				w10 <= w10 + (((u6[31])? -error : error)>>>step);
				w11 <= w11 + (((u5[31])? -error : error)>>>step);
				w12 <= w12 + (((u4[31])? -error : error)>>>step);
				w13 <= w13 + (((u3[31])? -error : error)>>>step);
				w14 <= w14 + (((u2[31])? -error : error)>>>step);
				w15 <= w15 + (((u1[31])? -error : error)>>>step);
				w16 <= w16 + (((u0[31])? -error : error)>>>step);
				state<=3;
			end
			3:begin
				circl_buffer[base_ptr+4'd15]<=u15;
				circl_buffer[base_ptr+4'd14]<=u14;
				circl_buffer[base_ptr+4'd13]<=u13;
				circl_buffer[base_ptr+4'd12]<=u12;
				circl_buffer[base_ptr+4'd11]<=u11;
				circl_buffer[base_ptr+4'd10]<=u10;
				circl_buffer[base_ptr+4'd9]<=u9;
				circl_buffer[base_ptr+4'd8]<=u8;
				circl_buffer[base_ptr+4'd7]<=u7;
				circl_buffer[base_ptr+4'd6]<=u6;
				circl_buffer[base_ptr+4'd5]<=u5;
				circl_buffer[base_ptr+4'd4]<=u4;
				circl_buffer[base_ptr+4'd3]<=u3;
				circl_buffer[base_ptr+4'd2]<=u2;
				circl_buffer[base_ptr+4'd1]<=u1;
				circl_buffer[base_ptr+4'd0]<=u0;
				state<=4;
			end
			4: begin
				base_ptr<=base_ptr+4'd1;
				state<=5;
			end
			5: begin
				u14<=circl_buffer[base_ptr+4'd14];
				u13<=circl_buffer[base_ptr+4'd13];
				u12<=circl_buffer[base_ptr+4'd12];
				u11<=circl_buffer[base_ptr+4'd11];
				u10<=circl_buffer[base_ptr+4'd10];
				u9<=circl_buffer[base_ptr+4'd9];
				u8<=circl_buffer[base_ptr+4'd8];
				u7<=circl_buffer[base_ptr+4'd7];
				u6<=circl_buffer[base_ptr+4'd6];
				u5<=circl_buffer[base_ptr+4'd5];
				u4<=circl_buffer[base_ptr+4'd4];
				u3<=circl_buffer[base_ptr+4'd3];
				u2<=circl_buffer[base_ptr+4'd2];
				u1<=circl_buffer[base_ptr+4'd1];
				u0<=circl_buffer[base_ptr+4'd0];
				state<=6;
			end
			6: begin
			end
		endcase
		end
	end // always end
endmodule

//////////////////////////////////////////////////
//// signed mult of 2.16 format 2'comp////////////
//////////////////////////////////////////////////
module multiplier (out, a, b);

	output 		[31:0]	out;
	input 	signed	[31:0] 	a;
	input 	signed	[31:0] 	b;

	logic	signed	[31:0]	out;
	logic 	signed	[63:0]	mult_out;

	assign mult_out = a * b;
	//assign out = mult_out[33:17];
	assign out = {mult_out[63], mult_out[60:30]};
endmodule

/*module tbench();

	reg clk;
	reg AUD_DACLRCK;
	reg clk,clk1;
	reg signed [15:0] testData [22049:0];
	reg signed [15:0] noise [22049:0];
	reg [3:0] KEY;
	logic [17:0] SW;
	//assign KEY = 1;
	//assign SW=1;
	assign SW=18'b00110000000000000;

	//assign SW[0]=0;
	reg [15:0]  audio_inL;
	reg [15:0]  audio_inR;
	//reg [15:0] audio_outL;
	//reg [15:0] audio_outR;
	logic  signed [15:0] audio_outL;
	logic  signed [15:0] audio_outR;
	integer filehandlerL,filehandlerR;
	initial filehandlerL = $fopen("outputL");
	initial filehandlerR = $fopen("outputR");
	LMS dut(.clk(CLOCK_50), .KEY(KEY), .SW(SW), .AUD_DACLRCK(AUD_DACLRCK), .audio_inL(audio_inL), .audio_inR(audio_inR), .audio_outL(audio_outL), .audio_outR(audio_outR));


	//assign CLOCK_50=clk;
//	initial begin
//	clk=0;
//	//assign CLOCK_50=0;
//	//always #20000 clk= ~clk;
//	forever #20000 clk=~clk;
//	end


	initial begin
		CLOCK_50=0;
		forever #20000 CLOCK_50=~CLOCK_50;
	end

	initial begin
	@(posedge CLOCK_50);
	assign KEY = 4'b0000;

	@(posedge CLOCK_50);
	assign KEY = 4'b0001;
	end
// 	initial begin
//	clk1=0;
//	//assign CLOCK_50=0;
//	forever #22675736 clk1= ~clk1;
//	end

//	initial begin
//	assign AUD_DACLRCK=0;
//	//assign CLOCK_50=0;
//	forever #22675736 AUD_DACLRCK= ~AUD_DACLRCK;
//	end

	initial begin
	AUD_DACLRCK=0;
	//assign CLOCK_50=0;
	forever #22675736 AUD_DACLRCK= ~AUD_DACLRCK;
	end

	//assign CLOCK_50=clk;
	//assign AUD_DACLRCK=clk1;
	//always #22675736 AUD_DACLRCK =~AUD_DACLRCK;

	initial $readmemh("noisy", testData);
	initial $readmemh("contaminated", noise);

	integer i;
	initial begin
		for(i=0;i<22050;i=i+1) begin
			if(i==7)
			begin
				@(posedge AUD_DACLRCK);
				assign KEY = 4'b0000;
				@(posedge CLOCK_50);
				assign KEY = 4'b0001;
			end
			@(posedge AUD_DACLRCK);
			$display($time, " <<audio_inR: testData[%d][15:0] = %d >>", i, testData[i][15:0]);
			$display($time, " <<audio_inL: testData[%d][15:0] = %d >>", i, noise[i][15:0]);
			#1; audio_inL = noise[i][15:0]; audio_inR = testData[i][15:0];
		end

		$finish;
	end

	always @(negedge AUD_DACLRCK)begin
		$fdisplay(filehandlerR, "%d", audio_outR);
		$fdisplay(filehandlerL, "%d", audio_outL);
	end

endmodule*/
