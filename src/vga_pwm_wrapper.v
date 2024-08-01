module vga_pwm_wrapper (
    input clk, rst_n,
    input [1:0] vga_state, audio_select,
    output [1:0] vga_r, vga_b, vga_g,
    output hsync, vsync, pwm_out
);
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

    pwm pwm ();

    audio_source audio_source();
endmodule