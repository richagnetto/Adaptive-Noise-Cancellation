module sockit_top (
    input  OSC_50_B8A,

    inout  AUD_ADCLRCK,
    input  AUD_ADCDAT,
    inout  AUD_DACLRCK,
    output AUD_DACDAT,
    output AUD_XCK,
    inout  AUD_BCLK,
    output AUD_I2C_SCLK,
    inout  AUD_I2C_SDAT,
    output AUD_MUTE,

    input  [3:0] KEY,
    input  [3:0] SW,
    output [3:0] LED
);

logic reset = !KEY[0];
logic main_clk;
logic audio_clk;

logic [1:0] sample_end;
logic [1:0] sample_req;
logic [15:0] audio_output;
logic [15:0] audio_input;

clock_pll pll (
    .refclk (OSC_50_B8A),
    .rst (reset),
    .outclk_0 (audio_clk),
    .outclk_1 (main_clk)
);

i2c_av_config av_config (
    .clk (main_clk),
    .reset (reset),
    .i2c_sclk (AUD_I2C_SCLK),
    .i2c_sdat (AUD_I2C_SDAT),
    .status (LED)
);

assign AUD_XCK = audio_clk;
assign AUD_MUTE = (SW != 4'b0);

audio_codec ac (
    .clk (audio_clk),
    .reset (reset),
    .sample_end (sample_end),
    .sample_req (sample_req),
    .audio_output (audio_output),
    .audio_input (audio_input),
    .channel_sel (2'b10),

    .AUD_ADCLRCK (AUD_ADCLRCK),
    .AUD_ADCDAT (AUD_ADCDAT),
    .AUD_DACLRCK (AUD_DACLRCK),
    .AUD_DACDAT (AUD_DACDAT),
    .AUD_BCLK (AUD_BCLK)
);

LMS  fast_lms(
	.clk(main_clk),    // 50 MHz - main clock
	.KEY(reset),         // Pushbutton[3:0]
	.SW(SW),
	.AUD_DACLRCK(AUD_DACLRCK), // Audio CODEC DAC LR Clock - audio_clk
	.audio_inL(audio_input),
	.audio_outL(audio_output)
);
endmodule