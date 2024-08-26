module demoscene_wrapper (
    input clk, rst_n, SCLK, SSEL, MOSI,
    output [1:0] vga_r, vga_b, vga_g,
    output hsync, vsync, audio_out, MISO
);
    reg [9:0] h_count, v_count;
    reg visible;

    reg [7:0] background_state;
    reg [5:0] solid_color;
    reg audio_en;

    hvsync_generator vga (
        .clk(clk),
        .reset(~rst_n),
        .hpos(h_count),
        .vpos(v_count),
        .display_on(visible),
        .hsync(hsync),
        .vsync(vsync)
    );

    spi spi (
        .SCLK(SCLK),
        .SSEL(SSEL),
        .MOSI(MOSI),
        .MISO(MISO),
        .background_state(background_state),
        .solid_color(solid_color),
        .audio_en(audio_en)
    );

    pixel_color pixel (
        .clk(clk),
        .visible(visible),
        .hpos(h_count),
        .vpos(v_count),
        .hsync(hsync),
        .vsync(vsync),
        .rst_n(rst_n),
        .background_state(background_state),
        .solid_color(solid_color),
        .R(vga_r),
        .G(vga_g),
        .B(vga_b)
    );

    audio_source audio_source(
        .clk(clk),
        .rst_n(rst_n),
        .audio_en(audio_en),
        .audio_out(audio_out)
    );
endmodule