module sprite_rom (
    input clk,
    input [10:0] addr,
    output reg [7:0] color_out
);
    reg [7:0] color_arr [2047:0];
    initial begin
        color_arr[0] = 8'h0F;
    end
    always @(posedge clk ) begin
        color_out <= color_arr[addr];
    end
endmodule
