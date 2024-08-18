module pixel_color (
    input clk, hsync, vsync, rst_n,
    input [9:0] hpos, vpos,
    input visible,
    output reg [5:0] vga_color
);
    // sprite_rom rom (.clk(clk), .addr(8'h00), .color_out(vga_color));

    reg [7:0] background_state;

    reg [9:0] moving_counter;

    always @(posedge vsync) begin
        if (!rst_n) begin
            moving_counter <= 0;
        end else begin
            moving_counter <= moving_counter + 1;
        end
    end

    always @(*) begin
        background_state = 0;
        case (background_state)
            0 : vga_color = 6'b000011;
            default: vga_color = 6'b000000;
        endcase
    end

endmodule