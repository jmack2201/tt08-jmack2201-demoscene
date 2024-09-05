module demoscene_wrapper (
    input clk, rst_n,
    output [1:0] vga_r, vga_b, vga_g,
    output hsync, vsync
);
    reg [9:0] h_count, v_count;
    reg visible;

    hvsync_generator vga (
        .clk(clk),
        .reset(~rst_n),
        .hpos(h_count),
        .vpos(v_count),
        .display_on(visible),
        .hsync(hsync),
        .vsync(vsync)
    );

    pixel_color pixel (
        .clk(clk),
        .visible(visible),
        .hpos(h_count),
        .vpos(v_count),
        .hsync(hsync),
        .vsync(vsync),
        .rst_n(rst_n),
        .R(vga_r),
        .G(vga_g),
        .B(vga_b)
    );

endmodule