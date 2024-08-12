module vga_pwm_wrapper (
    input clk, rst_n, SCLK, SSEL, MOSI,
    output [1:0] vga_r, vga_b, vga_g,
    output hsync, vsync, pwm_out, MISO
);
    reg [10:0] h_count, v_count;
    reg visible;

    assign {vga_r,vga_g,vga_b} = h_count[5:0];

    vga vga (
        .clk(clk),
        .rst_n(rst_n),
        .h_count(h_count),
        .v_count(v_count),
        .visible(visible),
        .hsync(hsync),
        .vsync(vsync)
    );

    spi spi (
        .SCLK(SCLK),
        .SSEL(SSEL),
        .MOSI(MOSI),
        .MISO(MISO)
    );

    reg audio_source_out;

    pwm pwm (
        .clk(clk),
        .rst_n(rst_n),
        .audio_in(audio_source_out),
        .sample(8'h01),
        .pwm_out(pwm_out)
    );

    pixel_color pixel (
        .clk(clk),
        .vga_color({vga_r,vga_g,vga_b})
    );

    audio_source audio_source(
        .clk(clk),
        .rst_n(rst_n),
        .audio_out(audio_source_out)
    );
endmodule