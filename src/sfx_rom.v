module sfx_rom (
    input clk,
    input [7:0] addr,
    output [7:0] note_out
);
    reg [7:0] note_arr [0:7];
    always @(posedge clk ) begin
        note_out <= note_arr[addr];
    end
endmodule