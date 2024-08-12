module pixel_color (
    input clk,
    output [7:0] vga_color
);
    sprite_rom rom (.clk(clk), .addr(8'h00), .color_out(vga_color));
endmodule