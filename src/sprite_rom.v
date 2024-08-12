module sprite_rom (
    input clk,
    input [7:0] addr,
    output reg [7:0] color_out
);
    reg [7:0] color_arr [0:7];
    always @(posedge clk ) begin
        color_out <= color_arr[addr];
    end
endmodule
