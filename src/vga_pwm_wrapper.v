module vga_pwm_wrapper (
    input clk, rst_n,
    output [1:0] vga_r, vga_b, vga_g,
    output hsync, vsync, pwm_out
);
    reg [10:0] hcount, vcount;
    vga vga (
        .clk(clk),
        .rst_n(rst_n),
        .vga_state(vga_state),
        .vga_r(vga_r),
        .vga_g(vga_g),
        .vga_b(vga_b),
        .hsync(hsync),
        .vsync(vsync)
    );

    reg audio_source_out;

    pwm pwm (
        .clk(clk),
        .rst_n(rst_n),
        .audio_in(audio_source_out),
        .sample(8'h01),
        .pwm_out(pwm_out)
    );

    audio_source audio_source(
        .clk(clk),
        .rst_n(rst_n),
        .audio_select(audio_select),
        .audio_out(audio_source_out)
    );
endmodule